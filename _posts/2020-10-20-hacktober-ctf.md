---
layout: post
title: Cyber Hacktics' Hacktober CTF 2020
---

The Hacktober CTF was held Oct 16, 2020 @ 9am CDT to Oct 17, 2020 @ 9pm CDT. Over 1000 teams competed.

## Results
We solved 58 of the 65 challenges, scored 4730 points, and landed in 44th place.

![results.png](/images/ctf/cybercup2020/results.png)

## Selected Solutions

### Talking to the Dead I-IV

> We've obtained access to a server maintained by spookyboi. There are four flag files that we need you to read and submit (flag1.txt, flag2.txt, etc).
> ssh hacktober@env.hacktober.io
> Password: hacktober-Underdog-Truth-Glimpse

```
noble@heart:~$ ssh hacktober@env.hacktober.io # password: hacktober-Underdog-Truth-Glimpse
[...]

luciafer@c3c7bd493a55:~$ find / -name *flag?.txt 2>/dev/null
/home/luciafer/Documents/.flag2.txt
/home/luciafer/Documents/flag1.txt
/home/spookyboi/Documents/flag3.txt
/root/flag4.txt

luciafer@a3d72c103f14:/$ cat /home/luciafer/Documents/flag1.txt
flag{cb07e9d6086d50ee11c0d968f1e5c4bf1c89418c}
luciafer@9d60d705c926:/$ cat /home/luciafer/Documents/.flag2.txt
flag{728ec98bfaa302b2dfc2f716d3de7869f3eadcbf}
luciafer@9d60d705c926:/$ cat /home/spookyboi/Documents/flag3.txt
cat: /home/spookyboi/Documents/flag3.txt: Permission denied

luciafer@9d60d705c926:/$ find / -perm /4000 2>/dev/null
/usr/bin/umount
/usr/bin/passwd
/usr/bin/mount
/usr/bin/gpasswd
/usr/bin/su
/usr/bin/chsh
/usr/bin/newgrp
/usr/bin/chfn
/usr/local/bin/ouija
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper

luciafer@9d60d705c926:/$ # what is ouija?

luciafer@9d60d705c926:/$ /usr/local/bin/ouija
OUIJA 6.66 - Read files in the /root directory
Usage: ouija [FILENAME]
EXAMPLES:
        ouija file.txt
        ouija read.me

luciafer@9d60d705c926:/$ /usr/local/bin/ouija ../home/spookyboi/Documents/flag3.txt
flag{445b987b5b80e445c3147314dbfa71acd79c2b67}

luciafer@9d60d705c926:/$ /usr/local/bin/ouija flag4.txt
flag{4781cbffd13df6622565d45e790b4aac2a4054dc}
```


### Prefetch Perfection
> Prefetch files are another handy tool to show evidence of execution. What time was Internet Explorer opened? (GMT) Submit the flag as flag{YYYY-MM-DD HH:MM:SS}.

I downloaded WinPrefetchView and in Advanced Options changed the Prefetch Folder to the challenge folder. There was one row for IEXPLORE.EXE and two rows for IE4UINIT.EXE. In the options, switch to GMT time and grab the last run date: `5/1/2017 9:11:41 PM`. Put that into the correct format: `flag{2017-05-01 21:11:41}`.


### Past Attacks
> Knowing that it is going to be an attack against a Financial firm. What is the type of attack that is likely to happen? Enter the answer as flag{word word}.

I tried a bunch of guesses until finally landing on `flag{watering hole}`.
```
flag{data exfiltration}
flag{eternal blue}
flag{social engineering}
flag{ddos attack}
flag{ddos attacks}
flag{credential stuffing}
flag{phishing attack}
flag{ransomware attack}
flag{insider threat}
flag{insider threats}
flag{data breach}
flag{data loss}
flag{banking malware}
flag{banking trojan}
flag{insider attack}
flag{insider attacks}
flag{accidental disclosures}
flag{mega breach}
flag{whaling attack}
flag{watering hole}
```
## Evil Corp's Child 2

> The malware uses four different ip addresses and ports for communication, what IP uses the same port as https? Submit the flag as: flag{ip address}.

Unzip the file with the password `hacktober`.

Filter on: `tcp.port == 443 || udp.port == 443`

`192.168.1.91` which downloaded the malware communicates with `213.136.94.177` over port 443.

`flag{213.136.94.177}`

## Evil Corp's Child 3

> What is the localityName in the Certificate Issuer data for HTTPS traffic to 37.205.9.252?

Filter on: `ip.addr == 37.205.9.252` and search for `localityName` in the packet details. You can find it in frame 521.

```
Certificate: 3082037f30820267a003020102020900d7b06c4ce1fe0221… (id-at-commonName=Inawe0deouna.pics,id-at-organizationName=Bulloccea B.M.,id-at-localityName=Mogadishu,id-at-countryName=SO)
```

`flag{Mogadishu}`

### Remotely Administrated Evil 2

> What MYDDNS domain is used for the post-infection traffic in RATPack.pcap?

Just search for MYDDNS in the packet details. Frame 1497 contains the string: `solution.myddns.me: type A, class IN`

`flag{solution.myddns.me}`

Name: global.asimov.events.data.trafficmanager.net


### An Evil Christmas Carol 2

> What is the domain used by the post-infection traffic over HTTPS?

Filter on: `dns && ip.addr == 10.0.0.163`. Out of all the domains, vlcafxbdjtlvlcduwhga.com stands out.

`flag{vlcafxbdjtlvlcduwhga.com}`


### Red Rum

> We want you to infiltrate DEADFACE as a programmer. Thing is, they're picky about who they bring in. They want to make sure you're the real deal when it comes to programming. Generate a list of numbers 1-500. For each number divisible by 3, replace it with Red; for each number divisible by 5, replace it with Rum. For numbers divisible by both 3 AND 5, replace it with RedRum.
> nc env2.hacktober.io 5000

When you try to connect, you get the following output:
```
$ nc env2.hacktober.io 5000
DEADFACE gatekeeper: If you want to join our programmers circle, you need to show that you can at least do the basics. Send the first 500 (1 - 500) Red Rums to show you're serious. You answer should be comma-separated with no spaces.
```

This appeared to be a simple FizzBuzz challenge that didn't even require a pwntools connection to send and recieve lines. My teammate wrote a script that generated the string we needed:
```
1,2,Red,4,Rum,Red,7,8,Red,Rum,11,Red,13,14,RedRum,Red,16,17,Red,19,Rum,Red,22,23,Red,Rum,26,Red,28,29,RedRum,Red,31,32,Red,34,Rum,Red,37,38,Red,Rum,41,Red,43,44,RedRum,Red,46,47,Red,49,Rum,Red,52,53,Red,Rum,56,Red,58,59,RedRum,Red,61,62,Red,64,Rum,Red,67,68,Red,Rum,71,Red,73,74,RedRum,Red,76,77,Red,79,Rum,Red,82,83,Red,Rum,86,Red,88,89,RedRum,Red,91,92,Red,94,Rum,Red,97,98,Red,Rum,101,Red,103,104,RedRum,Red,106,107,Red,109,Rum,Red,112,113,Red,Rum,116,Red,118,119,RedRum,Red,121,122,Red,124,Rum,Red,127,128,Red,Rum,131,Red,133,134,RedRum,Red,136,137,Red,139,Rum,Red,142,143,Red,Rum,146,Red,148,149,RedRum,Red,151,152,Red,154,Rum,Red,157,158,Red,Rum,161,Red,163,164,RedRum,Red,166,167,Red,169,Rum,Red,172,173,Red,Rum,176,Red,178,179,RedRum,Red,181,182,Red,184,Rum,Red,187,188,Red,Rum,191,Red,193,194,RedRum,Red,196,197,Red,199,Rum,Red,202,203,Red,Rum,206,Red,208,209,RedRum,Red,211,212,Red,214,Rum,Red,217,218,Red,Rum,221,Red,223,224,RedRum,Red,226,227,Red,229,Rum,Red,232,233,Red,Rum,236,Red,238,239,RedRum,Red,241,242,Red,244,Rum,Red,247,248,Red,Rum,251,Red,253,254,RedRum,Red,256,257,Red,259,Rum,Red,262,263,Red,Rum,266,Red,268,269,RedRum,Red,271,272,Red,274,Rum,Red,277,278,Red,Rum,281,Red,283,284,RedRum,Red,286,287,Red,289,Rum,Red,292,293,Red,Rum,296,Red,298,299,RedRum,Red,301,302,Red,304,Rum,Red,307,308,Red,Rum,311,Red,313,314,RedRum,Red,316,317,Red,319,Rum,Red,322,323,Red,Rum,326,Red,328,329,RedRum,Red,331,332,Red,334,Rum,Red,337,338,Red,Rum,341,Red,343,344,RedRum,Red,346,347,Red,349,Rum,Red,352,353,Red,Rum,356,Red,358,359,RedRum,Red,361,362,Red,364,Rum,Red,367,368,Red,Rum,371,Red,373,374,RedRum,Red,376,377,Red,379,Rum,Red,382,383,Red,Rum,386,Red,388,389,RedRum,Red,391,392,Red,394,Rum,Red,397,398,Red,Rum,401,Red,403,404,RedRum,Red,406,407,Red,409,Rum,Red,412,413,Red,Rum,416,Red,418,419,RedRum,Red,421,422,Red,424,Rum,Red,427,428,Red,Rum,431,Red,433,434,RedRum,Red,436,437,Red,439,Rum,Red,442,443,Red,Rum,446,Red,448,449,RedRum,Red,451,452,Red,454,Rum,Red,457,458,Red,Rum,461,Red,463,464,RedRum,Red,466,467,Red,469,Rum,Red,472,473,Red,Rum,476,Red,478,479,RedRum,Red,481,482,Red,484,Rum,Red,487,488,Red,Rum,491,Red,493,494,RedRum,Red,496,497,Red,499,Rum
```
While the string was confirmed correct by the CTF admin, every attempt to send it over the line resulted in a closed connection usually with the string `Stop wasting my time.`. I tried piping it into `netcat` from a file, `echo`ing it with and without the trailing newline character, and sending it using the pwn library in a python script.

On a whim, I decided to scan the port and lo and behold I was gifted the flag.

```
root@kali:~# nmap env2.hacktober.io -p5000 -A
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-17 15:04 EDT
Nmap scan report for env2.hacktober.io (143.110.147.190)
Host is up (0.0013s latency).

PORT     STATE SERVICE VERSION
5000/tcp open  upnp?
| fingerprint-strings: 
|   DNSVersionBindReqTCP, RTSPRequest: 
|     DEADFACE gatekeeper: If you want to join our programmers circle, you need to show that you can at least do the basics. Send the first 500 (1 - 500) Red Rums to show you're serious. You answer should be comma-separated with no spaces.
|     Stop wasting my time.
|     Connection Closed.
|   GenericLines: 
|     DEADFACE gatekeeper: If you want to join our programmers circle, you need to show that you can at least do the basics. Send the first 500 (1 - 500) Red Rums to show you're serious. You answer should be comma-separated with no spaces.
|     flag{h33eeeres_j0hnny!!!}
|     Stop wasting my time.
|     Connection Closed.
|   GetRequest: 
|     DEADFACE gatekeeper: If you want to join our programmers circle, you need to show that you can at least do the basics. Send the first 500 (1 - 500) Red Rums to show you're serious. You answer should be comma-separated with no spaces.
|     Stop wasting my time.
|     Connection Closed.
|     Stop wasting my time.
|     Connection Closed.
|     Stop wasting my time.
|     Connection Closed.
|   NULL: 
|     DEADFACE gatekeeper: If you want to join our programmers circle, you need to show that you can at least do the basics. Send the first 500 (1 - 500) Red Rums to show you're serious. You answer should be comma-separated with no spaces.
|_    flag{h33eeeres_j0hnny!!!}
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port5000-TCP:V=7.80%I=7%D=10/17%Time=5F8B4050%P=x86_64-pc-linux-gnu%r(N
SF:ULL,105,"DEADFACE\x20gatekeeper:\x20If\x20you\x20want\x20to\x20join\x20
SF:our\x20programmers\x20circle,\x20you\x20need\x20to\x20show\x20that\x20y
SF:ou\x20can\x20at\x20least\x20do\x20the\x20basics\.\x20Send\x20the\x20fir
SF:st\x20500\x20\(1\x20-\x20500\)\x20Red\x20Rums\x20to\x20show\x20you're\x
SF:20serious\.\x20You\x20answer\x20should\x20be\x20comma-separated\x20with
SF:\x20no\x20spaces\.\n\nflag{h33eeeres_j0hnny!!!}\n")%r(GenericLines,12E,
SF:"DEADFACE\x20gatekeeper:\x20If\x20you\x20want\x20to\x20join\x20our\x20p
SF:rogrammers\x20circle,\x20you\x20need\x20to\x20show\x20that\x20you\x20ca
SF:n\x20at\x20least\x20do\x20the\x20basics\.\x20Send\x20the\x20first\x2050
SF:0\x20\(1\x20-\x20500\)\x20Red\x20Rums\x20to\x20show\x20you're\x20seriou
SF:s\.\x20You\x20answer\x20should\x20be\x20comma-separated\x20with\x20no\x
SF:20spaces\.\n\nflag{h33eeeres_j0hnny!!!}\nStop\x20wasting\x20my\x20time\
SF:.\nConnection\x20Closed\.\n")%r(GetRequest,165,"DEADFACE\x20gatekeeper:
SF:\x20If\x20you\x20want\x20to\x20join\x20our\x20programmers\x20circle,\x2
SF:0you\x20need\x20to\x20show\x20that\x20you\x20can\x20at\x20least\x20do\x
SF:20the\x20basics\.\x20Send\x20the\x20first\x20500\x20\(1\x20-\x20500\)\x
SF:20Red\x20Rums\x20to\x20show\x20you're\x20serious\.\x20You\x20answer\x20
SF:should\x20be\x20comma-separated\x20with\x20no\x20spaces\.\nStop\x20wast
SF:ing\x20my\x20time\.\nConnection\x20Closed\.\nStop\x20wasting\x20my\x20t
SF:ime\.\nConnection\x20Closed\.\nStop\x20wasting\x20my\x20time\.\nConnect
SF:ion\x20Closed\.\n")%r(RTSPRequest,113,"DEADFACE\x20gatekeeper:\x20If\x2
SF:0you\x20want\x20to\x20join\x20our\x20programmers\x20circle,\x20you\x20n
SF:eed\x20to\x20show\x20that\x20you\x20can\x20at\x20least\x20do\x20the\x20
SF:basics\.\x20Send\x20the\x20first\x20500\x20\(1\x20-\x20500\)\x20Red\x20
SF:Rums\x20to\x20show\x20you're\x20serious\.\x20You\x20answer\x20should\x2
SF:0be\x20comma-separated\x20with\x20no\x20spaces\.\nStop\x20wasting\x20my
SF:\x20time\.\nConnection\x20Closed\.\n")%r(DNSVersionBindReqTCP,113,"DEAD
SF:FACE\x20gatekeeper:\x20If\x20you\x20want\x20to\x20join\x20our\x20progra
SF:mmers\x20circle,\x20you\x20need\x20to\x20show\x20that\x20you\x20can\x20
SF:at\x20least\x20do\x20the\x20basics\.\x20Send\x20the\x20first\x20500\x20
SF:\(1\x20-\x20500\)\x20Red\x20Rums\x20to\x20show\x20you're\x20serious\.\x
SF:20You\x20answer\x20should\x20be\x20comma-separated\x20with\x20no\x20spa
SF:ces\.\nStop\x20wasting\x20my\x20time\.\nConnection\x20Closed\.\n");
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: bridge|general purpose
Running (JUST GUESSING): Oracle Virtualbox (98%), QEMU (93%)
OS CPE: cpe:/o:oracle:virtualbox cpe:/a:qemu:qemu
Aggressive OS guesses: Oracle Virtualbox (98%), QEMU user mode network gateway (93%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 2 hops

TRACEROUTE (using port 80/tcp)
HOP RTT     ADDRESS
1   0.16 ms 10.0.2.2
2   0.22 ms 143.110.147.190

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 79.53 seconds
```