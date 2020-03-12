---
layout: post
title: OWASP Juice Shop 9.3.1 - 1 Star Solutions
---

## Confidential Document
### Access a confidential document.
Navigate to About Us page, where there is a link to terms of use on FTP server: http://10.10.50.111/ftp/legal.md?md_debug=true.

Go to ```http://10.10.50.111/ftp/```.

![ftp site](/images/juice/ftp.png)

Download acquisitions.md

![acquisitions.md](/images/juice/acquisitions.png)

Also, downloaded incident-support.kdbx for cracking.

```console
$ keepass2john incident-support.kdbx | cut -d ":" -f 2 > keepass.hash
```

## DOM XSS
### Perform a DOM XSS attack with ```<iframe src="javascript:alert(`xss`)">```.
Run alert in search field.

## Error Handling
### Provoke an error that is not very gracefully handled.
Try to access a non-existent file in the ftp server like:

```http://10.10.50.111/ftp/bla```

![error_handling.png](/images/juice/error_handling.png)

## Missing Encoding
### Retrieve the photo of Bjoern's cat in "melee combat-mode".
Navigate to ```http://localhost:3000/#/photo-wall```.

One image isn't loading, so inspect it with dev tools. There is a failed request in the Network tab:

```http://localhost:3000/assets/public/images/uploads/%F0%9F%98%BC-#zatschi-#whoneedsfourlegs-1572600969477.jpg```

The hashtags are restricted characters (HTML anchors), so replace them with the URL encoding %23.

```http://localhost:3000/assets/public/images/uploads/%F0%9F%98%BC-%23zatschi-%23whoneedsfourlegs-1572600969477.jpg```

![cat](/images/juice/cat.png)

See: [urlencode](https://www.w3schools.com/tags/ref_urlencode.ASP)

## Outdated Whitelist
### Let us redirect you to one of our crypto currency addresses which are not promoted any longer.

In "Your Basket" during checkout, we see the "Other payment options" for donations. Since bitcoins are most likely for donations, we inspect the donation and merchandise options still available. Several of them use the format: ```localhost:3000/redirect?to=<site>```.

Searching through the HTML there doesn't appear to be any buttons commented out. However, in main-es2015.js, there are several redirects (thanks Ctrl-F) which we can view at ```http://localhost:3000/main-es2015.js```. I first searched for bitcoin which had a lot of results; then I checked "redirect?to" in the file.

![bitcoin_whitelist](/images/juice/bitcoin_whitelist.png)

Follow any link, but to get success to trigger you need to redirect through the site like so:

```localhost:3000/redirect?to=https://blockchain.info/address/1AbKfgvw9psQ41NbLi8kufDQTezwG8DRZm```

## Privacy Policy
### Read our privacy policy.

![privacy_policy](/images/juice/privacy_policy.png)

## Reflected XSS
### Perform a reflected XSS attack with ```<iframe src="javascript:alert(`xss`)">```.
Submit the iframe to the Track Orders field.

```http://localhost:3000/#/track-result?id=%3Ciframe%20src%3D%22javascript:alert(%60xss%60)%22%3E```

## Repetitive Registration
### Follow the DRY principle while registering a user.

While registering a user, once the Password and Repeat Password fields match change the initial password and register the account.

## Score Board
### Find the carefully hidden 'Score Board' page.
Navigate to ```http://10.10.50.111/#/score-board```.

## Zero Stars
### Give a devastating zero-star feedback to the store.
Delete disabled field on Submit button.

![base_field](/images/juice/base_field.png)

![disabled_parameter](/images/juice/disabled_parameter.png)

![enabled_button](/images/juice/enabled_button.png)
