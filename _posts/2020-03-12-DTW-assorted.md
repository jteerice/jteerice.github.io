---
layout: post
title: Defend The Web - Assorted Challenges
---

## 24 bit

Download the file. Change the filetype and open it.

![soln](/images/defend/24bit/soln.png)


## Beach

![prompt](/images/defend/beach.png)

I first downloaded the image and ran exiftool on it. There were two fields that stuck out to me.

```shell
$ exiftool b4.jpg | egrep 'Artist|User'
Artist                          : james
User Comment                    : I like chocolate
```

First guess was the following credentials, and they worked.

Username: james
Password: chocolate

## Secure agent

![prompt](/images/defend/secure.png)

Use Burp to modify the User-Agent.

```
GET /playground/secure-agent HTTP/1.1
Host: defendtheweb.net
User-Agent: secure_user_agent
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: https://defendtheweb.net/playground/world-of-peacecraft
DNT: 1
Connection: close
Cookie: PHPSESSID=aqk872qeadbgpess902phb70qo; cookies_dismissed=0; auth_remember=409a8a38a8bff55fd6367c8e4ab0e5f50b4893f53f14731d29ac4a51b30016e1
Upgrade-Insecure-Requests: 1
Cache-Control: max-age=0
```


##  HTTP method / Intro

Prompt: Use the POST method to send the password '07fed6c363' to this page

First I tried editting the HTML with Dev Tools.

```html
<form method="POST">
<input type="password" name="password" id="password" value="07fed6c363">
</form>
```

This results in a banner saying "Invalid CSRF Token", so I tried to fix that by explicitly referencing a hidden token.
```html
<form method="POST">
<input type="password" name="password" id="password" value="07fed6c363">
<input type="hidden" name="token" id="token" value="6066c326f92de2e480e517ec86dc6cc7b919caed505247a100835919e78c9dde" maxlength="" placeholder="" class="u-full-width">
<input type="submit" value="Submit"></form>
```

I wasn't getting anywhere, so I intercepted a request from a different challenge (crypt2) to see how my requests differed.

```
POST /playground/crypt2 HTTP/1.1
Host: defendtheweb.net
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: https://defendtheweb.net/playground/crypt2
Content-Type: multipart/form-data; boundary=---------------------------37042204124855
Content-Length: 447
Origin: https://defendtheweb.net
DNT: 1
Connection: close
Cookie: PHPSESSID=aqk872qeadbgpess902phb70qo; cookies_dismissed=0; auth_remember=409a8a38a8bff55fd6367c8e4ab0e5f50b4893f53f14731d29ac4a51b30016e1
Upgrade-Insecure-Requests: 1

-----------------------------37042204124855
Content-Disposition: form-data; name="token"

1028b2dd058a6c7574df33c2e569fbff84fba502b18b5f318f19fd2f7319afa8
-----------------------------37042204124855
Content-Disposition: form-data; name="formid"

21047b51ac06cf006c2c9540f60d71a0
-----------------------------37042204124855
Content-Disposition: form-data; name="password"

shiftthatletter
-----------------------------37042204124855--
```
I simply switched the path of my POST request and the password data to the following and sent it in the Burp Repeater.

```
POST /playground/http-method HTTP/1.1
Host: defendtheweb.net
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Referer: https://defendtheweb.net/playground/http-method
Content-Type: multipart/form-data; boundary=---------------------------37042204124855
Content-Length: 442
Origin: https://defendtheweb.net
DNT: 1
Connection: close
Cookie: PHPSESSID=aqk872qeadbgpess902phb70qo; cookies_dismissed=0; auth_remember=409a8a38a8bff55fd6367c8e4ab0e5f50b4893f53f14731d29ac4a51b30016e1
Upgrade-Insecure-Requests: 1

-----------------------------37042204124855
Content-Disposition: form-data; name="token"

1028b2dd058a6c7574df33c2e569fbff84fba502b18b5f318f19fd2f7319afa8
-----------------------------37042204124855
Content-Disposition: form-data; name="formid"

21047b51ac06cf006c2c9540f60d71a0
-----------------------------37042204124855
Content-Disposition: form-data; name="password"

07fed6c363
-----------------------------37042204124855--
```

## Sid / Intro

![prompt](/images/defend/sid.png)

Edit the i3_access cookie from false to true, and you're let in.
