---
layout: post
title: Bash functions and aliases
---

``` bash
# notepad for Windows Subsystem for Linux
notepad(){
	/mnt/c/Windows/notepad.exe $1
}

# make directory and enter it
mcd()
{
    test -d "$1" || mkdir "$1" && cd "$1"
}

# go up x directories
# (c) 2007 stefan w. GPLv3          
function up {
ups=""
for i in $(seq 1 $1)
do
        ups=$ups"../"
done
cd $ups
}

# Search Forward through bash command history (Ctrl-S)
stty -ixon

# copy file contents to clipboard
clip(){
xclip -sel c < $1
}
```