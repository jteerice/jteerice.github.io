---
layout: post
title: pwnable.kr - flag
---

## Prompt
Papa brought me a packed present! let's open it.

Download : http://pwnable.kr/bin/flag

This is reversing task. all you need is binary

## Solution
Download the file and figure out what it does.
```
noble@heart:~/cyber/ctf/pwnable.kr/flag$ wget http://pwnable.kr/bin/flag

noble@heart:~/cyber/ctf/pwnable.kr/flag$ file flag
flag: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, no section header

noble@heart:~/cyber/ctf/pwnable.kr/flag$ chmod +x flag

noble@heart:~/cyber/ctf/pwnable.kr/flag$ ./flag
I will malloc() and strcpy the flag there. take it.
```
Check for longer strings, perhaps the flag?
```
noble@heart:~/cyber/ctf/pwnable.kr/flag$ strings -25 flag
@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_
`abcdefghijklmnopqrstuvwxyz{|}~
 "9999$%&/999956799999:<DG9999HI_`
 ''''!#$`''''abcd''''efgh''''ijkl''''mnop''''qrst''''uvwx''''yz{|''''}~
Q2R''''STUV''''WXYZ''''[\]^''''_
MNONNNNPRTUNNNNVWYZNNNN[\_`NNNNabcdNNNNefhi
 rrrr!"#$rrrr%&'(rrrr)*+,rrrr-./0rrrr1234rrrr5678rrrr9;<=rrrr>@ABrrrrCDFJrrrrKLMNrrrrOPRSrrrrTUVWrrrrXYZ[rrrr\]^_rrrr`abcrrrrdefgrrrrhijkrrrrlmnorrrrpqrsrrrrtuvwrrrrxyz{rrrr|}~
 !"9999#$%&9999'()*9999+,-.9999/012999934569999789:9999;<=>9999?@AB9999CDEF9999GHIJ9999KLMN9999OPQR9999STUV9999WXYZ9999[\]^9999_`ab9999cdef9999ghij9999klmn9999opqr9999stuv9999wxyz9999{|}~9999
b'cdr%WrefgWr%Whij%Wr%klr%WrmnoWr%Wpqr%Wr%str%WruvwWr%Wxyz%Wr%ABr%WrCDEWr%WFGH%Wr%IJr%WrKLMWr%WNOP%Wr%QRr%WrSTUWr%WVWX%Wr%YZ
 $9999(/6>9999HQXa9999eimq9999uy}
PROT_EXEC|PROT_WRITE failed.
$Info: This file is packed with the UPX executable packer http://upx.sf.net $
$Id: UPX 3.08 Copyright (C) 1996-2011 the UPX Team. All Rights Reserved. $
GCC: (Ubuntu/Linaro 4.6.3-1u)#
```
File was packed with UPX; let's unpack it.
```
noble@heart:~/cyber/ctf/pwnable.kr/flag$ upx -d flag
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2018
UPX 3.95        Markus Oberhumer, Laszlo Molnar & John Reiser   Aug 26th 2018

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
    883745 <-    335288   37.94%   linux/amd64   flag

Unpacked 1 file.

# Still the same output
noble@heart:~/cyber/ctf/pwnable.kr/flag$ ./flag
I will malloc() and strcpy the flag there. take it.
```
Let's check the calls made with gdb (`-q` is the quiet flag):
```
noble@heart:~/cyber/ctf/pwnable.kr/flag$ gdb -q flag
Reading symbols from flag...(no debugging symbols found)...done.
(gdb) disass main
Dump of assembler code for function main:
   0x0000000000401164 <+0>:     push   %rbp
   0x0000000000401165 <+1>:     mov    %rsp,%rbp
   0x0000000000401168 <+4>:     sub    $0x10,%rsp
   0x000000000040116c <+8>:     mov    $0x496658,%edi
   0x0000000000401171 <+13>:    callq  0x402080 <puts>
   0x0000000000401176 <+18>:    mov    $0x64,%edi
   0x000000000040117b <+23>:    callq  0x4099d0 <malloc>
   0x0000000000401180 <+28>:    mov    %rax,-0x8(%rbp)
   0x0000000000401184 <+32>:    mov    0x2c0ee5(%rip),%rdx        # 0x6c2070 <flag>
   0x000000000040118b <+39>:    mov    -0x8(%rbp),%rax
   0x000000000040118f <+43>:    mov    %rdx,%rsi
   0x0000000000401192 <+46>:    mov    %rax,%rdi
   0x0000000000401195 <+49>:    callq  0x400320
   0x000000000040119a <+54>:    mov    $0x0,%eax
   0x000000000040119f <+59>:    leaveq
   0x00000000004011a0 <+60>:    retq
End of assembler dump.
(gdb) x/s *0x6c2070
0x496628:       "{censored}"
```