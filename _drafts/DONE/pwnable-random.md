---
layout: post
title: pwnable.kr - passcode
---

## Prompt
Daddy, teach me how to use random value in programming!

ssh random@pwnable.kr -p2222 (pw:guest)

## Solution

**random.c**:
```c
#include <stdio.h>

int main(){
        unsigned int random;
        random = rand();        // random value!

        unsigned int key=0;
        scanf("%d", &key);

        if( (key ^ random) == 0xdeadbeef ){
                printf("Good!\n");
                system("/bin/cat flag");
                return 0;
        }

        printf("Wrong, maybe you should try 2^32 cases.\n");
        return 0;
}
```
> The srand() function sets the starting point for producing a series of pseudo-random integers. If srand() is not called, the rand() seed is set as if srand(1) were called at program start. ([Source](https://www.geeksforgeeks.org/rand-and-srand-in-ccpp/))

The seed for `rand()` will not be updated. So, let's write another file to check what the key is and we can use the properties of XOR to solve for the key.

```
random@pwnable:~$ mkdir /tmp/check_rand && cd $_
random@pwnable:/tmp/check_rand$ cat rand.c
#include <stdio.h>
#include <stdlib.h>
int main(){
    unsigned int random;
    random = rand();
    printf("%d\n", random);
    return 0;
}
random@pwnable:/tmp/check_rand$ gcc rand.c -o rand
random@pwnable:/tmp/check_rand$ ./rand
1804289383
random@pwnable:/tmp/check_rand$ ./rand
1804289383
random@pwnable:/tmp/check_rand$ ./rand
1804289383
```
If `(key ^ random) == 0xdeadbeef`, then `random ^ 0xdeadbeef == key`.

```
random@pwnable:/tmp/check_rand$ python
Python 2.7.12 (default, Nov 12 2018, 14:36:49)
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 1804289383 ^ 0xdeadbeef
3039230856
```
With the key, we can solve the challenge.
```
random@pwnable:~$ ./random
3039230856
Good!
{censored}
```