---
layout: post
title: Binary Exploitation - Pwnable_kr/Input2
---
This challenge can be found on the pwnable_kr [website](http://pwnable.kr/play.php).

## Pwnable_kr - Input Write-up

After using ```scp``` to copy the binary and c file locally, we can use ```cat``` to take a look at the c file.

```
└─$ cat input.c                
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>

int main(int argc, char* argv[], char* envp[]){
	printf("Welcome to pwnable.kr\n");
	printf("Let's see if you know how to give input to program\n");
	printf("Just give me correct inputs then you will get the flag :)\n");

	// argv
	if(argc != 100) return 0;
	if(strcmp(argv['A'],"\x00")) return 0;
	if(strcmp(argv['B'],"\x20\x0a\x0d")) return 0;
	printf("Stage 1 clear!\n");	

	// stdio
	char buf[4];
	read(0, buf, 4);
	if(memcmp(buf, "\x00\x0a\x00\xff", 4)) return 0;
	read(2, buf, 4);
        if(memcmp(buf, "\x00\x0a\x02\xff", 4)) return 0;
	printf("Stage 2 clear!\n");
	
	// env
	if(strcmp("\xca\xfe\xba\xbe", getenv("\xde\xad\xbe\xef"))) return 0;
	printf("Stage 3 clear!\n");

	// file
	FILE* fp = fopen("\x0a", "r");
	if(!fp) return 0;
	if( fread(buf, 4, 1, fp)!=1 ) return 0;
	if( memcmp(buf, "\x00\x00\x00\x00", 4) ) return 0;
	fclose(fp);
	printf("Stage 4 clear!\n");	

	// network
	int sd, cd;
	struct sockaddr_in saddr, caddr;
	sd = socket(AF_INET, SOCK_STREAM, 0);
	if(sd == -1){
		printf("socket error, tell admin\n");
		return 0;
	}
	saddr.sin_family = AF_INET;
	saddr.sin_addr.s_addr = INADDR_ANY;
	saddr.sin_port = htons( atoi(argv['C']) );
	if(bind(sd, (struct sockaddr*)&saddr, sizeof(saddr)) < 0){
		printf("bind error, use another port\n");
    		return 1;
	}
	listen(sd, 1);
	int c = sizeof(struct sockaddr_in);
	cd = accept(sd, (struct sockaddr *)&caddr, (socklen_t*)&c);
	if(cd < 0){
		printf("accept error, tell admin\n");
		return 0;
	}
	if( recv(cd, buf, 4, 0) != 4 ) return 0;
	if(memcmp(buf, "\xde\xad\xbe\xef", 4)) return 0;
	printf("Stage 5 clear!\n");

	// here's your flag
	system("/bin/cat flag");	
	return 0;
}
```
So it looks like this challenge is broken up into 5 sepearate challenges. We can try and conquer them one by one.

### argv

Let's take a look at the code block for the first challenge more closely.

```
// argv
	if(argc != 100) return 0;
	if(strcmp(argv['A'],"\x00")) return 0;
	if(strcmp(argv['B'],"\x20\x0a\x0d")) return 0;
	printf("Stage 1 clear!\n");
```

We can see that the program expects 100 arguments and will exit otherwise. Additionally, the argument at index ```'A'``` should be a null byte, and the argument at index ```'B'``` should be ```"\x20\x0a\x0d```. To accomplish this, I will make use of the ```execve``` function in C.

The ```execve``` function works by taking three arguments: The full path string, an array of ```char``` pointer, and an array of environment variables which is nullable. The function will stop execution of the calling process and replace it with the process being pointed to be the full path argument. More information can be found [Here](https://man7.org/linux/man-pages/man2/execve.2.html).

Here is the C program I created to pass in the necessary arguments:
```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv)
{

	char* args[100];

	for (int i =0; i < 100; i++)
	{
		args[i] = "A";
	}

	args[0] = "input";
	args['A'] = "\x00";
	args['B'] = "\x20\x0a\x0d";
	args[100] = '\0';

	execve("/home/jake/Desktop/pwnable_kr/input/breakme", args, NULL);

	return 0;
}
```
Now let's go through the program line by line. To start, I initialized a ```char``` pointer array with 101 elements. Even though the arguments are zero indexed, the ```char``` pointer array passed to the ```execve``` function must be null terminated, so we need to add an additional element for the null terminator.

Next, I use a ```for``` loop to fill the array with arbitrary values. The next line replaces the first element with the name of the binary to be executed by ```execve```. Then I replace indexes ```'A'``` and ```'B'``` with the necessary values, and finish with the null terminator at index 100.

Running this program, we can see that it worked.
```
└─$ ./test
Before
Welcome to pwnable.kr
Let's see if you know how to give input to program
Just give me correct inputs then you will get the flag :)
Stage 1 clear!
```


