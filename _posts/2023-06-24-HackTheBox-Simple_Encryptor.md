---
layout: post
title: Reverse Engineering&#58; HackTheBox/Simple_Encryptor
---

## HackTheBox - Simple Encryptor - Write-up

Downloading the files, we see that we have a elf file and a text file named ```flag.enc``` which is assumed to be the encrypted output of the flag.

Running the ```file``` command tells us that we are dealing with a 64-bit pie executable that is dynamically linked and not stripped.
```
encrypt: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=0bddc0a794eca6f6e2e9dac0b6190b62f07c4c75, for GNU/Linux 3.2.0, not stripped
```
Running ```strings``` and ```ltrace``` doesn't yield anything useful. Running the binary gives us a segmentation fault, so let's see what it looks like under the hood.

### Ghidra

Opening up in ghidra, we can see that the binary is trying to open a file named ```flag``` that doesn't exist locally on our machine, which is probably what is causing our segmentation fault.
```c
local_30 = fopen("flag","rb");
```

Further down in the ```main``` function, we see that a chunk of memory is being allocated on the heap and ```srand()``` is seeded.
```c
  local_20 = malloc(local_28);
  fread(local_20,local_28,1,local_30);
  fclose(local_30);
  tVar2 = time((time_t *)0x0);
  local_40 = (uint)tVar2;
  srand(local_40);
```

Next looks like the meat of the program, which is an encryption function with a lot of bitwise logic and using randomly generated integers.
```c
  for (local_38 = 0; local_38 < (long)local_28; local_38 = local_38 + 1) {
    iVar1 = rand();
    *(byte *)((long)local_20 + local_38) = *(byte *)((long)local_20 + local_38) ^ (byte)iVar1;
    local_3c = rand();
    local_3c = local_3c & 7;
    *(byte *)((long)local_20 + local_38) =
         *(byte *)((long)local_20 + local_38) << (sbyte)local_3c |
         *(byte *)((long)local_20 + local_38) >> 8 - (sbyte)local_3c;
  }
```

This would normally be a problem, seeing as ```rand()``` is seeded with a pseudo-random value of ```time(NULL)```, but fortunately, the program leeks the seed used as the first 4 bytes of the ```flag.enc``` file followed by the encrypted flag.

### Solution

First, we need to extract the first 4 bytes of ```flag.enc```.
```c
    int *seed = malloc(sizeof(int));
	rewind(fp);

	res = fread(seed, 1, 4, fp);
	if (res != 4) {
		printf("Failed to read seed.\n");
		return 0;
	}
	printf("The seed is: %d\n", *seed);
	srand(*seed);
```

Now we can generate the same random integers in the same exact order as the binary did when encrypting the flag originally. Using these values, we can reverse the bitwise logic and generate our flag!
```c
int xor_key, shift_key;
	char flag_enc[size - 3], c;
	fread(flag_enc, 1, (size - 4), fp);
	for (int i = 0; i < (size - 3); i++) {
		xor_key = rand();
		shift_key = rand() & 7;
		c = flag_enc[i];
		c = ((unsigned char)c << (8 - shift_key)) | ((unsigned char)c >> shift_key);
		c = (unsigned char)c ^ xor_key;
		flag_enc[i] = c;
	}

	flag_enc[size - 3] = '\0';
	printf("The flag is: %s\n", flag_enc);
```

And finally running the whole program yields us our flag.
```c
#include <stdio.h>
#include <stdlib.h>

int main() {

	FILE* fp = fopen("flag.enc", "rb");
	if (!fp) {
		printf("Could not open file.\n");
		return 0;
	}

	int res = fseek(fp, 0, SEEK_END);
	if (res) {
		printf("fseek failed.\n");
		return 0;
	}

	long size = ftell(fp);
	int *seed = malloc(sizeof(int));
	rewind(fp);

	res = fread(seed, 1, 4, fp);
	if (res != 4) {
		printf("Failed to read seed.\n");
		return 0;
	}
	printf("The seed is: %d\n", *seed);
	srand(*seed);

	int xor_key, shift_key;
	char flag_enc[size - 3], c;
	fread(flag_enc, 1, (size - 4), fp);
	for (int i = 0; i < (size - 3); i++) {
		xor_key = rand();
		shift_key = rand() & 7;
		c = flag_enc[i];
		c = ((unsigned char)c << (8 - shift_key)) | ((unsigned char)c >> shift_key);
		c = (unsigned char)c ^ xor_key;
		flag_enc[i] = c;
	}

	flag_enc[size - 3] = '\0';
	printf("The flag is: %s\n", flag_enc);

	return 0;
}
```

Et voila!
