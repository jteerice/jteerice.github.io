---
layout: post
title: 247/CTF - TIPS AND TRICKS
---

## Prompt
Utilise a programming language to interface with the socket and automate solving 500 simple addition problems to receive the flag. Take care when interfacing with unknown remote services - '\n' is not the only way to end a line!

## Solution
```py
#!/usr/bin/env python3
from pwn import *

URL="54774aadc5a56c41.247ctf.com"
PORT=50488

# [+] Opening connection to 54774aadc5a56c41.247ctf.com on port 50488: Done
r = remote(URL,PORT)

# b'Welcome to the 247CTF addition verifier!\r\n'
print(r.recvline())
# b'If you can solve 500 addition problems, we will give you a flag!\r\n'
print(r.recvline())

for i in range(500):
	problem = r.recvline().decode("utf-8") 	# What is the answer to 64 + 491?
	
	# print(problem)

	split = problem.split() # ['What', 'is', 'the', 'answer', 'to', '64', '+', '491?']

	a = int(split[5])		# '64' -> 64
	b = int(split[7].strip('?')) 	# '491?' -> 491

	answer = (str(a+b)+'\r\n').encode("utf-8")
	# print(answer)
	r.sendline(answer)

	r.recvline() # b'Yes, correct!\r\n'

# b'247CTF{6ae15c0aeb{censored}1eb0dda5cab1}\r\n'
flag = r.recvline().decode("utf-8").strip('\r\n')

# 247CTF{6ae15c0aeb{censored}1eb0dda5cab1}
print(flag)

# [*] Closed connection to 54774aadc5a56c41.247ctf.com port 50488
r.close()
```