---
layout: post
title: SSH_Inception
---

## Login
On EDURange after scenario is provisioned, use the Login and Password in the Scenario Information section and the Public IP Address of the first instance, nat, to begin the challenge.

```bash
$ ssh zheller@3.92.162.111 # enter 2fff0a89
```
## nat
```bash
Welcome to SSH Inception. The goal is to answer all questions by exploring the local network, the subnet 10.0.0.0/27. You are currently at the NAT Instance.
Your journey will begin when you login into the next host:     
    ssh 10.0.0.5

For every host you login to you will be greeted with instructions. Each host will give you a list of useful commands to solve each challenge. Use man pages to help find useful options for commands.

Every stop has a file named 'secret' with a code inside. Submit these codes on     EDURange to verify your progress.

Helpful commands: ssh, help, man

zheller@nat:~$ ssh 10.0.0.5 # enter 2fff0a89
```
## starting_line
```bash
"It's a week the first level down. Six months the second level down, and... the third level..."

Go a level deeper. You will find the next host at 10.0.0.7.
The trick is that the ssh port has been changed to 123. Good luck!

zheller@starting-line:~$ cat secret
7d647191
zheller@starting-line:~$ ssh 10.0.0.7 -p 123 # enter 2fff0a89
```
## first_stop
```bash
"I'll tell you a riddle. You're waiting for a train, a train that will take you far away. You know where you hope this train will take you, but you don't know for sure."

You found it. Well done. The next dream machine lies just a few addresses higher on your subnet. Use nmap to find the next closest machine.  The subnet address was mentioned in an earlier message, or you can calculate it for yourself using 'ipcalc'

Helpful commands: ifconfig, nmap, ssh, ipcalc
zheller@first-stop:~$ cat secret
ba94516a
```
### Enumeration
```bash
zheller@first-stop:~$ nmap 10.0.0.0/24
```
Refined Output:

10.0.0.5:22 - ssh

10.0.0.10:22 - ssh

10.0.0.13:22 - ssh

10.0.0.14:21 - ftp

10.0.0.16:22 - ssh

10.0.0.17:22 - ssh

10.0.0.19:666 - doom

```bash
zheller@first-stop:~$ ssh 10.0.0.10 # enter 2fff0a89
```
## second_stop
```bash
"Remember, you are the dreamer, you build this world."

SSH a level deeper if you dare. This time no password is provided. However, you might find the file id_rsa helpful...
zheller@second-stop:~$ cat secret
7fd0c744
zheller@second-stop:~$ ssh -i id_rsa 10.0.0.13
```
## third_stop
```bash
"Do not try and bend the spoon. That's impossible. Instead... only try to realize the truth."

Someone incepted the password for the next stop in one of these directories.
It sure would take a long time to look through all of them. There has to be a better way...

Even once you have the credentials (which are correct), you might have trouble logging into the Forth Stop. Perhaps they are blocking your IP? 

zheller@third-stop:~$ cat secret
d0ae1433
zheller@third-stop:~$ find ./ | grep -r pass
dir52/file.txt:to login as zheller at the ip address 10.0.0.16 use the password d63881f1
```
Since IP is blocked, I close out this SSH session in 10.0.0.13 and am able to ssh into 10.0.0.16 from 10.0.0.10.
```bash
zheller@second-stop:~$ ssh 10.0.0.16 # enter d63881f1
```
## fourth_stop
```bash
"It's been six hours. Dreams move one... one-hundredth the speed of reality, and dog time is one-seventh human time. So y'know, every day here is like a minute. It's like Inception, Morty, so if it's confusing and stupid, then so is everyone's favorite movie."

There is an ftp server on the network. Find some useful credentials there to run decryptpass to get your next password. If you can make nmap more aggressive it may be easier to learn how to log in to the ftp server.

(The file on the ftp server will give you credentials to use when running
decryptpass. The files in this directory will not help you get to the ftp server.)
Helpful commands: nmap, ftp, help, man

Helpful hint: When connected to the ftp interpreter, type '?' for a list of available commands.
zheller@fourth-stop:~$ cat secret
401f200c
```
We know 10.0.0.14 has port 21 exposed with an ftp service running.

```bash
zheller@fourth-stop:~$ ftp 10.0.0.14
Connected to 10.0.0.14.
220 (vsFTPd 3.0.3)
Name (10.0.0.14:zheller): zheller
530 This FTP server is anonymous only.
Login failed.
```
Reading about [anonymous FTP](https://www.webopedia.com/TERM/A/anonymous_FTP.html), I learned that you can use the username *anonymous* or *ftp* when prompted for username and use anything as your password.

```bash
zheller@fourth-stop:~$ ftp 10.0.0.14
Connected to 10.0.0.14.
220 (vsFTPd 3.0.3)
Name (10.0.0.14:zheller): ftp
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-r--r--r--    1 0        0              61 Mar 03 16:16 hint       226 Directory send OK.
ftp> get hint
local: hint remote: hint
200 PORT command successful. Consider using PASV.
150 Opening BINARY mode data connection for hint (61 bytes).       226 Transfer complete.
61 bytes received in 0.00 secs (1.5309 MB/s)
ftp> 221 Goodbye.
zheller@fourth-stop:~$ cat hint
ip:                  10.0.0.17
decryption_password: v3fujUNK
zheller@fourth-stop:~$ ./decrypt_password
enter aes-256-cbc decryption password:
6230d3e4
zheller@fourth-stop:~$ ssh 10.0.0.17 # enter 6230d3e4
```
## fifth_stop
"The ecstasy that blooms in synapses is Paprika-brand milk fat! 5% is the norm. The safety net of the ocean is nonlinear, even with what crabs dream of! Lets go!"

Decode the file 'betcha_cant_read_me' to find your way to the ultimate challenge... SATAN'S PALACE

zheller@fifth-stop:~$ cat secret
f2f39010
zheller@fifth-stop:~$ cat betcha_cant_read_me | base64 -d
You found me. Good job. The next challenge will not be so easy. You will find Satans Palace on the host with a certain open port. The most evil open port. SSH to that port with the password 'c8da368f'. The final treasure awaits... maybe you can steal it, without ever going in...
zheller@fifth-stop:~$ ssh 10.0.0.19 -p 666 ls # enter c8da368f
zheller@10.0.0.19's password:
secret
## satans_palace
zheller@fifth-stop:~$ ssh 10.0.0.19 -p 666 cat secret
zheller@10.0.0.19's password:
Permission denied, please try again.
zheller@10.0.0.19's password:
ZLKDOXQP VLR XOB QEB PPE FKZBMQFLK JXPQBO. Ebob fp vlro mollc: cyy9ab31
```
I use my rotsolver.sh script on my home machine here:
```
$ rotsolver "ZLKDOXQP VLR XOB QEB PPE FKZBMQFLK JXPQBO. Ebob fp vlro mollc: cyy9ab31" | grep proof
CONGRATS YOU ARE THE SSH INCEPTION MASTER. Here is your proof: fbb9de31 ; ROT23
```
QED

