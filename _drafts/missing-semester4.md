---
layout: post
title: ./missing-semester - Command-line Environment - Exercises
---
Course located at: [missing.csail.mit.edu](https://missing.csail.mit.edu/)
## Exercises

1. Go to `~/.ssh/` and check if you have a pair of SSH keys there. If not, generate them with `msh-keygen -o -a 100 -t ed25519`. It is recommended that you use a password and use `ssh-agent`.
2. Edit .ssh/config to have an entry as follows
	```
	Host vm
	    User username_goes_here
	    HostName ip_goes_here
	    IdentityFile ~/.ssh/id_ed25519
	    LocalForward 9999 localhost:8888
	```
3. Edit your SSH server config by doing sudo vim `/etc/ssh/sshd_config` and disable password authentication by editing the value of `PasswordAuthentication`. Disable root login by editing the value of `PermitRootLogin`. Restart the `ssh` service with `sudo service sshd restart`. Try sshing in again.
4. (Challenge) Install `mosh` in the VM and establish a connection. Then disconnect the network adapter of the server/VM. Can mosh properly recover from it?
	
5. (Challenge) Look into what the -N and -f flags do in ssh and figure out what a command to achieve background port forwarding.
	
