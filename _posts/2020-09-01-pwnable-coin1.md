---
layout: post
title: pwnable.kr - coin1
---

## Prompt
Mommy, I wanna play a game!
(if your network response time is too slow, try nc 0 9007 inside pwnable.kr server)

Running at : nc pwnable.kr 9007
## Analysis
```
noble@heart:~$ nc pwnable.kr 9007

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
        [Server] N=4 C=2        # find counterfeit among 4 coins with 2 trial
        [Client] 0 1            # weigh first and second coin
        [Server] 20                     # scale result : 20
        [Client] 3                      # weigh fourth coin
        [Server] 10                     # scale result : 10
        [Client] 2                      # counterfeit coin is third!
        [Server] Correct!

        - Ready? starting in 3 sec... -

N=338 C=9
```
We need to, with a restricted number of guesses, find a counterfeit coin in an array of coins. I'm optimistic about using binary search to cut out half of the possible coins each guess. The main issue is finding 100 coins in 60 seconds. We obviously have to do this programmatically. Python and its `pwntools` library will be very useful for sending, receiving, and processing.

At first I was making the connections remotely, i.e. with `conn = remote('pwnable.kr', 9007)`, but it was not fast enough. We need to solve 100 challenges, and my initial script only reached the mid-80s in solves. I was considering using recursive binary search, but then remembered I could `ssh` into the server to run my scripts locally to improve response time. Note: you can make SSH connections with `pwntools` but you'll need to programmatically upload, `chmod +x`, and run your solution script if you want to bypass the delay.

## Solution

SSH into on of the other pwnable.kr challenge accounts, e.g. ```ssh fd@pwnable.kr -p2222 #password: guest```.
```
fd@pwnable:~$ mkdir /tmp/binary
fd@pwnable:~$ cd $_
fd@pwnable:/tmp/binary$ vim solve.py # paste file into vim
fd@pwnable:/tmp/binary$ chmod +x solve.py
fd@pwnable:/tmp/binary$ python solve.py
[+] Opening connection to localhost on port 9007: Done
Correct! (0)

Correct! (1)
...
Correct! (99)

Congrats! get your flag

{censored flag}

[*] Closed connection to localhost port 9007
fd@pwnable:/tmp/binary$
```

**solve.py**:
```py
#!/usr/bin/env python2

from pwn import *

# For SSHing in, and then running locally
# s = ssh(host="pwnable.kr", user="fd", port=2222, password="guest")
# conn = s.remote('localhost', 9007)

# For running remotely
# conn = remote('pwnable.kr', 9007)

# For running locally on pwnable.kr
conn = remote('localhost', 9007)

conn.recvuntil('Ready? starting in 3 sec')
conn.recvline()
conn.recvline()

for _ in range(100):
        
        line = conn.recvline().decode('utf-8').strip().split(' ') # [u'N=317', u'C=9']
        # print line
        n = int(line[0].split('=')[1])  # 317
        c = int(line[1].split('=')[1])  # 9

        start = 0
        end = n

        for _ in range(c):

                mid = int((start + end)/2) # cast to ensure only whole numbers

                # print('start: '+str(start))
                # print('mid: '+str(mid))
                # print('end: '+str(end))

                guess = ' '.join(str(i) for i in range(start, mid + 1))
                # print guess
                conn.sendline(guess)
                weight = int(conn.recvline())
                # print weight
                
                if weight % 10 == 0: # if divisible by 10, then no counterfeit in list
                        start = mid + 1
                else: # counterfeit in list
                        end = mid

        conn.sendline(str(start)) # send final guess

        print(conn.recvline())  # Correct! (n)

print(conn.recvline()) # Congrats! get your flag
print(conn.recvline()) # {actual flag}

conn.close()

```