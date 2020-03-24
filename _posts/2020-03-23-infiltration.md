---
layout: post
title: Hack The Box - Infiltration
---

> Can you find something to help you break into the company 'Evil Corp LLC'. Recon social media sites to see if you can find any useful information.

---

### LinkedIn
Website: https://www.e-corp-usa.com/
* E Corp is the leading global provider of corporate strategy, philanthropy, sustainability, and growth.
* Partner with Apple for iGlass
* host Google's gmail servers at Evil Corp Datacenter
* rewriting the Windows 11 kernel for Microsoft

### Twitter

Alia Mccarty - @mccarty_alia
* Internal Communications Designer at Evil Corp LLC
* secret nerd, loves role playing - it's all about communication!

![twitter](/images/htb/infiltration/1.png)

### e-corp-usa.com

Nothing interesting exposed.

### Instagram

Eryn Mcmahon - eryn_mcmahon12

![instagram](/images/htb/infiltration/2.png)
The code is on the badge. I inspect the element of the image, to find the [```src```](https://scontent-ort2-1.cdninstagram.com/v/t51.2885-15/fr/e15/s1080x1080/53565136_1015310385333737_784366953763073280_n.jpg?_nc_ht=scontent-ort2-1.cdninstagram.com&_nc_cat=105&_nc_ohc=vn1egg0zcVQAX8YBtXc&oh=f7d22d756b81ee0709df2724bdb89168&oe=5E9EA182) so I can open it in its own tab and zoom in to read it better.

HTB{Y0ur_Enum3rat10n_{censored}_Y0ung_0ne}