---
layout: post
title: Binary Exploitation&#58; Pwnable.kr/leg
---

## Pwnable.kr: Leg - Write-up

This is simple challenge that tests very basic knowledge of ARM assembly language. The executable is not downloadable using ```scp``` so we can save the ```c``` and ```asm``` file locally and take a look at it from there.

### The Code

Let's inspect the ```c``` file and see what's going on.

```c
#include <stdio.h>
#include <fcntl.h>
int key1(){
        asm("mov r3, pc\n");
}
int key2(){
        asm(
        "push   {r6}\n"
        "add    r6, pc, $1\n"
        "bx     r6\n"
        ".code   16\n"
        "mov    r3, pc\n"
        "add    r3, $0x4\n"
        "push   {r3}\n"
        "pop    {pc}\n"
        ".code  32\n"
        "pop    {r6}\n"
        );
}
int key3(){
        asm("mov r3, lr\n");
}
int main(){
        int key=0;
        printf("Daddy has very strong arm! : ");
        scanf("%d", &key);
        if( (key1()+key2()+key3()) == key ){
                printf("Congratz!\n");
                int fd = open("flag", O_RDONLY);
                char buf[100];
                int r = read(fd, buf, 100);
                write(0, buf, r);
        }
        else{
                printf("I have strong leg :P\n");
        }
        return 0;
}
```

It appears that the the main function reads in a value from ```stdin``` and compares it to the values returned by the sum of the ```key1```, ```key2```, and ```key3``` functions.

The challenge gives us two files to work with: A ```c``` file and an ```asm``` file. The ```asm``` file will serve as a legend for the c file. We can take a closer look at each ```key``` function individually and calculate the sum.

### ARM Primer

As most of us are more experienced with x86 (including myself!), we can try and relate the ARM registers with thier x86 equivalents.

```
-------------------------------------------------------------
|  ARM  |    Description         |  x86                     |
-------------------------------------------------------------
|  R0   |  General Purpose       |  EAX                     |
| R1-R5 |  General Purpose       |  EBX, ECX, EDX, ESI, EDI |
| R6-R10|  General Purpose       |  -			    |
|  R11  |  Frame Pointer         |  EBP                     |
|  R12  |  Intra Procedural Call |  -                       |
|R13(SP)|  Stack Pointer         |  ESP                     |
|R14(LR)|  Link Register         |  -                       |
|R15(PC)|  Program Counter       |  EIP                     |
| CPSR  |  Flags                 |  EFLAGS                  |
-------------------------------------------------------------
```

##### R0

The ```R0``` register is the equivalent of ```EAX```, and thus, will hold the return value of each function.

##### R15 (PC)

The ```R15 (PC)``` register is the equivalent of the ```EIP``` register. In x86, the ```EIP``` register will point to the next instruction to be executed, but in ARM, it points to the instruction *after* the next instruction, effectively pointing to the second intruction after the one being executed.

##### R14 (LR)

The ```R14  (LR``` register is the Link Register. This register hold the memory address of the next instruction to be executed where a function call was initiated from. This allows the program to return to the "parent" function that initialed the "child" function.

### key1

The first code block is rather simple, but the ```asm``` file makes it easier to understand the return value of each function.
```asm
(gdb) disass key1
Dump of assembler code for function key1:
   0x00008cd4 <+0>:     push    {r11}           ; (str r11, [sp, #-4]!)
   0x00008cd8 <+4>:     add     r11, sp, #0
   0x00008cdc <+8>:     mov     r3, pc
   0x00008ce0 <+12>:    mov     r0, r3
   0x00008ce4 <+16>:    sub     sp, r11, #0
   0x00008ce8 <+20>:    pop     {r11}           ; (ldr r11, [sp], #4)
   0x00008cec <+24>:    bx      lr
End of assembler dump.
```

The first two lines are the function preamble. The following two lines are the meat and potatoes of the function. 
```asm
 0x00008cdc <+8>:     mov     r3, pc
 0x00008ce0 <+12>:    mov     r0, r3
```

The first line takes the memory address stored at ```pc``` and moves it into ```r3```. The following line simply moves the value of ```r3``` and stores it in ```r0``` to be returned. All we need to do is figure out the value in ```pc``` at the time of this instruction's execution and we have the value from the ```key1``` function.

Since we know that the ```pc``` points to the second instruction from the current instruction, we know that ```pc``` points to ```0x00008ce4```. Running that through a python shell yields the value 36068. ```Key``` solved!

### key2

The ```key2``` function looks quite a bit more complicated, but I promise, it is quite easy as well.
```asm
(gdb) disass key2
Dump of assembler code for function key2:
   0x00008cf0 <+0>:     push    {r11}           ; (str r11, [sp, #-4]!)
   0x00008cf4 <+4>:     add     r11, sp, #0
   0x00008cf8 <+8>:     push    {r6}            ; (str r6, [sp, #-4]!)
   0x00008cfc <+12>:    add     r6, pc, #1
   0x00008d00 <+16>:    bx      r6
   0x00008d04 <+20>:    mov     r3, pc
   0x00008d06 <+22>:    adds    r3, #4
   0x00008d08 <+24>:    push    {r3}
   0x00008d0a <+26>:    pop     {pc}
   0x00008d0c <+28>:    pop     {r6}            ; (ldr r6, [sp], #4)
   0x00008d10 <+32>:    mov     r0, r3
   0x00008d14 <+36>:    sub     sp, r11, #0
   0x00008d18 <+40>:    pop     {r11}           ; (ldr r11, [sp], #4)
   0x00008d1c <+44>:    bx      lr
End of assembler dump.
```

We know that the value being returned in the function is stored at ```R0```. Knowing this, we can work backwards in the function to see which instructions are pertinent to this challenge. To make this section a little more concise, I will remove the bloat and show only the lines that are necessary to decode ```key2```.
```asm
   0x00008d04 <+20>:    mov     r3, pc
   0x00008d06 <+22>:    adds    r3, #4
```
and
```asm
   0x00008d10 <+32>:    mov     r0, r3
```

To start, ```pc``` is moved to the ```r3``` register, has the value immediate value ```4``` added to it, and is moved to ```r0``` to be returned from the function. Once again, all we need to do is get the memory address stored at ```pc```, convert it to decimal value, and add 4 to it. 

The memory address two instructions from the instruction being executed when ```pc``` is moved into ```r3``` is ```0x00008d08```. Running that through a python shell yields 36104 and adding 4 to that yields 36108. Done!

### key3

This function is similar to the other two, but references the ```lr``` register instead of ```pc```.
```asm
(gdb) disass key3
Dump of assembler code for function key3:
   0x00008d20 <+0>:     push    {r11}           ; (str r11, [sp, #-4]!)
   0x00008d24 <+4>:     add     r11, sp, #0
   0x00008d28 <+8>:     mov     r3, lr
   0x00008d2c <+12>:    mov     r0, r3
   0x00008d30 <+16>:    sub     sp, r11, #0
   0x00008d34 <+20>:    pop     {r11}           ; (ldr r11, [sp], #4)
   0x00008d38 <+24>:    bx      lr
End of assembler dump.
```

Since ```lr``` references the memory address of the next intruction to be executed in the parent function, we will have to look back at the ```main``` function to find the value of ```lr```.


Here is the code chunk that calls ```key3``` in the ```main``` function.
```asm
   0x00008d7c <+64>:    bl      0x8d20 <key3>
   0x00008d80 <+68>:    mov     r3, r0
```

The memory address stored in ```lr``` is the next instruction after the call to ```key3```, which is ```0x00008d80```. This value is moved to ```r3``` then to ```r0``` to be returned. Converted to decimal, this value is 36224. Time to pwn the program!

### pwn

The values that are returned from the three ```key``` functions are 36068, 36108, and 36224. The sum of these numbers is 108400. Time to connect to the ```ssh``` server and see if we are correct.
```
/ $ ./leg
Daddy has very strong arm! : 108400
Congratz!
My daddy has a lot of ARMv5te muscle!
```

Pwned!
