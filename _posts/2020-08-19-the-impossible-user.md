---
layout: post
title: 247/CTF - THE IMPOSSIBLE USER
---

## Prompt
This encryption service will encrypt almost any plaintext. Can you abuse the implementation to actually encrypt every plaintext?

## Source
```py
from Crypto.Cipher import AES
from flask import Flask, request
from secret import flag, aes_key, secret_key

app = Flask(__name__)
app.config['SECRET_KEY'] = secret_key
app.config['DEBUG'] = False
flag_user = 'impossible_flag_user'

class AESCipher():
    def __init__(self):
        self.key = aes_key
        self.cipher = AES.new(self.key, AES.MODE_ECB)
        self.pad = lambda s: s + (AES.block_size - len(s) % AES.block_size) * chr(AES.block_size - len(s) % AES.block_size)
        self.unpad = lambda s: s[:-ord(s[len(s) - 1:])]

    def encrypt(self, plaintext):
        return self.cipher.encrypt(self.pad(plaintext)).encode('hex')

    def decrypt(self, encrypted):
        return self.unpad(self.cipher.decrypt(encrypted.decode('hex')))

@app.route("/")
def main():
    return "
%s
" % open(__file__).read()

@app.route("/encrypt")
def encrypt():
    try:
        user = request.args.get('user').decode('hex')
        if user == flag_user:
            return 'No cheating!'
        return AESCipher().encrypt(user)
    except:
        return 'Something went wrong!'

@app.route("/get_flag")
def get_flag():
    try:
        if AESCipher().decrypt(request.args.get('user')) == flag_user:
            return flag
        else:
            return 'Invalid user!'
    except:
        return 'Something went wrong!'

if __name__ == "__main__":
  app.run()
```

## Solution

At `/` the source code is read from the file, which is how we are able to see it. At `/encrypt`, a user parameter is decoded from hex to string. If the `user != 'impossible_flag_user'`, the string is encrypted with an AESCipher. At `/get_flag` if the supplied use parameter can be decrypted into 'impossible_flag_user', the flag will be returned.

We want to encrypt 'impossible_flag_user', but that's the one thing we can't pass into the `encrypt()` function:

```bash
$ python3
Python 3.7.3 (default, Jul 25 2020, 13:03:44)
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 'impossible_flag_user'.encode("utf-8").hex()
'696d706f737369626c655f666c61675f75736572'
>>>
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=696d706f737369626c655f666c61675f75736572
No cheating!
```

So how do we encrypt this? On a closer read of the source, the AES cipher is using MODE.ECB. ECB (Electronic Code Book) is a notoriously poor encryption method (which coincidentally [Zoom uses](https://www.zdnet.com/article/zoom-concedes-custom-encryption-is-sub-standard-as-citizen-lab-pokes-holes-in-it/)).

![ECB](https://miro.medium.com/max/875/0*KVvdWAhe4krGhY03.png)

In ECB, the plaintext is divided into blocks of the same length with the standard length of 128 for AES. AES.MODE_ECB needs to pad data until it is the same length as the block (similar to the equal signs `=` at the end of base64 encoded strings). Every block is encrypted with the same `secret_key` from the app.config file and the same algorithm. If we encrypt the same plaintext, we will get the same ciphertext.

The first step is to check the actual block length. From there we can perhaps slip in our flag_user string to be encrypted. We can find the block size by increasing the length of our plaintext until the length of the ciphertext doubles.

```
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=0
Something went wrong!
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=00
acd6f9b60178266c227beb5b32b2b2b1
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=000
Something went wrong!
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=0000
7f66a2c7f33a59f0e2f4bf49c10e8ebb
...
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=000000000000000000000000000000
89a270471cdfca1286a49873dc68c5e9
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=00000000000000000000000000000000
a46f1da3a75f394ab02f44283ef87d562f28487624c5f1476e9fb265d2b47349
$ echo "00000000000000000000000000000000" | awk '{print length}'
32
```
We learn early on that we have to supply multiples of full bytes--even numbers of characters only. It appears we have 32 '0's or 16 pairs of '00' which means a 16-byte block length.

Our hex encoded 'impossible_flag_user' string is 40 hex digits which equals 20 bytes (hex digits are 4 bits and there are 8 bits to a byte). And 20 bytes requires two 16-byte blocks.
```bash
$ echo 696d706f737369626c655f666c61675f75736572 | awk '{print length}'
40
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=$(python -c "print ('0'*40)")
a46f1da3a75f394ab02f44283ef87d565916f7c1bc3ab529b2e411b514db4f29
```

We can't pass in `696d706f737369626c655f666c61675f75736572` alone due to the program logic, and we can't pass it first because the padding we supply afterward will affect the output of that block. Thus, we must put padding beforehand and let ECB pad our ending 20-byte string. Let's pad the front with 16 bytes using Python and append our encoded string.

```bash
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=$(python -c "print ('00'*16)")696d706f737369626c655f666c61675f75736572
a46f1da3a75f394ab02f44283ef87d56939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=$(python -c "print ('01'*16)")696d706f737369626c655f666c61675f75736572
c4deb6954f0bdce61c92be5ee5295240939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=$(python -c "print ('02'*16)")696d706f737369626c655f666c61675f75736572
bf8bb43ed63a4f2c7c5abd389f05e20e939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
$ curl https://8101e13c1ba0ee83.247ctf.com/encrypt?user=$(python -c "print ('03'*16)")696d706f737369626c655f666c61675f75736572
d2eb25d914c50480b074bda4253790f3939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
```

Trying different paddings of the same length, we can see the output has different first blocks but the same following two blocks. 
```
a46f1da3a75f394ab02f44283ef87d56|939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
c4deb6954f0bdce61c92be5ee5295240|939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
bf8bb43ed63a4f2c7c5abd389f05e20e|939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
d2eb25d914c50480b074bda4253790f3|939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
```

`939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d` looks like our string! Let's send it to `/get_flag` and confirm.

```bash
$ curl https://8101e13c1ba0ee83.247ctf.com/get_flag?user=939454b054b7379b0709a270b894025c707ece4f0913868ec5df07d131b0822d
247CTF{ddd01e396dc{censored}43f3968aa39}
```