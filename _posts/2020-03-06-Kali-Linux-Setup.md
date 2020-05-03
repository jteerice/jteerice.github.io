---
layout: post
title: Kali Linux Setup
---
## Setup and Initial Configuration
```
passwd root
apt update && apt upgrade
apt autoremove
dpkg-reconfigure openssh-server #change default ssh keys
```
### use systemctl to turn on services by default (on boot)
```
systemctl enable ssh
systemctl enable postgresql  # useful for metasploit
```
### turn off the water dropping sound
```
dconf write /org/gnome/desktop/sound/event-sounds "false"
```
### add a non-root user
```
adduser <user>
usermod -aG sudo <user> # give sudo permission
```
### add a bin to home
```
mkdir ~/bin
```
## Installation and Developer Tools
```
apt install xclip # for copying file contents to clipboard
apt install gedit-plugins
apt install python-pip  # python2 pip
apt install python3-pip
pip3 install pyftpdlib  # Python FTP Server library
apt install ruby-full #  gem install
```
### Docker
```
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' > /etc/apt/sources.list.d/docker.list
apt-get update
apt install docker-ce
```

## CTF Tools
### General
```
python3 -m pip install --upgrade 
git+https://github.com/Gallopsled/pwntools.git@dev3

git clone https://github.com/exiftool/exiftool.git /opt/exiftool
cd $_
perl Makefile.PL
make
make test
make install
```
### Steganography
```
apt install gimp
apt install steghide

git clone https://github.com/zed-0xff/zsteg.git /opt/zsteg 
cd $_
gem install zsteg
```
### Setup ImageMagick
```
apt install autoconf
git clone https://github.com/ImageMagick/ImageMagick.git /opt/ImageMagick
cd $_
./configure
make
```

## Reverse Engineering
```
git clone https://github.com/longld/peda.git /opt/peda
git clone https://github.com/radareorg/cutter.git /opt/cutter
```
### IDA Freeware for Linux
```
wget https://out7.hex-rays.com/files/idafree70_linux.run
mv <dir>/idafree70_linux.run /opt/ida64
cd $_ && chmod +x idafree70_linux.run
./idafree70_linux.run # go through install daemon
ln -s /opt/idafree-7.0/ida64 ./ida64
```

## Cracking and Fuzzing
### AFL
```
git clone https://github.com/google/AFL.git /opt/AFL
```
### Hashcat - to get hashcat to work in a VM
```
apt install libhwloc-dev ocl-icd-dev ocl-icd-opencl-dev pocl-opencl-icd
gunzip /usr/share/wordlists/rockyou.txt.gz
```

## Assorted
### Morse
```
git clone https://github.com/mk12/morse.git /opt/morse
    ->make
ln -s /opt/morse/bin/morse ~/bin/morse
```
### Autoclicking tool
```
apt install xdotool # for a clicker challenge
```
### Rubber Ducky
```
git clone https://github.com/hak5darren/USB-Rubber-Ducky /opt/usb_rubber_ducky
```

## Networking and Pentesting

### Dirbuster big wordlist
```
git clone https://github.com/daviddias/node-dirbuster/blob/master/lists/directory-list-2.3-big.txt /usr/share/wordlists/dirbuster/directory-list-2.3-big.txt
```
### bluto for DNS recon
```
pip install bluto  # DNS recon and Brute Forcer
```
### Impacket
```
git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket
pip install /opt/impacket
```
### Gobuster - Directory/File, DNS and VHost busting tool
```
git clone https://github.com/OJ/gobuster.git /opt/gobuster
# use: gobuster dir -u $url -w $wordlist
```
### Evil-WinRM - escalate priviledges on Windows machine
```
git clone https://github.com/Hackplayers/evil-winrm.git /opt/Evil-WinRM
gem install evil-winrm
```
### General Priviledge Escalation Scripts
```
git clone https://github.com/1N3/PrivEsc.git /opt/PrivEsc
```

### OpenLuck
```
apt install libc6-dev-i386
git clone https://github.com/heltonWernik/OpenLuck /opt/OpenLuck
cd $_
gcc OpenFuck.c -o open -lcrypto
```
### LinEnum 
```
apt install libssl-dev
git clone https://github.com/rebootuser/LinEnum.git /opt/LinEnum
```
### Download Nessus package from website - https://www.tenable.com/downloads/nessus
```
dpkg -i <package like: Nessus-8.8.0-debian6_amd64.deb>
ln -s /etc/init.d/nessusd ~/bin/nessusd
ln -s /opt/nessus/sbin/nessuscli  ~/bin/nessuscli
```

## Web
### Firefox extensions 
* **Wappalyzer**, which checks front and back end technologies on a website
* **FoxyProxy**, to configure with Burp Suite

### Setup Tor
```
echo 'deb https://deb.torproject.org/torproject.org stretch main
deb-src https://deb.torproject.org/torproject.org stretch main' > /etc/apt/sources.list.d/tor.list
wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo apt-key add -
apt update
apt install tor deb.torproject.org-keyring
```
