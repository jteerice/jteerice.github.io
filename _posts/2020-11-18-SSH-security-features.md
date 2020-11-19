---
layout: post
title: DigitalOcean - Utilizing Security Features in SSH
---

## What is SSH

* Secure shell
* Protocol for creating encrypted communication channels between two networked hosts

## What is OpenSSH

* The standard tool for remote management of *Nix systems from servers to embedded devices to network devices (is now supported by Windows)
* Active development happening on OpenBSD version, then ported to Portable OpenSSH

## The Pieces

* SSH Server
  * Listens on the network for incoming SSH requests, authenticates them and provides a terminal
* SSH Clients
  * Used to connect to your remote device, e.g. Putty, ssh(1)
* Protocol Versions
  * Version 2 - always use this
  * Version 1 - old, barely more secure than unencrypted telnet

## A Brief Intro to Encryption

* Encryption transforms readable plaintext into unreadable ciphertext that people without the key cannot understand. Decryption is the reverse of this process.
* Symmetric algorithms use the same key for both encryption and decryption.
* Asymmetric algorithms use a different key for encryption and decryption.

## Generating Keys
* Highly discouraged from using passwords, since SSH keys are more secure
* ssh-keygen
  * By default generates an RSA 2048 bit key
  * `ssh-keygen -t rsa -b 4096 -C mason@do.co`
  * RSA is accepted everywhere, though ecdsa is better
  * dsa is no longer recommended
  * rsa is showing its age. Larger key size is better.
  * ecdsa new Digital Standard Algorithm standardized by US Gov. Uses 521 bits.
  * ed25519 new algorithm added, support not universal yet

## Quick *sshd* Security Wins

* Usually found in /etc/ssh/sshd_config
* Disable Root SSH - PermitRootLogin no
* No Password Authentication - PasswordAuthentication no
* Disable X11 Forwarding if you don't need it - X11Forwarding no

## Verify Host Fingerprints

* When you first login, you will be presented with a key fingerprint. Verify that this is actually the fingerprint of the server key.
* Someone could impersonate the server. You'll have to take the risk on the first connect.
* On the server run `ssh-keygen -lf /etc/ssh/ssh_host_<type>_key.pub > $HOME/fingerprints.txt` from a console
* Verify the fingerprints match
* You may want to automate this and get the fingerprints of every server and distribute them to your users

## SSH Agent Forwarding

* Scenario:
  * Have Droplets behind a Load Balancer that are not accessible to the public internet
  * Use a Bastion host to jump in to private network
  * Don't want to have my SSH key on Bastion host
* Run `ssh-agent` on your local machine to turn on
* SSH to host forwarding the agent `ssh -A mason@sammy.codes`
  * Identity is forwarded through the agent to the Bastion; Droplets are accessible
* Warning: `ssh-agent` keeps the key in memory, so if Bastion is compromised, your key could be pulled out of memory

## Setting up 2FA with SSH

* Two Factor Authentication is possible with SSH and PAM
* PAM - Pluggable Authentication Modules
* [How To Set Up Multi-Factor Authentication for SSH on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-20-04)
* Enable rate-limiting

## Port Forwarding

* SSH can serve as a wrapper around arbitrary TCP traffic to create a secure way of accessing unencrypted services such as POP3, IMAP, or HTTP.
* Local - "Take this port on the SSH server and make it local to my client"
  * `ssh -L 8080:port.codes:80 root@port.codes`
  * Can ensure securely entering admin credentials into your web app
* Remote - "Take this port on my client and attach it to the remote server"
* Dynamic - Essentially creates a SOCKS proxy on the SSH client allowing any request to proxy out through the server, giving access to the server's entire network

## OpenSSH-based VPN

* OpenSSH supports building generic tunnels that can pass all traffic and protocols, not just TCP
  * Not supported by PuTTy
* When a TCP packet is lost, it retransmits
  * Wrapping TCP in TCP amplifies this effect
  * TCP-based VPNs collapse when congested
* Not the greatest idea; probably the most complicated thing you can do with OpenSSH

## Honeypot

* A honeypot is a server that is intentionaly left open for attackers to exploit.
  * Once the attackers are in, they are dropped into an environment that looks like a typical server but is a decoy. Events on this machine are typically ignored and when a user logs off, their changes are deleted.
* [Cowrie SSH and Telnet Honeypot](https://github.com/cowrie/cowrie)
 
## Resources

* openssh.com
* SSH Mastery, 2nd Edition - Michael W Lucas
