---
layout: post
title: TryHackMe - Anthem
---

This is a simple box that doesn't require actual exploitation located (here)[https://tryhackme.com/room/anthem].

## Website Analysis
Run a basic `nmap <ip>` to discover port a website on port 80 and an RDP service on port 3389. Check /robots.txt to find a password and some "hidden" directories: /bin, /config, /umbraco, /umbraco_client. Be sure to check words you don't recognize as they may be services or CMS's you haven't heard of. On the main page of the site, the domain is clearly listed as anthem.com. Check the first blog post and identify who the poem written is about, as they are both the administrator of the site and a character from a nursery rhyme. Check the other blog post to find the format of the usernames for emails. Jane Doe becomes JD@anthem.com. Knowing this, determine the administrator's username and email. 

## Spot the flags
If you were forwarding traffic through Burp the whole time, navigating to all the pages (happy path) would build a tree you could search through for the flag format `THM{.*}`. Else, just go to every page on the site (including those that are mentioned in /robots.txt) and check the source to find the flags.

## Final Stage
Use the username of the administrator with the password from /robots.txt to RDP into the server. The user has a flag on their desktop. Then check for hidden folders; there is a hidden backup folder in C:\ that contains a password file whose permissions you have to change to allow you to view. Using that password, open an Administrator command prompt or simply click on the C:\Users\Administrator directory in the File Explorer. Check inside for the final flag. 
