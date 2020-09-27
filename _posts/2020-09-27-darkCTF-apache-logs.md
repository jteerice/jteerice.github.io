---
layout: post
title: DarkCTF - Web/Apache Logs
---

This is my solution to DarkCTF's Web/Apache Logs challenge. First, download and unzip the folders until you find `logs.ctf` within.

```
$ file logs.ctf
logs.ctf: ASCII text, with very long lines
$ head -n 10 logs.ctf
find the flag! khkhkh
192.168.32.1 - - [29/Sep/2015:03:28:43 -0400] "GET /dvwa/robots.txt HTTP/1.1" 200 384 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:43 -0400] "GET /favicon.ico HTTP/1.1" 404 503 "http://192.168.32.134/dvwa/robots.txt" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:48 -0400] "GET /dvwa/robots.txt HTTP/1.1" 304 209 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:51 -0400] "GET /dvwa HTTP/1.1" 301 557 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:51 -0400] "GET /dvwa/ HTTP/1.1" 302 478 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:51 -0400] "GET /dvwa/login.php HTTP/1.1" 200 985 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:51 -0400] "GET /dvwa/dvwa/images/login_logo.png HTTP/1.1" 200 13170 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:51 -0400] "GET /dvwa/dvwa/css/login.css HTTP/1.1" 200 671 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:28:53 -0400] "POST /dvwa/login.php HTTP/1.1" 302 451 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
```

We have a log file from an Apache server. `dvwa` is likely the Damn Vulnerable Web Application. The first hit to robots.txt makes me think the website is being scanned. Later, all the requests to the login form made me think it was being brute-forced:
```
192.168.32.1 - - [29/Sep/2015:03:31:10 -0400] "POST /dvwa/login.php HTTP/1.1" 302 451 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:10 -0400] "GET /dvwa/login.php HTTP/1.1" 200 1004 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:11 -0400] "POST /dvwa/login.php HTTP/1.1" 302 451 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:11 -0400] "GET /dvwa/login.php HTTP/1.1" 200 1004 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:11 -0400] "POST /dvwa/login.php HTTP/1.1" 302 451 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:11 -0400] "GET /dvwa/login.php HTTP/1.1" 200 1004 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:11 -0400] "POST /dvwa/login.php HTTP/1.1" 302 451 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:11 -0400] "GET /dvwa/login.php HTTP/1.1" 200 1004 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:24 -0400] "POST /dvwa/login.php HTTP/1.1" 302 452 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:31:24 -0400] "GET /dvwa/login.php HTTP/1.1" 200 1004 "http://192.168.32.134/dvwa/login.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
```

I did `grep` for various strings relating to flags and DarkCTF, but found nothing. Since the file wasn't that long, I ended up skimming over it. I eventually found a couple lines that stood out.

```
192.168.32.1 - - [29/Sep/2015:03:37:34 -0400] "GET /mutillidae/index.php?page=user-info.php&username=%27+union+all+select+1%2CString.fromCharCode%28102%2C+108%2C+97%2C+103%2C+32%2C+105%2C+115%2C+32%2C+83%2C+81%2C+76%2C+95%2C+73%2C+110%2C+106%2C+101%2C+99%2C+116%2C+105%2C+111%2C+110%29%2C3+--%2B&password=&user-info-php-submit-button=View+Account+Details HTTP/1.1" 200 9582 "http://192.168.32.134/mutillidae/index.php?page=user-info.php&username=something&password=&user-info-php-submit-button=View+Account+Details" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:37:59 -0400] "GET /mutillidae/index.php?page=register.php HTTP/1.1" 200 8921 "http://192.168.32.134/mutillidae/index.php?page=html5-storage.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:38:46 -0400] "GET /mutillidae/index.php?csrf-token=&username=CHAR%28121%2C+111%2C+117%2C+32%2C+97%2C+114%2C+101%2C+32%2C+111%2C+110%2C+32%2C+116%2C+104%2C+101%2C+32%2C+114%2C+105%2C+103%2C+104%2C+116%2C+32%2C+116%2C+114%2C+97%2C+99%2C+107%29&password=&confirm_password=&my_signature=&register-php-submit-button=Create+Account HTTP/1.1" 200 8015 "http://192.168.32.134/mutillidae/index.php?page=register.php" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:39:05 -0400] "GET /fdsfdsa HTTP/1.1" 404 501 "-" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
192.168.32.1 - - [29/Sep/2015:03:39:46 -0400] "GET /mutillidae/index.php?page=client-side-control-challenge.php HTTP/1.1" 200 9197 "http://192.168.32.134/mutillidae/index.php?page=user-info.php&username=%27+union+all+select+1%2CString.fromCharCode%28102%2C%2B108%2C%2B97%2C%2B103%2C%2B32%2C%2B105%2C%2B115%2C%2B32%2C%2B68%2C%2B97%2C%2B114%2C%2B107%2C%2B67%2C%2B84%2C%2B70%2C%2B123%2C%2B53%2C%2B113%2C%2B108%2C%2B95%2C%2B49%2C%2B110%2C%2B106%2C%2B51%2C%2B99%2C%2B116%2C%2B49%2C%2B48%2C%2B110%2C%2B125%29%2C3+--%2B&password=&user-info-php-submit-button=View+Account+Details" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36"
```

These clearly looked like SQL Injections passed through URL parameters, so I tried several variations of `DarkCTF{SQLI}`. I then decided to decode the URL encoded characters to see what was being passed since that was the last route I saw.

```
$ function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
$ urldecode %28102%2C%2B108%2C%2B97%2C%2B103%2C%2B32%2C%2B105%2C%2B115%2C%2B32%2C%2B68%2C%2B97%2C%2B114%2C%2B107%2C%2B67%2C%2B84%2C%2B70%2C%2B123%2C%2B53%2C%2B113%2C%2B108%2C%2B95%2C%2B49%2C%2B110%2C%2B106%2C%2B51%2C%2B99%2C%2B116%2C%2B49%2C%2B48%2C%2B110%2C%2B125%29%2C | tr -d "(+)" | tr "," " "
102 108 97 103 32 105 115 32 68 97 114 107 67 84 70 123 53 113 108 95 49 110 106 51 99 116 49 48 110 125
$ python
>>> a = "102 108 97 103 32 105 115 32 68 97 114 107 67 84 70 123 53 113 108 95 49 110 106 51 99 116 49 48 110 125"
>>> b = a.split()
>>> res = ""
>> for x in b:
...     res += chr(int(x))
...
>>> print res
flag is DarkCTF{5ql_1nj3ct10n}
```
