---
layout: post
title: pwnable.kr - mistake
---

## Prompt
We all make mistakes, let's move on.
(don't take this too seriously, no fancy hacking skill is required at all)

This task is based on real event
Thanks to dhmonkey

hint : operator priority

ssh mistake@pwnable.kr -p2222 (pw:guest)

## Source Code Analysis
We are given an executable `mistake` and its source `mistake.c`. We are also given two additional files named `password` and `flag`.

**mistake.c**:
```c
#include <stdio.h>
#include <fcntl.h>

#define PW_LEN 10
#define XORKEY 1

void xor(char* s, int len){
        int i;
        for(i=0; i<len; i++){
                s[i] ^= XORKEY;
        }
}

int main(int argc, char* argv[]){

        int fd;
        if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
                printf("can't open password %d\n", fd);
                return 0;
        }

        printf("do not bruteforce...\n");
        sleep(time(0)%20);

        char pw_buf[PW_LEN+1];
        int len;
        if(!(len=read(fd,pw_buf,PW_LEN) > 0)){
                printf("read error\n");
                close(fd);
                return 0;
        }

        char pw_buf2[PW_LEN+1];
        printf("input password : ");
        scanf("%10s", pw_buf2);

        // xor your input
        xor(pw_buf2, 10);

        if(!strncmp(pw_buf, pw_buf2, PW_LEN)){
                printf("Password OK\n");
                system("/bin/cat flag\n");
        }
        else{
                printf("Wrong Password\n");
        }

        close(fd);
        return 0;
}
```

The program first attempts to open the `password` file and save its contents to `pw_buf`. 
```
if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){...}
```
Upon successful completion, the `open()` function opens the file and return a non-negative integer representing the lowest numbered unused file descriptor. Upon failure, the function returns `-1`. But, comparison operators like `<` are given higher priority than assignment operators `=`, so the conditional statement is interpreted like the following:

```
fd=(open("/home/mistake/password",O_RDONLY,0400) < 0) == (non_neg_int < 0) == 0
fd=0
```

The file descriptor `fd` is not being set to the response code of `open()`, but rather to `0`--the file descriptor for `stdin`. So when `read()` is called, it reads 10 bytes from `stdin` to the buffer `pw_buf`.

```
if(!(len=read(fd,pw_buf,PW_LEN) > 0)){...}
```
Then 10 characters are saved into `pw_buf2` by `scanf`, and the `xor()` function XORs every byte. Lastly, the XORed supplied password in `pw_buf2` is `strncmp`ed with what's stored in `pw_buf`.

## Solution

When you run `mistake` it waits for input. Enter an easily XORed 10-character string. Then, it asks to input the password. Enter the XORed version of the 10-character string.
```
mistake@pwnable:~$ ./mistake
do not bruteforce...
1111111111
0000000000
input password : Password OK
{flag}
```