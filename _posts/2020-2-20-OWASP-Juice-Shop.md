---
layout: post
title: OWASP Juice Shop - 1 Star Solutions
---

## Confidential Document
### Access a confidential document.
Navigate to About Us page, where there is a link to terms of use on FTP server: http://10.10.50.111/ftp/legal.md?md_debug=true.

Go to http://10.10.50.111/ftp/
![ftp site]({{ site.baseurl }}/images/resources/8dd98f9a6ce542909f62ee1661e1044f.png)

Download acquisitions.md
![acquisitions.md]({{ site.baseurl }}/images/resources/7434f92b2b924277beed5cea2512c942.png)

Also, downloaded incident-support.kdbx for cracking.

```$ keepass2john incident-support.kdbx | cut -d ":" -f 2 > keepass.hash```
## DOM XSS
### Perform a DOM XSS attack with ```<iframe src="javascript:alert(`xss`)">```.
Run alert in search field.
## Error Handling
### Provoke an error that is not very gracefully handled.
Try to access a non-existent file in the ftp server: http://10.10.50.111/ftp/bla
![d3a7f48567c58049c323cd9147b720e5.png]({{ site.baseurl }}/images/resources/5e06c3e0cf764c58b9d7a3a6f95916f2.png)

## Missing Encoding
### Retrieve the photo of Bjoern's cat in "melee combat-mode".
Navigate to http://localhost:3000/#/photo-wall
One image isn't loading, inspect it with dev tools.
There is a failed request in the Network tab: ```http://localhost:3000/assets/public/images/uploads/%F0%9F%98%BC-#zatschi-#whoneedsfourlegs-1572600969477.jpg```
The hashtags are restricted characters (HTML anchors), so replace them with the URL encoding %23
http://localhost:3000/assets/public/images/uploads/%F0%9F%98%BC-%23zatschi-%23whoneedsfourlegs-1572600969477.jpg

![33d713d9e6162a8f1e5e548993149fb0.png]({{ site.baseurl }}/images/resources/8efcc773cec44852b8738ce9e98e0d5b.png)

See: https://www.w3schools.com/tags/ref_urlencode.ASP

## Outdated Whitelist
### Let us redirect you to one of our crypto currency addresses which are not promoted any longer.

In Your Basket during checkout, we see the Other payment options for donations. Since bitcoins are most likely for donations, we inspect the donation and merchandise options still available. Several of them use the format: ```localhost:3000/redirect?to=<site>```
Searching through the HTML there doesn't appear to be any buttons commented out. However, in main-es2015.js, there are several redirects (thanks Ctrl-F) which we can view at http://localhost:3000/main-es2015.js. I first searched for bitcoin which had a lot of results; then I checked "redirect?to" in the file.
![531b88431546dec4df3806da4b0cc363.png]({{ site.baseurl }}/images/resources/d913fcc56876459f8bbcdcf5ebc9cb2c.png)

Follow any link, but to get success to trigger you need to redirect through the site, i.e. ```localhost:3000/redirect?to=https://blockchain.info/address/1AbKfgvw9psQ41NbLi8kufDQTezwG8DRZm```

## Privacy Policy
### Read our privacy policy.

![e427b90d637263c6beaf4f4aa1d6c92b.png]({{ site.baseurl }}/images/resources/fd8aa56eaf5547d2ab25eb96b272f9cd.png)

## Reflected XSS
### Perform a reflected XSS attack with ```<iframe src="javascript:alert(`xss`)">```.
Submit the iframe to the Track Orders field: http://localhost:3000/#/track-result?id=%3Ciframe%20src%3D%22javascript:alert(%60xss%60)%22%3E

## Repetitive Registration
### Follow the DRY principle while registering a user.

While registering a user, once the Password and Repeat Password fields match change the initial password and register the account.

## Score Board
### Find the carefully hidden 'Score Board' page.
Navigate to http://10.10.50.111/#/score-board

## Zero Stars
### Give a devastating zero-star feedback to the store.
Delete disabled field on Submit button.
![cd2c7463fe46b3a8bcb974f8b8aa2d81.png]({{ site.baseurl }}/images/resources/f9bf26e11f5f449bb3f06a727e7b9429.png)

![5d04614364614c29cf5d18218a1cffa0.png]({{ site.baseurl }}/images/resources/d782dd318efd47f5ac501c900df116df.png)

![fec9524963e1673d475f44d67a010d0d.png]({{ site.baseurl }}/images/resources/42d69c44b3d3474ebf5595a243eb9c44.png)
