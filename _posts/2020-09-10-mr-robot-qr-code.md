---
layout: post
title: eps1.91_redwheelbarr0w.txt - QR Code Solution
---

There is a QR code on a page of the book *eps1.91_redwheelbarr0w.txt*. I scanned the QR Code with my phone and it directed me to [conficturaindustries.com](https://www.conficturaindustries.com).

![qr](/images/red_wheelbarrow/QR.JPG)

The website is designed to look like an old Geocities site. I believe it's a part of the greater *MR. ROBOT* ARG, and not so much a self-contained puzzle related to the rest of the journal. The previous challenge explicitly said the next message would be in the word search. But it still looked interesting, so I gave it a shot.

I clicked around the page, read the source code (`Ctrl-U`), and checked the developer console (`F12`). The site has a few key elements.
* A Latin reference: Confictura is Latin for imagination.
* A Confucius quote: "Our greatest glory is not in never falling, but in rising every time we fall."
* Broken image links: 
	```html
	<img src="img/image_confictura01.jpg" alt="image_confictura01">
	<img alt="image_bcyufvmducwkydszpwn" src="img/image_bcyufvmducwkydszpwn.jpg">
	<img src="img/image_productmenu.jpg" alt="image_productmenu">
	```
	* Note: We cannot access /images or /img on the server.
* A counter:
	```html
    <!-- COUNTER -->
    <span id="a">
	    <img src="images/0.gif">
	    <img src="images/0.gif">
	    <img src="images/0.gif">
	    <img src="images/0.gif">
	    <img src="images/3.gif">
	    <img src="images/4.gif">
	    <img src="images/2.gif">
    </span>
    <!-- COUNTER -->
    ```
* A minified JS file named `c.js`, which I unminify here:
	```js
	"use strict";
	$(function () {
	    function t(t) {
	        (a = !1),
	            $.ajax({
	                url: "check.php",
	                type: "POST",
	                data: { a: t, b: "" },
	                success: function (e) {
	                    e.response &&
	                        (function (t, e) {
	                            "string" == typeof e && e.indexOf("r") > 0
	                                ? window.location.reload(!0)
	                                : ($("#a").replaceWith(
	                                      '<form id="f" method="POST"><input type="text" class="i" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></input><input type="submit" style="position: absolute; left: -9999px"/></form>'
	                                  ),
	                                  $(".i").focus(),
	                                  (function (t) {
	                                      $("#f").submit(function (e) {
	                                          e.preventDefault();
	                                          var a = $(".i").val();
	                                          !(function (t, e) {
	                                              $.ajax({
	                                                  url: "check.php",
	                                                  type: "POST",
	                                                  data: { a: t, b: e },
	                                                  success: function (t) {
	                                                      window.location.reload(!0);
	                                                  },
	                                                  error: function (t) {},
	                                              });
	                                          })(t, a);
	                                      });
	                                  })(t));
	                        })(t, e.response),
	                        (a = !0);
	                },
	                error: function (t) {
	                    a = !0;
	                },
	            });
	    }
	    var e = null,
	        a = !1;
	    $.ajax({
	        url: "c.php",
	        cache: !1,
	        type: "GET",
	        dataType: "html",
	        success: function (t) {
	            var e = t;
	            $("#a").html(e), (a = !0);
	        },
	    }),
	        $("#a")
            .on("touchstart click", "> *", function (n) {
                if ((n.stopPropagation(), n.preventDefault(), a && !n.handled)) {
                    var o = parseInt($(this).attr("src")[7]),
                        c = "",
                        i = "images/" + (o = o < 9 ? o + 1 : 0) + ".gif";
                    $(this).attr("src", i),
                        e && clearTimeout(e),
                        (e = setTimeout(function () {
                            for (var e = 0; e < 7; e++) {
                                var a = $("#a").children()[e];
                                c += $(a).attr("src")[7];
                            }
                            t(parseInt(c));
                        }, 500)),
                        (n.handled = !0);
                }
            })
            .on("dblclick", function (t) {
                t.preventDefault();
            });
	});
	```

When reading through `c.js`, I noticed that the element with `id="a"`, our counter, is important. There is PHP (`c.php`) which grabs the html of the counter.
```js
$.ajax({
    url: "c.php",
    cache: !1,
    type: "GET",
    dataType: "html",
    success: function (t) {
        var e = t;
        $("#a").html(e), (a = !0);
    },
})
```
There is a `check.php` file which POSTs counter data and returns `{"response":false}` if the counter is not set to the correct value.

And, there is a click handler that allows you to modify the counter.
```js
$("#a")
.on("touchstart click", "> *", function (n) {
    if ((n.stopPropagation(), n.preventDefault(), a && !n.handled)) {
        var o = parseInt($(this).attr("src")[7]),
            c = "",
            i = "images/" + (o = o < 9 ? o + 1 : 0) + ".gif";
        $(this).attr("src", i),
            e && clearTimeout(e),
            (e = setTimeout(function () {
                for (var e = 0; e < 7; e++) {
                    var a = $("#a").children()[e];
                    c += $(a).attr("src")[7];
                }
                t(parseInt(c));
            }, 500)),
            (n.handled = !0);
    }
})
.on("dblclick", function (t) {
    t.preventDefault();
});
```
The format of the digits in the counter is: `<img src="images/X.gif">`. The JS makes each of the seven digit images in the counter clickable. When clicked, the images are replaced with another one from the server depending on the value of the number represented in the image:  `i = "images/" + (o = o < 9 ? o + 1 : 0) + ".gif";`. Essentially, each click increments the number until `9` is clicked which resets the digit to `0`. The function `t()` is called on the assembled numbers (e.g. `0003456`) parsed into an `int`. 

I needed to find the correct counter value because it is later passed into the final AJAX request. I could've clicked all day to try to hit the necessary value, which would then trigger the replacement of the counter:
```js
$("#a").replaceWith(
  '<form id="f" method="POST"><input type="text" class="i" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></input><input type="submit" style="position: absolute; left: -9999px"/></form>'
)
```
Or, I could brute-force it. I decided to send a bunch of POST requests with an incrementing `a` parameter and a constant `b=""` parameter, à la:
```js
url: "check.php",
type: "POST",
data: { a: t, b: "" }
```
After running for quite a while, my script discovered the correct counter value: `0736565`.
```py
import requests

a = "0000000"
b = ""
success_str = 'true'

while True:
	r = requests.post("https://www.conficturaindustries.com/check.php", data={'a':a,'b':b})

	# when 'a' is wrong:		r.text = u'{"response":false}'
	# when 'a' is right, expect: 	r.text = u'{"response":true}'
	if success_str in r.text:
		print("Correct Value Found: "+ str(a))
		break

	# pad zeroes to fill 7 digits
	a = str(int(a)+1).zfill(7)

```

Entering `0736565` in the counter causes it to get replaced by the form. I thought I might've needed to brute-force this form too, but I took a step back to consider the other things I knew.

All that was left was:
* Confictura: Latin for imagination.
* A Confucius quote
* Broken Links

Looking at the links again, one broken link with a random string of characters stood out to me:
```html
<img alt="image_bcyufvmducwkydszpwn" src="img/image_bcyufvmducwkydszpwn.jpg">
```
The other image names were fairly descriptive (`image_confictura01.jpg` and `image_productmenu.jpg`) and both had their `src` and `alt` ordered the same in the tags. This led me to believe `bcyufvmducwkydszpwn` was key to solving the form.

I first tried submitting it straight which just reset the form to the counter. I then ran `bcyufvmducwkydszpwn` through my `rotsolver` tool and into [quipqiup.com](quipqiup.com) but no luck. The likeliest option was that the phrase was encrypted with a key--potentially a Vigenère cipher.

I researched the Confucius quote more deeply and the term `confictura`, and I tried a bunch of keywords that came up, e.g. `perserverance`, `glory`, but had no luck decrypting the ciphertext. I re-read the main blurb over and over:

> Confictura Industries is the company of the future. Our mission is to innovate at the speed of evolution, providing world-class service by creating and delivering the best products utilizing the newest technology, remaining true to the core values on which we were founded while revolutionizing the eco-system with unprecedented synergy, leadership, growth, and empowerment. Customer-first. Product-focused. Paradigm-changing. Confictura Industries brings you tomorrow, today. Our mission can be best summed up in the quote that has defined our vision since Day One: "Our greatest glory is not in never falling, but in rising every time we fall."

Day One: Confucius... Confucius' birthday maybe? According to Wikipedia, Confucius' Birthday is thought to be September 28, 551 BC, though is celebrated on September 10 in mainland China. 09/28/551 and 09/10/551 are 7 digits each, so I plugged them into the counter in case it would reveal additional information--it didn't. 

I googled `cipher with numeric key` and came upon a variant of the Vigenère cipher called the Gronsfeld cipher. I tried to decode `bcyufvmducwkydszpwn` using the following encryption keys: `0928551` and `0910551` to no avail. I finally tried encrypting `bcyufvmducwkydszpwn` with `0928551` and got the plaintext: `blackanddeepdesires`.

Upon entering the passcode into the form, I was taken to a site that contained the only the following line from *Alice's Adventures in Wonderland*:

> If you drink much from a bottle marked "poison" it is almost certain to disagree with you sooner or later.

I expect this line is part of the ARG, since Mr. Robot didn't have access to a computer at the time and the message isn't relevant to the conversation with the Dark Army. That's the end of this challenge.
