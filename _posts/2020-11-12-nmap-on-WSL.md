---
layout: post
title: Running Nmap using WSL2
---

## What
Nmap ("Network Mapper") is a free and open source (license) utility for network discovery and security auditing. Many systems and network administrators also find it useful for tasks such as network inventory, managing service upgrade schedules, and monitoring host or service uptime.

## Why
On WSL, there have been problems with opening sockets which leads to many traditional Linux networking tools like Nmap failing.

## Fix
The current workaround is to run Nmap.exe for Windows through an alias on WSL. 

1. Download and run the [latest stable release self-installer for Windows](https://nmap.org/download.html)
2. Put `alias nmap='"/mnt/c/Program Files (x86)/Nmap/nmap.exe"'` in your .bashrc or .profile 
