---
layout: post
title: 247/CTF - My Magic Bytes
---

## Prompt
Can you recover the secret XOR key we used to encrypt the flag?

## Solution

Our file `my_magic_bytes.jpg.enc` is an encrypted jpg (at least that's what the extension `.jpg.enc` leads us to believe). While this might be misdirection, let's start by assuming it is an encrypted JPEG. Because we know what the [magic bytes of a JPEG](https://en.wikipedia.org/wiki/List_of_file_signatures) are and we can see the encrypted version of those same bytes in the file, we can solve for the key using [XOR](https://en.wikipedia.org/wiki/Exclusive_or). Then we can XOR that key with the encrypted file to get the unencrypted file. This is also known as a [known-plaintext attack](https://en.wikipedia.org/wiki/Known-plaintext_attack).

```
A XOR B = C
C XOR B = A
A XOR C = B
```

Possible JPEG file Signatures: `FF D8 FF DB`, `FF D8 FF E0 00 10 4A 46 49 46 00 01`, `FF D8 FF EE`.

Encrypted magic bytes:
```
$ xxd my_magic_bytes.jpg.enc|head
00000000: b914 0645 71e0 b5f7 3707 cb85 47cc f9a4  ...Eq...7...G...
```

### XOR the Key

Here's a bash XOR function:

```bash
# XOR function written by colinhb
# https://stackoverflow.com/a/55986217
xor() {
  {
    echo "${1}" | # start pipeline with first parameter
      fold -w 16 | # break into 16 char lines (note: 4-bit hex char * 16 = 64 bits)
      sed 's/^/0x/' | # prepend '0x' to lines to tell shell their hex numbers
      nl # number the lines (we do this to match corresponding ones)
    echo "${2}" | # do all the same to the second parameter
      fold -w 16 | 
      sed 's/^/0x/' | 
      nl
  } | # coming into this pipe we have lines: 1,...,n,1,...,n 
  sort -n | # now sort so lines are: 1,1,...,n,n
  cut -f 2 | # cut to keep only second field (blocks), ditching the line numbers
  paste - - | # paste to join every-other line with tabs (now two-field lines)
  while read -r a b; do # read lines, assign 'a' and 'b' to the two fields 
    printf "%#0${#a}x" "$(( a ^ b ))" # do the xor and left-pad the result
  done |
  sed 's/0x//g' | # strip the leading '0x' (here for clarity instead of in the loop)
  paste -s -d '\0' - # join all the blocks back into to a big hex string
}
```

Here are the potential keys based on the different file signatures:
```bash
$ xor FFD8FFDB b9140645
46ccf99e
$ xor FFD8FFEE b9140645
46ccf9ab
$ xor FFD8FFE000104A4649460001 b914064571e0b5f73707cb85
46ccf9a571f0ffb17e41cb84
```

Let's dump the encrypted file into a one line file called `hex`.
```bash
$ xxd -p my_magic_bytes.jpg.enc | tr -d '\n' > hex
```

Now let's modify a Python script from [Open Tech Notes](https://opentechnotes.blogspot.com/2014/08/xor-string-with-key-in-python.html) to XOR a String or File with a Key.

```py
# Adapted from http://opentechnotes.blogspot.com/2014/08/xor-string-with-key-in-python.html
from itertools import cycle
import sys

def do_xor(key, message):
    message = message.replace(' ', '').decode('hex')
    key = ''.join(key.split()[::-1]).decode('hex')

    return ''.join([chr(ord(a) ^ ord(b)) for a,b in zip(message, cycle(key))])

msg_file = sys.argv[1]
key = sys.argv[2]

with open(msg_file, 'rb') as f:
    message  = f.read()
f.close()

print do_xor(key,message).encode("hex")
```

Next, let's try our different keys.

```bash
$ python XOR-hex.py hex 46ccf99e | xxd -r -p > image1.jpg; file image.jpg
image1.jpg: JPEG image data
$ python XOR-hex.py hex 46ccf9ab | xxd -r -p > image2.jpg; file image.jpg
image.jpg: JPEG image data
$ python XOR-hex.py hex 46ccf9a571f0ffb17e41cb84 | xxd -r -p > image3.jpg; file image3.jpg
image3.jpg: JPEG image data, JFIF standard 1.01, aspect ratio, density 1x1, segment length 16, progressive, precision 8, 500x500, components 3
```

The file with the most information is likely our answer. Checking though, image1.jpg and image2.jpg do not open but image3.jpg does and it contains our flag.

![flag](/images/ctf/247/my_magic_bytes.png)
