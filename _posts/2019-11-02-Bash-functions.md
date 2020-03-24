---
layout: post
title: bashrc for Debian in WSL
---

I run Debian in Windows Subsystem for Linux (WSL), and I wanted to make a post about my setup and give an example bashrc. I find opening and manipulating files on Debian with Windows programs to be super neat. From the Debian side, your Windows filesystem can be found in the ```/mnt``` directory.

If you'd like to copy my setup, first enable WSL by opening PowerShell as Administrator and running:
```ps
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
After restarting, download [Debian for WSL](https://www.microsoft.com/store/productId/9MSVKQC78PK6) and the [Windows Terminal (Preview)](https://www.microsoft.com/store/productId/9N0DX20HK701) app. The normal Debian terminal that comes with the download is minimal and doesn't have some QoL configuration options or tabs. The terminal app has tabs and you can open any terminal emulator you have installed (e.g. PowerShell, cmd), which keeps your taskbar clearer.

``` bash
######
notepad(){
	/mnt/c/Windows/notepad.exe $1
}
paint(){
	/mnt/c/Windows/System32/mspaint.exe $1
}
sublime(){
	/mnt/c/Program\ Files/Sublime\ Text\ 3/sublime_text.exe $1
}
alias subl='sublime'
######

# make directory and enter it
mcd()
{
    test -d "$1" || mkdir "$1" && cd "$1"
}

#go up x directories
# (c) 2007 stefan w. GPLv3          
function up {
ups=""
for i in $(seq 1 $1)
do
        ups=$ups"../"
done
cd $ups
}

# copy file contents to clipboard
clip(){
	xclip -sel c < $1
}

#Search Forward through bash command history (Ctrl-S)
stty -ixon

######
# this is for binary and ascii conversions
# source: https://unix.stackexchange.com/questions/98948/ascii-to-binary-and-binary-to-ascii-conversion-tools
chrbin() {
	echo $(printf \\$(echo "ibase=2; obase=8; $1" | bc))
}

ordbin() {
	a=$(printf '%d' "'$1")
	echo "obase=2; $a" | bc
}

ascii2bin() {
    echo -n $* | while IFS= read -r -n1 char
    do
        ordbin $char | tr -d '\n'
        echo -n " "
    done
}

bin2ascii() {
    for bin in $*
    do
        chrbin $bin | tr -d '\n'
    done
}
######
```