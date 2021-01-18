---
layout: post
title: TryHackMe - Startup
---

TryHackMe [Room](https://tryhackme.com/room/startup)

## Welcome to Spice Hut!

I first enumerated the box with `nmap` and found FTP, SSH, and HTTP services running. FTP allowed anonymous login, and I could `get` and `put` files into the ftp directory. I ran `gobuster` to find if that was visible on the website, and I discovered a `/files` directory with the ftp directory within, i.e. `/files/ftp`. I dropped a reverse shell over FTP and accessed the PHP file from the website. Once connected, I upgraded to a TTY shell with Python. As user `www-data`, I found a recipe.txt file in the `/` directory along with two interesting directories: `incidents` and `vagrant`. I copied the suspicious.pcapng file from `/incidents` to the FTP folder located on the server at `/var/www/html/files/ftp`, and then used `get` to retrieve it. I opened it in Wireshark, followed a TCP stream that contained the string "vagrant", and found a plaintext password being used to try to run `sudo` as user `www-data`. That likely phished password allowed me to switch to user `lennie`. I found user.txt in his previously disallowed home directory. I checked his scripts folder to find an interesting file named planner.sh which `lennie` did not have write access to:
```sh
#!/bin/bash
echo $LIST > /home/lennie/scripts/startup_list.txt
/etc/print.sh
```

print.sh was basically empty but was writable by `lennie`. I pasted in a reverse shell one-liner, opened up another listener on my attack machine, and ran `bash planner.sh`. With that I had root and could find the final flag at `/root/root.txt`.
