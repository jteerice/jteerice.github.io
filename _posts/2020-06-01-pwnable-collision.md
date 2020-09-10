---
layout: post
title: pwnable.kr - collision 
---

## Prompt
Daddy told me about cool MD5 hash collision today.
I wanna do something like that too!

`ssh col@pwnable.kr -p2222 (pw:guest)`

## Solution
We are given 3 files: `col`, `col.c`, and `flag`. We cannot open flag, but can read `col.c` and run the executable.
```c
#include <stdio.h>
#include <string.h>
unsigned long hashcode = 0x21DD09EC;
unsigned long check_password(const char* p){
        int* ip = (int*)p;
        int i;
        int res=0;
        for(i=0; i<5; i++){
                res += ip[i];
        }
        return res;
}

int main(int argc, char* argv[]){
        if(argc<2){
                printf("usage : %s [passcode]\n", argv[0]);
                return 0;
        }
        if(strlen(argv[1]) != 20){
                printf("passcode length should be 20 bytes\n");
                return 0;
        }

        if(hashcode == check_password( argv[1] )){
                system("/bin/cat flag");
                return 0;
        }
        else
                printf("wrong passcode.\n");
        return 0;
}
```

We must supply a 20 byte string that will cause the `check_password()` function to output a value equal to the hashcode value `0x21DD09EC`, or 568134124.

```
col@pwnable:~$ echo $((16#21DD09EC))
568134124
```

`check_password()` declares `ip` to be an array of integer pointers starting with a casted integer pointer to `p`. Because ints in C are 4 bytes and we supplied 20 bytes worth of characters, we `ip` has an array of 5 ints. These ints are then summed into the `res` variable and returned.

So, we need to come up with five 4-byte integers that sum to 568134124.

```
>>> 568134124/5
113626824.8
>>> 113626824*4
454507296
>>> 568134124-454507296
113626828
>>> hex(113626824)
'0x6c5cec8'
>>> hex(113626828)
'0x6c5cecc'
```
Notice that the hex is not in little-endian and is missing a nibble. Let's add the missing zero to each and flip the byte order around.

```
col@pwnable:~$ ./col $(python -c 'print "\xc8\xce\xc5\x06" * 4 + "\xcc\xce\xc5\x06"')
{flag censored}
```
