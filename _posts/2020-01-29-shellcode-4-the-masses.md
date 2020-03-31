---
layout: post
title: Webinar - Shellcode for the Masses
---

> Shellcode for the Masses - Presented by John Hammond - EH-Net - Jan 29, 2020

---

## Ethical Hacking Breakdown
* Pentesting
  * Network
  * WebApp
  * Mobile
* Red Teaming
  * Physical
  * SE
* Forensics
  * System, OS
  * Network
* Incident Response
  * Threat Hunting
  * Adv Sim
* Dev
  * **Exploit**
  * RE

---

## What is Shellcode?
* Code that will return a remote shell when executed. The meaning has evolved, it now represents any byte code that will be inserted into an exploit to accomplish a desired task.
* A small chunk of code used in the payload in the exploitation of a software vulnerability

## What is Binary exploitation?
* The process of subverting a compiled application such that it violates some trust boundary

![pic](/images/webinar/s4tm/1.png)

![pic](/images/webinar/s4tm/2.png)

## Why do we care?
* Vulnerable programs can be abused
* Understanding security mitigations
        
![pic](/images/webinar/s4tm/3.png)

![pic](/images/webinar/s4tm/4.png)


## How do we learn this stuff?
* LINUX PRACTICE - exploit.education
* WINDOWS PRACTICE - VulnServer
* GENERAL PRACTICE - Exploit-DB
* HELPFUL READING - The Shellcoder's Handbook


## Demos
* shell storm - see other people's shell code for many architectures
* shellcraft (comes with pwntools)
* Immunity Debugger for Windows

```
from boofuzz import *

host = "192.168.205.136"
port = 9999

session = Session(target = Target(connection=SocketConnection(host,port, proto="tcp")))
....
```