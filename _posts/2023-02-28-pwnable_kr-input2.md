---
layout: post
title: Binary Exploitation - Pwnable_kr/Input2
---

## Pwnable_kr: Input - Write-up

This is a fairly straightforward binary exploitation challenge on Pwnable_kr that centers around passing input to a program. First we can try and exploit the program locally, then write an exploit that we can use to retrieve the flag remotely.

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

We can see that the program expects 100 arguments and will exit otherwise. Additionally, the argument at index ```'A'``` should be a null byte, and the ```char``` array at index ```'B'``` should be ```"\x20\x0a\x0d"```. To accomplish this, I will make use of the ```execve``` function in C.

The ```execve``` function works by taking three arguments: The full path string, an array of ```char``` pointer, and an array of environment variables which is nullable. The function will stop execution of the calling process and replace it with the process being pointed to by the full path argument. More information can be found [Here](https://man7.org/linux/man-pages/man2/execve.2.html).

Here is the C program I created to pass in the necessary arguments:
```
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
Now let's go through the program line by line. To start, I initialized a ```char``` pointer array with 101 elements. Even though the arguments are zero indexed, the ```char``` pointer array passed to the ```execve``` function must be null terminated, so we need to add an additional element for the null terminator.

Next, I use a ```for``` loop to fill the array with arbitrary values. The next line replaces the first element with the name of the binary to be executed by ```execve```. Then I replace indicies ```'A'``` and ```'B'``` with the necessary values, and finish with the null terminator at index 100.

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
```
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
Pipes are a mechanism for interprocess communication. When you use the ```|``` symbol in a shell, you are creating a pipe from the preceding process to the following process. A pipe reads input from one end and writes output on the other. To create a pipe, we can utilize the ```pipe``` system call.More information on creating pipes in the C language can be found [here](https://tldp.org/LDP/lpg/node11.html).

The ```pipe``` system call takes a single argument which is an array of two integers. The return value is an array of two integers which represent the input (read) and output (write) ends of the pipe. 

By using the pipe, we can use the ```fork``` system call which creates a duplicate process of the calling process. If successful, the return value of ```fork``` is the ```pid``` (process id) of the child in the parent and ```0``` in the child. Otherwise, ```fork``` will return ```-1``` to indicate that the system call failed. We can use this to determine if the current process is the parent or the child.

We need to know if the current process is either the parent or child so we know which file descriptor to close. According to [Creating Pipes in C](https://tldp.org/LDP/lpg/node11.html), if the current process is the child, we need to send data to the parent. In this case, we need to close ```fd[0]```. If the current process is the parent, we need to send data to the child. In this case, we would need to close ```fd[1]```. This is to ensure that the communicating processes don't get stuck in a loop with the same data being sent back and forth.

Here is my solution for stage 2:
```
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
Let's take a closer look at the code. To start, we declare two integer arrays that will serve as the file descriptors for our two pipes. We call ```pipe``` on both integer arrays and check to ensure that the system call completed successfully. Next, we fork the process and check to ensure ```fork``` returned properly. If ```fork``` returned 0, we know we are in the child process and close the read ends of the pipes. Next, we write the required data into both pipes. Now the else block executes and the parent process closes the write ends of the pipe and duplicates the read ends of the pipe into ```stdin``` and ```stderr```. Finally, we close the read ends of the pipe in order to close the pipe and call ```execve```.

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







