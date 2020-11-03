---
layout: post
title: TryHackMe - Intro to Python
---

Challenge Location: [TryHackMe](https://tryhackme.com/room/introtopython)

This lesson is fairly straightforward, but necessary to complete for one (or more) of the learning paths. I'm already confident with Python, so here's my solution to the challenge problem.

## Challenge Time!
You'll find a file attached to this task called encoded_flag.txt. Within this file, you will find some encoded information! This is your challenge as follows;

Using the base64 library within python. Can you decode this and retrieve the flag? Note this has been encoded a total of 15 times. Be sure to read from the file provided and the documentation for the base64 library.

```py3
import base64

file = open("encodedflag.txt","r")
encoded = file.readline()
for i in range(0,5):
    encoded = base64.b16decode(encoded)

for i in range(0,5):
    encoded = base64.b32decode(encoded)

for i in range(0,5):
    encoded = base64.b64decode(encoded)
f = open("decodedflag.txt","w")
f.write(encoded.decode())
f.close()
```
