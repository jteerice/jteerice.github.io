---
layout: post
title: Reverse Engineering&#58; HackTheBox/Exalton
---

## HackTheBox - Exalton - Write-up

After downloading the binary, we see that it is a 64-bit executable, statically linked, and not stripped.
```
exatlon_v1: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=99364060f1420e00a780745abcfa419af0b8b0d8, for GNU/Linux 3.2.0, not stripped
```

The ```strings``` command isn't particularly useful either, seeing as it is statically linked. Running the program simply asks us for a password. After entering a string, the program loops.

### Reversing

For this challenge, I decided to use Binary Ninja. I have been hearing a lot of good things about Binary Ninja, especially it's user friendly plugin support and scripting capabilities. Through this challenge, I also learned that it has a pretty nifty debugger. It may very well become my disassembler of choice from here on out.

Opening the binary, the first thing I noticed is that this it was written in c++. This just makes things a little harder to read for me, but we just need to comb through it piece by piece. The main function starts by printing the banner followed by reading in input from the user. Next, a particularly interesting function, ```exalton()```, is called. Later in the function, we see that our input is compared with some value and if correct, it simply prints ```Looks good!```. 
```
00404d4c          if (rax_1 != 0)
00404d5c              int64_t* rax_2 = print_banner(&std::cout, "[+] Looks Good ^_^ \n\n\n")
00404d71              std::ostream::operator<<(rax_2, 0x467e20, rax_2)
00404d76              arg1 = 0
00404d7c              rbx_2 = 0
00404d98          else if (std::operator==<char, st..._traits<char>, std::allocator<char> >(&var_58, &data_54b5b2) == 0)
00404db5              int64_t* rax_4 = print_banner(&std::cout, "[-] ;(\n")
00404dca              std::ostream::operator<<(rax_4, 0x467e20, rax_4)
00404dcf              rbx_2 = 1
00404d9a          else
00404d9a              arg1 = 0
00404da0              rbx_2 = 0
00404ddb          std::string::~string(&var_58)
```

From this, we can deduce that the input we give the program is arbitrary to use finding the flag. Let's look at the ```exalton()``` function and see if we can gain ny insight.

This function takes two pointers as arguments.
```
00404aad  int64_t* exatlon(int64_t* arg1, 
00404aad      int64_t* arg2)
```

The function starts by calling the ```String``` constructor on the first pointer with some unrecognized data.
```
    std::string::string(arg1, &data_54b00c)
```

The ```arg1``` variable is most likely where our encrypted input is being stored. Next, we see thatour input is being shifted left by 4 bits and stored in arg1 before being returned. This doesn't necessarily tell us the flag, but it gives us an idea of how our input is being manipulated.

If we return to the main function, we see something I missed before. The input returned from ```exalton()``` is being compared to a list of predefined integers.
```
00404d37          char rax_1 = std::operator==<char, st..._traits<char>, std::allocator<char> >(&var_38, "1152 1344 1056 1968 1728 816 164…")
```

I am willing to bet that this is the list of integers, after the characters of our input are shifted left, must match. To test this, we can shift the values of the predefined integer array right by 4 bits and see if we can get something that looks like a flag!

### Solution

The program to solve this is pretty simple. We just create an integer array of the integer values shown in the binary and shift them right by 4 bits. After we can just cast them to a ```char``` and print them out.
```c
#include <stdio.h>
#include <stdlib.h>

int main() {

	unsigned int key[] = {1152, 1344, 1056, 1968, 1728, 816, 1648, 784, 1584, 816, 1728, 1520, 1840, 1664, 784, 1632, 1856, 152, 0, 1728, 816, 1632, 1856, 1520, 784, 1760, 1840, 1824, 816, 1584, 1856, 784, 1776, 1760, 528, 528, 2000};
	int size = sizeof(key)/sizeof(unsigned int);

	for (int i = 0; i < size; i++) {
		key[i] = key[i] >> 4;
		printf("%c", (char)key[i]);
	}

	return 0;
}
```

Running this yields the flag like we thought! Et voila!
