---
layout: post
title: ./missing-semester - Course Overview + The Shell - Exercises
---
Course located at: [missing.csail.mit.edu](https://missing.csail.mit.edu/)
## Exercises
* For this course, you need to be using a Unix shell like Bash or ZSH. If you are on Linux or macOS, you don’t have to do anything special. If you are on Windows, you need to make sure you are not running cmd.exe or PowerShell; you can use Windows Subsystem for Linux or a Linux virtual machine to use Unix-style command-line tools. To make sure you’re running an appropriate shell, you can try the command echo $SHELL. If it says something like /bin/bash or /usr/bin/zsh, that means you’re running the right program.
```bash
$ echo $SHELL
/bin/bash
```
* Create a new directory called missing under /tmp.
```bash
mkdir /tmp/missing
```
* Look up the touch program. The man program is your friend.
```bash
man touch
```
* Use touch to create a new file called semester in missing.
```bash
touch /tmp/missing/semester
```
* Write the following into that file, one line at a time: `#!/bin/sh` and `curl --head --silent https://missing.csail.mit.edu`. The first line might be tricky to get working. It’s helpful to know that # starts a comment in Bash, and ! has a special meaning even within double-quoted (") strings. Bash treats single-quoted strings (') differently: they will do the trick in this case. See the Bash quoting manual page for more information.
```
echo '#!/bin/sh' >> semester
echo 'curl --head --silent https://missing.csail.mit.edu' >> semester
```
* Try to execute the file, i.e. type the path to the script (./semester) into your shell and press enter. Understand why it doesn’t work by consulting the output of ls (hint: look at the permission bits of the file).
```
No execution bit
```

* Run the command by explicitly starting the `sh` interpreter, and giving it the file semester as the first argument, i.e. `sh semester`. Why does this work, while `./semester` didn’t?

	*`./semester` asks the kernel to run semester as a program, and the kernal (program loader) will check permissions first, and then use /bin/bash (or sh or zsh etc) to actually execute the script.*

	*`sh semester` asks the kernel (program loader) to run /bin/sh, not the program so the execute permissions of the file do not matter.*

* Look up the chmod program (e.g. use man chmod). Use chmod to make it possible to run the command ./semester rather than having to type sh semester. How does your shell know that the file is supposed to be interpreted using sh? See this page on the shebang line for more information.
```
chmod +x semester
./semester
```
	*The shebang is parsed as an interpreter directive by the program loader mechanism.  The loader executes the specified interpreter program, passing to it as an argument the path that was initially used when attempting to run the script, so that the program may use the file as input data.*

* Use | and > to write the “last modified” date output by semester into a file called last-modified.txt in your home directory.
```
# expected
ls -l semester | tail -c 22 > ~/last-modified.txt
# alternate
stat -c '%y' semester > ~/last-modified.txt
```
* Write a command that reads out your laptop battery’s power level or your desktop machine’s CPU temperature from /sys. Note: if you’re a macOS user, your OS doesn’t have sysfs, so you can skip this exercise.
```
cat /sys/class/power_supply/BAT0/capacity
```
