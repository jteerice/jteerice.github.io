---
layout: post
title: pwnable.kr - fd
---

## Prompt
Mommy! what is a file descriptor in Linux?
`ssh fd@pwnable.kr -p2222 (pw:guest)`

## Solution
We are given 3 files: `fd`, `fd.c`, and `flag`. We cannot open flag, but can read `fd.c` and run the executable.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char buf[32];
int main(int argc, char* argv[], char* envp[]){
        if(argc<2){
                printf("pass argv[1] a number\n");
                return 0;
        }
        int fd = atoi( argv[1] ) - 0x1234;
        int len = 0;
        len = read(fd, buf, 32);
        if(!strcmp("LETMEWIN\n", buf)){
                printf("good job :)\n");
                system("/bin/cat flag");
                exit(0);
        }
        printf("learn about Linux file IO\n");
        return 0;

}
```
We need to pass in a string that will be converted into an integer and subtracted by 0x1234. The difference will be used as a file descriptor to be read from. The easiest to work with would be fd=0, which is for stdin. Then we can submit the string to be compared to `LETMEWIN\n` by typing `LETMEWIN` into stdin and pressing enter--which appends `\n`.

```
fd@pwnable:~$ echo $((16#1234))
4660
fd@pwnable:~$ echo $((4660 - 16#1234))
0
fd@pwnable:~$ ./fd 4660
LETMEWIN
good job :)
{flag censored}
```


