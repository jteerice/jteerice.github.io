---
layout: post
title: Red Team Village CTF @ Grayhat 2020
---

Red Team Village put on a CTF for Grayhat attendees hosted at ctf.threatsims.com. It was meant to be a beginner-to-intermediate-level CTF with the goal of learning and having fun. In between waiting for a large PCAP file to be rescanned with different filters for Niflheim's Network CTF, I answered a few questions in this CTF. I found the tunneler challenges to be extremely interesting, and I regret not being able to spend more time on them. There is an incredible writeup for them here: [blog.ikuamike.io](https://blog.ikuamike.io/posts/2020/grayhat_red_team_village_ctf_tunneler_writeup/).

## easy crack

I put all the easy crack hashes into a file called rtvhashes and ran the following command:

```
$ john rtvhashes --wordlist=/usr/share/wordlists/rockyou.txt
sneakers	(Pamela)
stampe! 	(David)
Doughsgirl	(Christine)
5223786		(Randall)
```

## What failed

> After a hard day of defeating cyber attacks from adversaries, let's dig into some sweet log files from our server to see how many cyber attacks we single handidly stopped. What service was fail2ban configured to protect?

I've seen fail2ban used for SSH, so I guessed `ssh` and it was the flag.

## Tweets

<blockquote class="twitter-tweet tw-align-center"><p lang="en" dir="ltr">Everyone gets a flag: ts{ThanksForPlaying}</p>&mdash; NOPResearcher (@NopResearcher) <a href="https://twitter.com/NopResearcher/status/1322262075566039040?ref_src=twsrc%5Etfw">October 30, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


## Trainer

SSH to the linux trainer at trainer.threatsims.com

After getting the password, I would `su` to that user and `cd ~`.

```
$ ssh trainer.threatsims.com -l level0# with password level0.
level0@trainer:~$ cat level1_password
4202c26842398c1d0772ed9eed195113

level1@trainer:~$ cat some_directory/level2_password
943430e07fd566bc96aa05fca3c96e48

level2@trainer:~$ cat dir/another_dir/another_another_dir/some_directory/level3_password
2cadca6148093c403d82396252b8c4db

level3@trainer:~$ cat .level4_password
72f6af6b0005adb15fbc91e1b140115f

level4@trainer:~$ cat .hidden_dir/.level5_password
7b6c2552940f47a27fbd729ae0e2893c

level5@trainer:~$ cat ../level6/level6_password
7cb1963d316b9a302cf6c204d35b7302

level6@trainer:~$ cat $(find . -name *level7*)
The password for level7 is:

RG8geW91IGV2ZW4gbGlmdCBicm8g

level7@trainer:~/password_directory$ cat $(grep -l password level8*)
The password for level8 is:

bGV0J3MgZmluZCBzb21ldGhpbmcg 

level8@trainer:~$ find . -name level9*
./dir24/subdir13/level9_password
level8@trainer:~$ ./dir24/subdir13/level9_password
The password is: 96ab15e954f1267ea04c35de2d771c2b

level9@trainer:~$ grep -n evilhacker /usr/share/wordlists/rockyou.txt
955830:evilhacker
# password is 955830

level10@trainer:~$ cat welcome_message
Welcome to Level 10

For this level you are given a log file from the program fail2ban.  Fail2ban is used monitor log files for suspicious activity like too many failed logins.  It is commonly deployed for use with Apache or SSH.  After a configured number of attempts it will create an iptables (linux firewall) rule to block the ip from communicating with the device for a period of time.

The log file is located in your home directory and is called fail2ban.log.  The password to level 11 is the number of times 112.85.42.94 was banned.
level10@trainer:~$ grep 'Ban 112.85.42.94' fail2ban.log | wc -l
192

level11@trainer:~$ cat welcome_message
Welcome to Level 11

For this level you are given a file that contains the password to the next level.  The password is a md5 hash.  Research md5 hashes and find it in the file.
# find an MD5 hash (a 32 digit hexadecimal) in the file md5find
level11@trainer:~$ grep -E "[0-9a-f]{32}" md5find
0982e2a869857644074d06b1a4fd1bea

level12@trainer:~$ cat welcome_message
Welcome to Level 12

For this level you are going to find SUID and SGID binaries in common locations.  This is a common privilege escalation technique seen in CTFs and real world.  Remember the user you are looking to escalate privileges to is level13.

type: man find
      google SUID
      google SGID

level12@trainer:~$ find / -perm /4000 2>/dev/null
/usr/bin/su
/usr/bin/sudo
/usr/bin/chsh
/usr/bin/gpasswd
/usr/bin/chfn
/usr/bin/umount
/usr/bin/mount
/usr/bin/newgrp
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/sbin/mysecret
level12@trainer:~$ /usr/sbin/mysecret
f4736e1eb28b1d9055c5f5d58a49b5a6

Welcome to Level 13

For this level you are going to familiarize yourself with environment variables.  They are used for a wide variety of applications.  Specifically, they can be used for docker and cloud providers to store credentials.  They password to level 14 is is the one that ends with ID.
level13@trainer:~$ env | grep ID
AWS_ACCESS_KEY_ID=0ea027e3835aa87a4a47465321c5fe75
XDG_SESSION_ID=2288

level14@trainer:~$ cat welcome_message
Welcome to Level 14

For this level you are going to familiarize yourself with the kernel version.  We are just looking for the Kernel and Major version (the first two sets of numbers) example: if the version is 2.62.26.1 the password will be 2.62

Understanding Kernel versions can help when search for exploits with tools like searchsploit or exploitdb (Sorry, there isn't any kernel exploits for this box, I hope)

level14@trainer:~$ uname -a
Linux trainer 4.19.0-10-cloud-amd64 #1 SMP Debian 4.19.132-1 (2020-07-24) x86_64 GNU/Linux
# Level 15 pass is 4.19, Level 16 pass is Debian

level16@trainer:~$ cat welcome_message
Welcome to Level 16

For this level you are going to familiarize yourself with the aliases.  They can be very useful and can be used for a variety of actions to speed up your workflow.  They can also be very dangerous.
level16@trainer:~$ cat .bashrc
alias devbox='sshpass -p 6b39034a8045ed996a436f8d09031522 ssh level17@trainer.threatsims.com'
alias grep='grep --color=auto'
alias bc='bc -l'
alias mkdir='mkdir -pv'

level17@trainer:~$ cat .viminfo
...
9a42b1822710d790a393800f2896a8f7
...

level18@trainer:~$ tail .bash_history -n 7
find / -perm -g=s -type f 2>/dev/null
ssh level19@localhost
b06a246b0646b337f319316b9232151c
whoami
ssh level19@127.0.0.1
pwd

$ cp level19@167.71.187.239:~/.ssh/level20_id_rsa .
level19@167.71.187.239's password:
level20_id_rsa                                                      100% 1811    25.6KB/s   00:00
$ ssh level20@167.71.187.239 -i level20_id_rsa
level20@trainer:~$ cat level20_password
The password for level20 is:

5cf82d972614f73422f899f90cfce80faaarainer:~$ tar xvf backup.tgz
level21_password
level20@trainer:~$ cat level21_password
65230da2ead4ba2ed76ee2605cadcd4d

level21@trainer:~$ bunzip2 -d mybackup
level21@trainer:~$ cat mybackup.out
643b2616b33de99b179c33950970d519
```

## Tunneler

### Bastion

> Connect to the bastion host 104.131.101.182
> User: tunneler Password: tunneler SSH Port: 2222

```
$ ssh 104.131.101.182 -p2222 -l tunneler
...
ts{censored}
...
The first challenge is to forward a port or forward tunnel to view a web server on an internal network.  The address is 10.174.12.14 and it is listening on port 80.
The second challenge is to connect to the pivot host.  The address is 10.218.176.199 with user: whistler and password: cocktailparty 
```

### Browsing Websites

> Browse to http://10.174.12.14/

```
$ ssh tunneler@104.131.101.182 -p2222 -L 8000:10.174.12.14:80
```

Then open, http://localhost:8000/ and find:

```
You made your first tunnel, take this flag as a reward for your hard work ts{censored}
```

### SSH in Tunnels

> SSH through the bastion to the pivot.

```
$ ssh -J tunneler@104.131.101.182:2222 whistler@10.218.176.199
...
ts{censored}

Pivot-1:

Some things you can do:

Something is Beaconing to the pivot on port 58671-58680 to ip 10.112.3.199, can you tunnel it back?

scan for the ftp server: 10.112.3.207 user: bishop pass: geese  (Its not where you think it is, also the banner is important)

connect to pivot-2 ip: 10.112.3.12 ssh port: 22 user: crease pass: NoThatsaV

connect to ip: 10.112.3.88 port: 7000, a beacon awaits you
```

### Beacons Everywhere

> Something is Beaconing to the pivot on port 58671-58680 to ip 10.112.3.199, can you tunnel it back?

```
$ ssh -J tunneler@104.131.101.182:2222 whistler@10.218.176.199 -R 10.112.3.199:58672:127.0.0.1:444

# In new window
$ nc -nlvp 4444
...
ts{censored}
```

### Beacons Annoying

> Connect to ip: 10.112.3.88 port: 7000, a beacon awaits you

```
$ ssh -J tunneler@104.131.101.182:2222 whistler@10.218.176.199 -L 7000:10.112.3.88:7000 &
$ nc -v localhost 7000
...
I hope you like tunneling, I will send you the flag on a random port... How fast is your tunnel game?
I will send the flag to ip: 10.112.3.199 on port: 24354 in 15 seconds

# In new window
$ ssh -J tunneler@104.131.101.182:2222 whistler@10.218.176.199 -R 10.112.3.199:24354:127.0.0.1:1234 &
$ nc -v localhost 1234
...
ts{censored}
```

See writeup linked above, for the rest.
