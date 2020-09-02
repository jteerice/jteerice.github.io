---
layout: post
title: 247/CTF - AN IMPOSSIBLE NUMBER
---

## Prompt
Can you think of a number which at the same time is one more than itself?

### Solution
We are given some C code for the backend. As the value range for an `int` in C is -2,147,483,648 to 2,147,483,647. The obvious answer is 2,147,483,647 because incrementing it would cause an integer overflow.
```c
#include <stdio.h>
int main() {
    int impossible_number;
    FILE *flag;
    char c;
    if (scanf("%d", &impossible_number)) {
        if (impossible_number > 0 && impossible_number > (impossible_number + 1)) {
            flag = fopen("flag.txt","r");
            while((c = getc(flag)) != EOF) {
                printf("%c",c);
            }
        }
    }
    return 0;
}
```
```bash
$ telnet 468b037a133065a0.247ctf.com 50247
...
2147483647
247CTF{38f5daf7{censored}3a7575bf4d7d1e}
```
