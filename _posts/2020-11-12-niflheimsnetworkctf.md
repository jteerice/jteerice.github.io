---
layout: post
title: Niflheim Network CTF - Solutions
---

I really enjoyed this CTF, and I dug into networking logs more than I ever had previous. It involved reading through several large PCAP files, a JSON file, a CSV file, some cool background documents on APTs, and various log files. I was asked to wait to post solutions to at least December 1st, so I have. Now, here you go!

## Mailing Service

> What is the IP address of the mail server?

Filtered on smtp, and saw 172.16.3.2 was responding to requests.

## Who are you?

> What is the device id of the router?

Filtered on arp and found a Cisco_ce router. So, I then filtered on cdp, the proprietary Data Link Layer protocol for Cisco. On such packet was No 13640, and the Device ID was bifrost.

## Domains

> What is the domain name for this network? Answer format should be: domain.tld

Filtered on dns, valhalla.mead showed up in the name column.

## DC

> What is the IP address of the domain controller?

The domain controller would be responding to LDAP requests. Filtered on ldap, and I found 172.16.3.1 to be the DC.

## DC 2

> How many devices are sending data to, or receiving data from, the DC?

Went to Statistics->Endpoints, and selected Apply As Filter on 172.16.3.1. There are 17 addresses shown, including the DC.

## Proxy

> What is the IP address of the proxy?

Searched on String i9.ytimg.com due to it showing up when searching on proxy. The destination for the Client Key Exchange to it was 172.16.3.4.

## Proxy 2

> What version of the proxy software is installed?

Filtered on http.x_forwarded_for, 1.1 proxy (squid/3.5.20) in the Hypertext Transfer Protocol section.

## Who sent it?

> What email address is the source of the malicious link sent to valhalla.mead users?

I filtered on SMTP and found packet 410249 which contained a phishing email from odin.alfodr@valhalla.meed. (Note: meed instead of mead). Message contained link to click: http://draug.dk/assistance.

## Who's Got Mail?

> What user clicked the link? Answer in format: first.last

The message from the previous challenge was to baldr.odinson@valhalla.mead, so it stands to reason he was the one that clicked it. Answer: baldr.odinson

## The Favorite One

> What file was transferred to Odin's favorite son?

Baldr (at 172.16.2.2) could've downloaded the assistance file from http://draug.dk/assistance which happens to be malware: TrojanDropper:VBS/PSRunner.G!MSR, or opened it from the attachment. If you check the Data field of the MIME Multipart Media Encapsulation's application/octet-stream in packet 409487, you can see a stream of bytes. Copy as Printable Text and you'll get a Base64 encoded string: `YXNzaXN0YW5jZS5kb2M=`.

```
$ echo YXNzaXN0YW5jZS5kb2M= | base64 -d
assistance.doc
```

## Spam, or Wonderful Spam?

> To what email address(es) was the malicious link sent to? (format: first.last@mail.com,first.last@mail.com, ....)

Filtered on smtp and searched for the String "draug.dk" in the Packet details.

thor.ennilang@valhalla.mead,baldr.odinson@valhalla.mead

## What were we talking about?

> What what the subject of the email? (Case sensitive)

Need assistance!

## Money Money Money

> What was the amount and currency mentioned in the malicious email? (format: ######## currency. No commas in the number)

Part of the message reads: "I have found myself trapped in Midgard, and i need your help to get home. Please transfer 5000000 weregild at this link: http://www.draug.dk/assistance (you may need to click something to make it work)."

Answer: 5000000 weregild

## What's the package?

> What is the value of the HTTP Content-Type header for the linked file?

application/hta

## Your Mail Carrier

> What site was hosting the payload?

www.draug.dk

## Surprise!

> When the user clicked the link, what program executed the linked file? Answer in format: process.exe

I was thrown off by powershell.exe being run in the file. But the question is more asking: since the file is downloaded as application/hta, which program would default to opening it on a Windows system? Through some quick googling, I found: mshta.exe.

## MITRE

> What MITRE Tactic ID does this behavior conform to? Reference: attack.mitre.org

T1218.005, Signed Binary Proxy Execution: Mshta.

## Correlation

> What is the ip address that the malicious link reached out to?

Filtered on http and searched packet details for draug.dk.

Answer: 67.79.76.68

## Children

> After execution of the payload, what program was spawned by mshta.exe?

The assistance file uses VBScript to run a powershell command.

Answer: powershell.exe

## Error?

> Fortunately, this phishing attempt was unsuccessful. What was the exception code thrown by Data Execution Prevention when it blocked the payload?

Answer: c0000096
```
Application: powershell.exe
Framework Version: v4.0.30319
Description: The process was terminated due to an unhandled exception.
Exception Info: exception code c0000096, exception address 07F300E1
```

## Host of Sadness

> What is the hostname of the targeted machine? Answer in format: host.valhalla.mead

```
$ grep 'computer_name' winlogbeat.json | tr -d " ," | sort | uniq | cut -d ":" -f 2
| tr -d '"'
WEB.valhalla.mead
wkstn-1.valhalla.mead
wkstn-2.valhalla.mead
wkstn-3.valhalla.mead
wkstn-4.valhalla.mead
wkstn-5.valhalla.mead
wkstn-6.valhalla.mead
wkstn-7.valhalla.mead
wkstn-8.valhalla.mead
wkstn-9.valhalla.mead
```
10 options, I thought it would likely be the WEB.valhalla.mead server being compromised since it was client-facing, rather than individual users.

## Ports again? && Suspicious

> Asgardian Intelligence reports a recent spike in attacks utilizing CVE-2019-0708. What is the IP address of the machine that leveraged this exploit against a valhalla.mead machine?
> What is the port that machine that leveraged this exploit against a valhalla.mead machine is using?

The exploit is CVE-2019-0708 which uses RDP. RDP is usually on port 3389. I filtered on ip.addr == 172.16.1.81 for the web server and saw lots of connections with 76.79.75.73. I then filtered on ip.dst == 76.79.75.73 to find the port used on that machine. Starting in packet 269513, there were TCP communications on port 8888.

## What popped?

> What process spawned Powershell?

cmd.exe, if you check the json logs

## Who did it?

> For the attack chain starting with "Touring Valhalla", what APT is responsible for the attack?

HAMMERFALL - gloated in an email about stealing bank account info

## Starting Out

> What MITRE ATT&CK tactic was used for initial access?

T1566 - Phishing

## Driving the Skyline

> For the attack chain "Skyline", what APT is responsible for the attack?

MimiSec - stole PII from MySQL DB

## Who is Carmen Sandiego?

> Who was the sender of the email?

In the MSGTRK2020102102-1 log file provided, the email being sent to all the cecilio.local users is being sent by cnn_news_team@cnn.com.

## Tell me more

> What was the subject of the e-mail?

In the MSGTRK2020102102-1 log file provided, a repeated e-mail subject is "Election Cycle!"

## Unsubscribe

> What e-mail addresses was the e-mail sent to? Your answer should be in alphabetical order and comma separated with no spaces.

In the MSGTRK2020102102-1 log file provided, the same e-mail is sent to the following addresses:

```
allen_justice@cecilio.local,galen_wilkinson@cecilio.local,jeffry_diaz@cecilio.local,reid_hopper@cecilio.local,roberto_beck@cecilio.local
```

## Success?

> Was the e-mail successful in phishing someone If so, what was the domain that was visited by the user? Answer should be in the format: google.com. If you think it was unsuccessful, put in the answer: NA

I filtered on http and found files being downloaded from cnnn.com.

## What Happened?

> Did the user download a file from cnnn.com? If so, what is the file name?

In packet 8463, a user downloads the file edge_update.hta from cnnn.com.

## Testing Your Knowledge

> You successfully identified that someone at least clicked the link in the phishing e-mail. However, the e-mail was from cnn.com, and the domain was cnnn.com. This is typically done to cirumvent people's phishing training by making it look so similar. What is this technique known as? Alternatively, put in the MITRE ATT&CK technique number (TXXXX)

T1328, or typosquatting

## Compromise

> What is the IP address and hostname of the box that was compromised? Answer format: IP,hostname

In the CSV, I froze the top row with the headings and searched for all the MySQL commands. host.ip and host.name columns were very helpful: 10.0.2.3,WIN10-FIN-001.cecilio.local

## Urgent!

> Intel just came through with an update, check it out here. Based off this intel report, and that a computer interacted with the website cnnn.com, which user actually clicked the e-mail?

I just scrolled the CSV further right and found user.name to be allen_justice.

## Execution

> What is the best match for the MITRE ATT&CK tactic that was used for Execution?

T1204 - User Execution, they had to click the .hta file to run it.

## How Are You Watching Me?

> What MITRE ATT&CK tactic was used for Discovery?

There are lots of dropped packets, so I assumed portscanning was going on. Answer: T1046 - Network Service Scanning

## Wait, another?

> Use the same dataset as you did with Skyline. Did you notice there was a bit more to it? Great! What MITRE ATT&CK tactic was used for initial access?

It's another phishing attack: T1566. This series of questions is likely all to be in MSGTRK2020102100-1.

## Wait, another e-mail?

> What e-mail addresses was the e-mail sent to? Your answer should be in alphabetical order and comma separated with no spaces.

```
$ grep -oiTE '[^,]+@cecilio.local' MSGTRK2020102100-1.LOG | sort | uniq | paste -sd ,
allen_justice@cecilio.local,galen_wilkinson@cecilio.local,jeffry_diaz@cecilio.local,reid_hopper@cecilio.local,roberto_beck@cecilio.local
```

## Methodology

> What is the best match for the MITRE ATT&CK tactic that was used for Execution?

A zip is downloaded, unzipped, and then the HTA file inside must be clicked to run. This is User Execution all the way. Answer: T1204.002 (User Execution - Malicious File)

## Which One is Screaming?

> Who actually clicked the e-mail?

10.0.2.4 downloaded the zip file, and checking the all-winlogs.csv I found that computer's user to be GALEN_WILKINSON.

## Name of the Town?

> What is the domain used for this attack? Answer format: site.tld

The host in the packets is hackkerrank.com.

## Venue

> What web browser was used to access hackkerrank.com?

There are quite a few packets to look through but the HTTP GET request for /update.zip is:

```
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36 Edg/86.0.622.43\r\n
``` 

Which upon lookup is Microsoft Edge.

## Dodging

> What MITRE ATT&CK tactic was used for Defense Evasion?

The file is zipped, so I thought it would be T1027.002, Obfuscated Files or Information - Software Packing. But it is once again T1218, Signed Binary Proxy Execution.

## Scoping the Town

> What MITRE ATT&CK tactic was used for Discovery?

T1046 - Network Service Scanning
