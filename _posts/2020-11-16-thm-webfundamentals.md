---
layout: post
title: TryHackMe - Web Fundamentals
---

Room: [Web Fundamentals](https://tryhackme.com/room/webfundamentals)

This room is designed as a basic intro to how the web works.

## Mini CTF

There's a web server running on http://10.10.32.23:8081. Connect to it and get the flags!

* GET request. Make a GET request to the web server with path /ctf/get

	`curl http://10.10.32.23:8081/ctf/get`

* POST request. Make a POST request with the body "flag_please" to /ctf/post

	`curl http://10.10.32.23:8081/ctf/post -d "flag_please"`

* Get a cookie. Make a GET request to /ctf/getcookie and check the cookie the server gives you

	With the `-c` flag, you can write the cookies to stdout if you set the filename to a single dash, "-". 
	
	`curl http://10.10.32.23:8081/ctf/getcookie -c -`

* Set a cookie. Set a cookie with name "flagpls" and value "flagpls" in your devtools and make a GET request to /ctf/sendcookie

	You can pass a cookie header with `-b` and the cookie in the format "NAME1=VALUE1; NAME2=VALUE2".
	
	`curl http://10.10.32.23:8081/ctf/sendcookie -b "flagpls=flagpls"`

