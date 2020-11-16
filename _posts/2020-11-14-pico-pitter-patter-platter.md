---
layout: post
title: picoCTF 2020 Mini-Competition - Pitter, Patter, Platters
---

## Challenge Description

'Suspicious' is written all over this disk image. Download `suspicious.dd.sda1`.

## Hints

* It may help to analyze this image in multiple ways: as a blob, and as an actual mounted disk.
* Have you heard of slack space? There is a certain set of tools that now come with Ubuntu that I'd recommend for examining that disk space phenomenon...

## Solution

I added suspicious.dd.sda1 as a data source into an Autopsy case. In the root directory was a file named suspicious-file.txt that contained the following:

```
0x00000000: 4E 6F 74 68  69 6E 67 20   74 6F 20 73  65 65 20 68    Nothing to see h
0x00000010: 65 72 65 21  20 42 75 74   20 79 6F 75  20 6D 61 79    ere! But you may
0x00000020: 20 77 61 6E  74 20 74 6F   20 6C 6F 6F  6B 20 68 65     want to look he
0x00000030: 72 65 20 2D  2D 3E 0A                                  re -->.         
```

In the Global Settings, I unchecked the hide slack files options and suspicious-file.txt-slack appeared. It contained some text that I reversed for the flag:

```
echo '}derosnec{FTCocip' | rev
picoCTF{censored}
```


