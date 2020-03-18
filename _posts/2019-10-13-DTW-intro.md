---
layout: post
title: Defend The Web - Intro 1-12
---

## Intro 1

![intro](/images/defend/1.png)

## Intro 2

![2_1](/images/defend/2_1.png)

![2_2](/images/defend/2_2.png)

## Intro 3 / Javascript

Looking through the source code, I come across some JavaScript.

```javascript
$(function(){
	$('.level form').submit(function(e){
		e.preventDefault();
		if(document.getElementById('password').value == correct) {
			document.location = '?pass=' + correct;
		} else { alert('Incorrect password') }
	})
})
```
The password field input value is checked against a variable called ```correct```. Searching the source, we find it.

```javascript
var correct = '6d6972378d';
```

## Intro 4

I searched the source code and found the following line:

```html
 <input type="hidden" name="passwordfile" id="passwordfile" value="../../extras/playground/9d2K4Fw.json" maxlength="" placeholder="" class="u-full-width" />
 ```

Navigating to ```https://defendtheweb.net/extras/playground/9d2K4Fw.json``` we find our solution.

![4](/images/defend/4.png)

## Intro 5

Check source again:

```javascript
var pass;
pass=prompt("Password","");
if (pass=="741fc86ee2") {
    window.location.href="?password=741fc86ee2";
}

```

Simply refresh the page and enter ```741fc86ee2```.

## Intro 6

![6](/images/defend/6.png)

![6_2](/images/defend/6_2.png)

It appears we need to add "emberfire" as a new option for username. Using dev tools, I edit the value of the jTman option so that it will submit "emberfire".

![6_3](/images/defend/6_3.png)

## Intro 7

The prompt is: "You couldn’t even find the password using a search engine as search bots have been excluded." So let's check robots.txt.

Go to ```https://defendtheweb.net/robots.txt``` and see:
```
User-agent: *
Allow: /
Disallow: /help/contact
Disallow: /profile/
Disallow: /extras/
Disallow: /extras/playground/jf94jhg03.txt

User-agent: Mediapartners-Google
Disallow:
```

Then go to ```https://defendtheweb.net/extras/playground/jf94jhg03.txt``` and see:
```
visualmaster
0ff735d018
```

## Intro 8

Check source:
```html
<input type="hidden" name="file" id="file" value="../../extras/playground/48w3756.txt" maxlength="" placeholder="" class="u-full-width" />
```

At ```https://defendtheweb.net/extras/playground/48w3756.txt``` we get some binary:
```
01100010 01110101 01110010 01101110 01100010 01101100 01100001 01111010 01100101 
01001100 01110000 00111001 01000101 01001101 00110010 00110111 01000111 01010010
```

```shell
$ bin2ascii "01100010 01110101 01110010 01101110 01100010 01101100 01100001 01111010 01100101"
burnblaze
$ bin2ascii "01001100 01110000 00111001 01000101 01001101 00110010 00110111 01000111 01010010"
Lp9EM27GR
```

## Intro 9

Find the hidden input field and change admin email in the email2 field. Then the login details are presented.

![9](/images/defend/9.png)

## Intro 10 / Javascript

![10](/images/defend/10.png)

Check source:
```javascript
document.thecode = 'code123';
$(function(){
	$('.level form').submit(function(e){
		e.preventDefault();
		if(document.getElementById('password').value == document.thecode) {
			document.location = '?pass=' + document.thecode;
		} else {
			alert('Incorrect password')
		}
	})
});
```
And further down:
```javascript
document['thecode'] = '\x31\x61\x36\x31\x37\x65\x39\x38\x38\x62'
```

I use the console to see what the hex evaluates to:

![10_1](/images/defend/10_1.png)


## Intro 11 / Javascript

Check source:
```html
<pre><div class='center'>The password is: 3f3f7206fb</div></pre>
```

The url is different this time: ```https://defendtheweb.net/playground/intro11?input=``` and when we press the Log In button, the URL changes to ```?input=password```. I thought perhaps the challenge would involve changing the url to submit the password, but it appears to be a red herring. Submitting the password from the html above works.

## Intro 12

The prompt says: "This one is simple, the password is 1c63129ae9db9c60c3e8aa94d3e00495". This looks like an md5 hash, so let's run hashcat with rockyou to see if we get an easy answer.
```shell
$ hashcat -m 0 -a 0 -o cracked.txt hashfile /usr/share/wordlists/rockyou.txt --force
$ cat cracked.txt
1c63129ae9db9c60c3e8aa94d3e00495:1qaz2wsx
```
