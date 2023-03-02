---
layout: post
title: Binary Exploitation - Pwnable_kr/Input2
---

## Pwnable_kr: Input - Write-up

This is a fairly straightforward binary exploitation challenge on Pwnable_kr that centers around passing input to a program. First we can try and exploit the program locally, then write an exploit that we can use to retrieve the flag remotely.

After using ```scp``` to copy the binary and c file locally, we can use ```cat``` to take a look at the c file.

```c              
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

```c
// argv
	if(argc != 100) return 0;
	if(strcmp(argv['A'],"\x00")) return 0;
	if(strcmp(argv['B'],"\x20\x0a\x0d")) return 0;
	printf("Stage 1 clear!\n");
```

We can see that the program expects 100 arguments and will exit otherwise. Additionally, the argument at index ```'A'``` should be a null byte, and the ```char``` array at index ```'B'``` should be ```"\x20\x0a\x0d"```. To accomplish this, I will make use of the ```execve``` function in C.

The ```execve``` function works by taking three arguments: The full path string, an array of ```char``` pointer, and an array of environment variables which is nullable. The function will stop execution of the calling process and replace it with the process being pointed to by the full path argument. More information can be found [Here](https://man7.org/linux/man-pages/man2/execve.2.html).

Here is the C program I created to pass in the necessary arguments:
```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv)
{

	char* args[101];

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
Now let's go through the program line by line. To start, we initialize a ```char``` pointer array with 101 elements. Even though the arguments are zero indexed, the ```char``` pointer array passed to the ```execve``` function must be null terminated, so we need to add an additional element for the null terminator.

Next, we use a ```for``` loop to fill the array with arbitrary values. The next line replaces the first element with the name of the binary to be executed by ```execve```. Then we replace indicies ```'A'``` and ```'B'``` with the necessary values, and finish with the null terminator at index 100.

Running this program, we can see that it worked.
```
└─$ ./test
Welcome to pwnable.kr
Let's see if you know how to give input to program
Just give me correct inputs then you will get the flag :)
Stage 1 clear!
```
### stdio

Let's take a look at the code block for the next stage.
```c
        // stdio
	char buf[4];
	read(0, buf, 4);
	if(memcmp(buf, "\x00\x0a\x00\xff", 4)) return 0;
	read(2, buf, 4);
        if(memcmp(buf, "\x00\x0a\x02\xff", 4)) return 0;
	printf("Stage 2 clear!\n");
```
This code block is pretty straightforward. A ```char``` array containing 4 bytes is initialized on the stack followed by a ```read``` function call. The ```read``` function reads 4 bytes from file descriptor 0 (stdin) into the ```char``` array. Then ```memcmp``` is called which compares 4 bytes in the ```char``` array with the bytes indicated. If it does not match, the program exits. The same process is repeated, but instead of file descriptor 0, ```read``` is called using file descriptor 2 (stderr).

To accomplish this, we can utilize pipes.

##### Pipe
Pipes are a mechanism for interprocess communication. When you use the ```|``` symbol in a shell, you are creating a pipe from the preceding process to the following process. A pipe writes input on one end and reads output from the other. To create a pipe, we can utilize the ```pipe``` system call. More information on creating pipes in the C language can be found [here](https://tldp.org/LDP/lpg/node11.html).

The ```pipe``` system call takes a single argument which is an array of two integers. The return value is an array of two integers which represent the input (write) and output (read) ends of the pipe. 

By using the pipe, we can use the ```fork``` system call which creates a duplicate process of the calling process. If successful, the return value of ```fork``` is the ```pid``` (process id) of the child in the parent and ```0``` in the child. Otherwise, ```fork``` will return ```-1``` to indicate that the system call failed. We can use this to determine if the current process is the parent or the child.

We need to know if the current process is either the parent or child so we know which file descriptor to close. According to [Creating Pipes in C](https://tldp.org/LDP/lpg/node11.html), if the current process is the child, we need to send data to the parent. In this case, we need to close ```fd[0]```. If the current process is the parent, we need to send data to the child. In this case, we would need to close ```fd[1]```. This is to ensure that the communicating processes don't get stuck in a loop with the same data being sent back and forth.

Here is my solution for stage 2:
```c
        int stdinStream[2];
	int stderrStream[2];	
	pid_t childPid;	

	if (pipe(stdinStream) < 0 || pipe(stderrStream) < 0)
	{
		printf("pipes failed!\n");
		exit(1);
	}	
	if ((childPid = fork()) < 0)
	{
		printf("fork failed!\n");
		exit(1);
	}
	if (childPid == 0)
	{
		close(stdinStream[0]);	
		close(stderrStream[0]);	
	
		write(stdinStream[1], "\x00\x0a\x00\xff", 4);	
		write(stderrStream[1], "\x00\x0a\x02\xff", 4);	
	}
	else 
	{
		close(stdinStream[1]);
		close(stderrStream[1]);

		dup2(stdinStream[0], 0);
		dup2(stderrStream[0], 2);

		close(stdinStream[0]);
		close(stderrStream[0]);	
		execve("/home/jake/Desktop/pwnable_kr/input/breakme", args, NULL);
	}
```
Let's take a closer look at the code. To start, we declare two integer arrays that will serve as the file descriptors for our two pipes. We call ```pipe``` on both integer arrays and check to ensure that the system call completed successfully. Next, we fork the process and check to ensure ```fork``` returned properly. If ```fork``` returned 0, we know we are in the child process and close the read ends of the pipes. Next, we write the required data into both pipes. Now the ```else``` block executes and the parent process closes the write ends of the pipe and duplicates the read ends of the pipe into ```stdin``` and ```stderr```. Finally, we close the read ends of the pipe in order to close the pipe and call ```execve```.

Compiling and running the program shows that we are successful.

```
└─$ ./test                
Welcome to pwnable.kr
Let's see if you know how to give input to program
Just give me correct inputs then you will get the flag :)
Stage 1 clear!
Stage 2 clear!
zsh: segmentation fault  ./test
```
### env

Once again, let's take a look at the code block for the next challenge.
```c
        // env
        if(strcmp("\xca\xfe\xba\xbe", getenv("\xde\xad\xbe\xef"))) return 0;
        printf("Stage 3 clear!\n");
```

This is pretty straightforward as well. This code block checks that the value of the envirnoment variable ```0xdeadbeef``` is ```0xcafebabe```. If the values don't match, the program exits.

To do this, all we need to do is setup the environment variable when we call ```execve```. The ```execve``` function requires that the environment variable argument be a ```char``` pointer array, and that array must be null terminated. The string values of the array elements must be in the format of ```key=value```.

Here is my simple code solution for stage 3.
```c
char* envp[2];

        envp[0] = "\xde\xad\xbe\xef=\xca\xfe\xba\xbe";
        envp[1] = "\0"; 
```
I initialized a character pointer array with 2 elements. This is to allow space for the environment variable I need to set, and the null terminating string. Next, I initialize the environent variable string at index ```0``` and initialize the null terminator at index ```1```.

When we run the code, we can see that it works as intended.
```
└─$ ./test         
Welcome to pwnable.kr
Let's see if you know how to give input to program
Just give me correct inputs then you will get the flag :)
Stage 1 clear!
Stage 2 clear!
Stage 3 clear!
```
### file

Let's inspect the next code block.
```
        // file
        FILE* fp = fopen("\x0a", "r");
        if(!fp) return 0;
        if( fread(buf, 4, 1, fp)!=1 ) return 0;
        if( memcmp(buf, "\x00\x00\x00\x00", 4) ) return 0;
        fclose(fp);
        printf("Stage 4 clear!\n");     
```
Another fairly simple challenge. The first line calls ```fopen``` which opens a file in read mode and saves returns a file pointer. The next line ensures that ```fopen``` returned successfully. Next, ```fread``` is called to read in one 4 byte item from the file pointer that was created with ```fopen```. Finally, ```memcmp``` checks to make sure that the value read in by ```fread``` is ```\x00\x00\x00\x00```, and upon success, closes the file pointer.

It is important to note that if the file that ```fopen``` is called on does not exist, it will create that file. Knowing this, we can call ```fopen``` on the file ```\x0a``` which will create the file for us. 

Here is the my solution for stage 4.
```c
	char* fileChallenge = "\x00\x00\x00\x00";
        FILE *fp = fopen("\x0a", "w");
        fwrite(fileChallenge, 4, 1, fp);
        fclose(fp);
```

The first line initializes a string to the required data. Then we open the file ```\x0a``` in write mode and write the string we initialized earlier to the file. Finally, we close the file.

Another stage complete.
```
└─$ ./test
Welcome to pwnable.kr
Let's see if you know how to give input to program
Just give me correct inputs then you will get the flag :)
Stage 1 clear!
Stage 2 clear!
Stage 3 clear!
Stage 4 clear!
```

### network

Let's take a look at the final stage.
```c
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
```
This is a much bigger code block than we have seen previously. We will need to dissect it line by line to get an idea of what's going on.

The code block starts by initializing two integer variables ```sd``` and ```cd```. The next line calls the ```socket``` function and saves the return value in ```sd```.







