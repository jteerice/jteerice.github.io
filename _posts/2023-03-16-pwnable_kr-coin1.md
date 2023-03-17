---
layout: post
title: Binary Exploitation&#58; Pwnable.kr/coin1
---

## Pwnable.kr: coin1 - Write-up

For this challenge, we are not given a source or binary file. We are simply given a netcat server to connect to.
```
Mommy, I wanna play a game!
(if your network response time is too slow, try nc 0 9007 inside pwnable.kr server)

Running at : nc pwnable.kr 9007
```

When we connect, we see a prompt for a text based game.
```
└─$ nc pwnable.kr 9007

	---------------------------------------------------
	-              Shall we play a game?              -
	---------------------------------------------------
	
	You have given some gold coins in your hand
	however, there is one counterfeit coin among them
	counterfeit coin looks exactly same as real coin
	however, its weight is different from real one
	real coin weighs 10, counterfeit coin weighes 9
	help me to find the counterfeit coin with a scale
	if you find 100 counterfeit coins, you will get reward :)
	FYI, you have 60 seconds.
	
	- How to play - 
	1. you get a number of coins (N) and number of chances (C)
	2. then you specify a set of index numbers of coins to be weighed
	3. you get the weight information
	4. 2~3 repeats C time, then you give the answer
	
	- Example -
	[Server] N=4 C=2 	# find counterfeit among 4 coins with 2 trial
	[Client] 0 1 		# weigh first and second coin
	[Server] 20			# scale result : 20
	[Client] 3			# weigh fourth coin
	[Server] 10			# scale result : 10
	[Client] 2 			# counterfeit coin is third!
	[Server] Correct!

	- Ready? starting in 3 sec... -
```

### Objective

To complete this challenge, we need identify the indecies of 100 "counterfeit" coins in ```C``` number of chances. The range of indecies we need to search is indicated by ```N```. Oh, and all of this needs to be completed in 60 seconds.

In order to expediate the operations needed to complete this challenge, we can script it using python. The method we will use to search for the counterfeit coin is called ```binary search```.

### Binary Search

If we wanted to search every possibility iteratively, it would take ```n``` number of tries (```n``` being the range of indecies to chose from). This, unfortunately, will not be efficient enough due to the constrained number of attempts at guessing the counterfeit coin. 

Binary search is a searching algorithm that runs in O(logn), meaning that every time an iteration occurs, the search range is halved. For the visual learners (like me!) out there, we can see what that looks like with a small array.

The most important take away is that the maximum number of search iterations will be the logarithm (base 2) of the elements in a collection. For more information on binary search, refer to this [guide](https://www.geeksforgeeks.org/binary-search/).

### The Script

Since this challenge is heavily dependent on network connection speed, we can copy/paste the exploit locally on the ```ssh``` server. That can be completed with the following steps:

1. Connect to the ```ssh``` server.
2. Use ```mkdir /tmp/$(some_directory_name)```.
3. ```cd``` to the directory you created.
4. Create the python file from the text editors available (I used vim).
5. Paste your script then save/exit.
6. ```chmod +x $(your_script)```.

Here is the python script I created:
```python
#!/usr/bin/env python2

import string
from pwn import *

conn = remote('localhost', 9007)

conn.recvuntil('Ready?')
conn.recvline()
conn.recvline()

def init():
	nums = conn.recvline().decode().strip().split(' ')
	r = int(nums[0].split('=')[1])
	t = int(nums[1].split('=')[1])
	print(r)
	print(t)	
	print('='*40)
	return r, t

def binarySearch(left, right, tries):
	for attempts in range(tries):
		
		mid = int((left + right) / 2)
		print(left)
		print(right)
		print(mid)
		guess = ' '.join(str(i) for i in range(left, mid))
		
		conn.sendline(guess)
		ans = int(conn.recvline().decode())
		print("answer: " + str(ans))	
		print('='*40)	
		if ans % 10 == 0:
			left = mid 
		else:
			right = mid 
	return left

for coins in range(100):
	left = 0
	right, tries = init()

	finalAnswer = binarySearch(left, right, tries)
	print("Final answer: " + str(finalAnswer))
	conn.sendline(str(finalAnswer))

	print(conn.recvline())

print(conn.recvline())
print(conn.recvline())	
```

Let's run it and see what we get.
```
Final answer: 233
Correct! (99)

Congrats! get your flag

b1NaRy_S34rch1nG_1s_3asy_p3asy
```

Et Voila!
