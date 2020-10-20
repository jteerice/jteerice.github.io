---
layout: post
title: TryHackMe - Linux Challenges
---

## Linux Challenges Introduction

This rooms purpose is to learn or improve your Linux skills.

There will be challenges that will involve you using the following commands and techniques:

* Using commands such as: ls, grep, cd, tail, head, curl, strings, tmux, find, locate, diff, tar, xxd
* Understanding cronjobs, MOTD's and system mounts
* SSH'ing to other users accounts using a password and private key
* Locating files on the system hidden in different directories
* Encoding methods (base64, hex)
* MySQL database interaction
* Using SCP to download a file
* Understanding Linux system paths and system variables
* Understanding file permissions
* Using RDP for a GUI
Deploy the virtual machine attached to this task to get started.

SSH Credentials: `garry:letmein`

* How many visible files can you see in garrys home directory?
	* 3

## The Basics

### flag1

```
garry@ip-10-10-136-234:~$ cat flag1.txt 
There are flags hidden around the file system, its your job to find them.
[...]
Username: bob
Password: linuxrules
```

### flag2

```
bob@ip-10-10-136-234:~$ cat flag2.txt
Flag 2: {flag}
```

### flag3

```
bob@ip-10-10-136-234:~$ cat .bash_history 
{flag}
cat ~/.bash_history 
rm ~/.bash_history
vim ~/.bash_history
exit
ls
crontab -e
ls
cd /home/alice/
ls
cd .ssh
ssh -i .ssh/id_rsa alice@localhost
exit
ls
cd ../alice/
cat .ssh/id_rsa
cat /home/alice/.ssh/id_rsa
exit
cat ~/.bash_history 
exit
```

### flag4

```
$ crontab -e
[...]
0 6 * * * echo 'flag4:{flag}' > /home/bob/flag4.txt
```

### flag5

```
bob@ip-10-10-136-234:~$ find / -name "*flag5*" 2>/dev/null
/lib/terminfo/E/flag5.txt
bob@ip-10-10-136-234:~$ cat /lib/terminfo/E/flag5.txt
{flag}
```

### flag6

```
bob@ip-10-10-136-234:~$ grep c9 $(find / -name "*flag6*" 2>/dev/null)
Sed sollicitudin eros quis vulputate rutrum. Curabitur mauris elit, elementum quis sapien sed, ullamcorper pellentesque neque. Aliquam erat volutpat. Cras vehicula mauris vel lectus hendrerit, sed malesuada ipsum consectetur. Donec in enim id erat condimentum vestibulum {flag} vitae eget nisi. Suspendisse eget commodo libero. Mauris eget gravida quam, a interdum orci. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Quisque eu nisi non ligula tempor efficitur. Etiam eleifend, odio vel bibendum mattis, purus metus consectetur turpis, eu dignissim elit nunc at tortor. Mauris sapien enim, elementum faucibus magna at, rutrum venenatis ipsum.
```

### flag7

```
bob@ip-10-10-136-234:~$ ps -ax | grep flag7
 1371 ?        S      0:00 flag7:{flag} 1000000
 2622 pts/1    S+     0:00 grep --color=auto flag7
```


### flag8

```
bob@ip-10-10-136-234:~$ tar xf $(find / -name "*flag8*" 2>/dev/null)
bob@ip-10-10-136-234:~$ cat /home/bob/flag8.txt
{flag}
```

### flag9

```
bob@ip-10-10-136-234:~$ cat /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

127.0.0.1	{flag}.com
```

### flag10

```
bob@ip-10-10-136-234:~$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
[...]
{flag}:x:1002:1002:,,,:/home/{flag}:/bin/bash
```

## Linux Functionality

### flag11

```
bob@ip-10-10-136-234:~$ grep flag11 .bashrc
alias flag11='echo "You need to look where the alias are created..."' #{flag}
```

### flag12

```
bob@ip-10-10-136-234:/etc/update-motd.d$ cat 00-header
[...]
if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
	# Fall back to using the very slow lsb_release utility
	DISTRIB_DESCRIPTION=$(lsb_release -s -d)
fi

# Flag12: {flag}

cat logo.txt
```

### flag13

```
bob@ip-10-10-136-234:~/flag13$ diff script2 script1
2437c2437
< Lightoller sees {flag} Smith walking stiffly toward him and quickly goes to him. He yells into the Captain's ear, through cupped hands, over the roar of the steam... 
---
> Lightoller sees Smith walking stiffly toward him and quickly goes to him. He yells into the Captain's ear, through cupped hands, over the roar of the steam... 
```

### flag14

```
bob@ip-10-10-136-234:/var/log$ tail -n 1 flagtourteen.txt 
{flag}
```

### flag15

```
bob@ip-10-10-136-234:~$ cat /etc/*release
FLAG_15={flag}
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.5 LTS"
NAME="Ubuntu"
VERSION="16.04.5 LTS (Xenial Xerus)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04.5 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
VERSION_CODENAME=xenial
UBUNTU_CODENAME=xenial
```

### flag16

```
bob@ip-10-10-136-234:~$ cd /media
bob@ip-10-10-136-234:/media$ ls
f
bob@ip-10-10-136-234:/media$ ls f/
l
bob@ip-10-10-136-234:/media$ ls -R
.:
f

./f:
l

./f/l:
a

./f/l/a:
g

./f/l/a/g:
1

./f/l/a/g/1:
6

./f/l/a/g/1/6:
is

./f/l/a/g/1/6/is:
{flag}

./f/l/a/g/1/6/is/{flag}:
test.txt
```

### flag17

Given credentials `alice:TryHackMe123`, so `su alice`.

```
alice@ip-10-10-107-144:~$ cat flag17
{flag}
```

### flag18

```
alice@ip-10-10-107-144:~$ cat .flag18 
{flag}
```

### flag19

```
alice@ip-10-10-107-144:~$ head -n 2345 flag19 | tail -1
{flag}
```

## Data Representation, Strings and Permissions

### flag20

```
alice@ip-10-10-107-144:~$ cat flag20 | base64 -d
{flag}
```

### flag21
`^M` is a carriage return, which breaks `cat`. We could potentially use the `dos2unix` command if it were installed, but simplest answer is to open the file with `vim`, `less`, `nano`, etc.
```
alice@ip-10-10-107-144:~$ vim $(find / -name flag21.php 2>/dev/null)
<?=`$_POST[flag21_{flag}]`?>^M<?='MoreToThisFileThanYouThink';?>
```

### flag22
Hex to ASCII:
```
alice@ip-10-10-107-144:~$ cat flag22 | xxd -r -p
{flag}
```
### flag23

```
alice@ip-10-10-107-144:~$ rev flag23
{flag}
```
### flag24

```
alice@ip-10-10-107-144:/home/garry$ strings $(find / -name flag24 2>/dev/null) | grep flag
flag24.c
flag_24_is_{flag}
```
### flag25

Flag 25 does not exist.

### flag26
```
alice@ip-10-10-107-144:~$ find / -xdev -type f 2>/dev/null | xargs grep -E '^4bceb.{27}$' 2>/dev/null
/var/cache/apache2/mod_cache_disk/config.json:{flag}
```
### flag27
```
alice@ip-10-10-107-144:/home$ sudo -l
Matching Defaults entries for alice on ip-10-10-107-144.eu-west-1.compute.internal:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User alice may run the following commands on ip-10-10-107-144.eu-west-1.compute.internal:
    (ALL) NOPASSWD: /bin/cat /home/flag27
alice@ip-10-10-107-144:/home$ sudo /bin/cat /home/flag27
{flag}
```
### flag28: What's the linux kernel version?

```
bob@ip-10-10-136-234:~$ uname -a
Linux ip-10-10-136-234 4.4.0-1075-aws #85-Ubuntu SMP Thu Jan 17 17:15:12 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

### flag29
```
alice@ip-10-10-107-144:/home/garry$ cat flag29 | tr -d ' \n' | rev | cut -d ',' -f1 |rev 
fastidiisuscipitmeaei.
```

## SQL, FTP, Groups and RDP

### flag30
```
alice@ip-10-10-107-144:~$ curl localhost
flag30:{flag}
```

### flag31
```
alice@ip-10-10-107-144:~$ mysql -u root -p
Enter password: 
[...]
mysql> show databases;
+-------------------------------------------+
| Database                                  |
+-------------------------------------------+
| information_schema                        |
| database_{flag}                           |
| mysql                                     |
| performance_schema                        |
| sys                                       |
+-------------------------------------------+
5 rows in set (0.02 sec)
```

### bonus flag

```
mysql> use database_{flag}
[...]
mysql> show tables;
+-----------------------------------------------------+
| Tables_in_database_{flag} |
+-----------------------------------------------------+
| flags                                               |
+-----------------------------------------------------+
1 row in set (0.00 sec)

mysql> SELECT * FROM flags;
+----+----------------------------------+
| id | flag                             |
+----+----------------------------------+
|  1 | {flag}							|
+----+----------------------------------+
1 row in set (0.00 sec)
```
### flag32

Listen to the file.

```
root@kali:~/Security/TryHackMe/linuxctf#  nc -nvlp 800 > flag32.mp3

alice@ip-10-10-107-144:~$ nc 10.2.37.2 800 < flag32.mp3
```

### flag33

```
bob@ip-10-10-107-144:~$ cat .profile | grep 33
#Flag 33: {flag}
```

### flag34

```
bob@ip-10-10-107-144:~$ env | grep flag34
flag34={flag}
```

### flag35

* getent - get entries from Name Service Switch libraries

```
bob@ip-10-10-107-144:~$ getent group | grep flag35
flag35_{flag}:x:1005:
```

### flag36

```
bob@ip-10-10-107-144:~$ getent group hacker
hacker:x:1004:bob
bob@ip-10-10-107-144:~$ cat $(find / -name flag36 2>/dev/null)
{flag}
```
