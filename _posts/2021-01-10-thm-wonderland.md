---
layout: post
title: TryHackMe - Wonderland
---

Room: [Wonderland](https://tryhackme.com/room/wonderland)

## Enumeration and Initial Access
An `nmap` scan reveals SSH and HTTP services on their standard ports. The home page of the website says to follow the white rabbit and includes a JPG of a white rabbit. I downloaded the image and ran it through `steghide extract -sf white_rabbit_1.jpg` with no passphrase supplied. A hint.txt file was extracted that contained the text:

> follow the r a b b i t

I ran a `gobuster` scan and found 3 interesting directories: /img, /r, and /poem. I re-ran the scan with /r as the root directory and found a new directory /r/a. Each subdirectory up to /r/a/b/b/i/t/ had it's own message. On the final page, SSH credentials were hidden for the user alice in the page's source.

## Elevating Privileges

There is a root.txt file in /home/alice which was unreadable with alice's permissions. Given the hint that "Everything is upside down here", I made a guess that alice's user flag could be stored in the /root directory.
```sh
alice@wonderland:~$ cat /root/user.txt
thm{censored}
```
I first escalated to the user rabbit. There is a Python script in alice's home directory called walrus_and_the_carpenter.py which imports the random library. Running `sudo -l`, I discovered that alice could run both /usr/bin/python3.6 and /home/alice/walrus_and_the_carpenter.py with rabbit's permissions. With only read access, the script could not be edited. But given that Python will first check the current directory for libraries to import, I realized I had an easy path to escalation. I created a random.py file in the current working directory that was loaded instead of the canonical random module to get a shell:

```py
import os

os.system("/bin/bash")
```

I executed the script in alice's home directory like so:

```bash
alice@wonderland:~$ sudo -u rabbit /usr/bin/python3.6 /home/alice/walrus_and_the_carpenter.py
```

In the new user rabbit's home directory was a setuid binary called "teaParty" that executed the `date` command without specifying its absolute path. I created a file named "date" which included a call to `/bin/bash`, added execution permissions, and added the directory it was in to the front of the PATH.
```
rabbit@wonderland:/home/rabbit$ export PATH=/tmp:$PATH
```

Thus, `./teaParty` would first look in /tmp for `date` and give me a new shell. Upon execution, I became user hatter. When running `id`, I noticed only the UID had changed however. Luckily, in hatter's home directory was a password file, and I was able to officially become the user rabbit with `su hatter` and the password.

I copied LinPEAS into a file and ran it, discovering that perl had the `cap_setuid+ep` capability set. Per GTFOBins:

> If the binary has the Linux CAP_SETUID capability set or it is executed by another binary with the capability set, it can be used as a backdoor to maintain privileged access by manipulating its own process UID.

I used their supplied exploit, running the following and getting the root flag:

```
hatter@wonderland:~$ perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/sh";'
# cat /home/alice/root.txt
thm{censored}
```