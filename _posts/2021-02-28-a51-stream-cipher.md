---
layout: post
title: A5/1 Stream Cipher Implementation
---
## What is A5/1?
A5/1 is a stream cipher used to provide over-the-air communication privacy in the GSM cellular telephone standard. It is one of seven algorithms which were specified for GSM use. It was initially kept secret, but became public knowledge through leaks and reverse engineering. A number of serious weaknesses in the cipher have been identified.

A GSM transmission is organized as sequences of _bursts_. In a typical channel and in one direction, one burst is sent every 4.615 milliseconds and contains 114 bits available for information. A5/1 is used to produce for each burst a 114 bit sequence of [keystream](https://en.wikipedia.org/wiki/Keystream "Keystream") which is [XORed](https://en.wikipedia.org/wiki/XOR "XOR") with the 114 bits prior to modulation. A5/1 is initialized using a 64-bit [key](https://en.wikipedia.org/wiki/Key_(cryptography) "Key (cryptography)") together with a publicly known 22-bit frame number.

A5/1 is based around a combination of three [linear feedback shift registers](https://en.wikipedia.org/wiki/Linear_feedback_shift_register "Linear feedback shift register") (LFSRs) with irregular clocking. The three shift registers are specified as follows:
| LFSR number | Length in bits |              Feedback polynomial              | Clocking bit |   Tapped bits  |
|:-----------:|:--------------:|:---------------------------------------------:|:------------:|:--------------:|
| 1           | 19             | x<sup>19</sup>+x<sup>18</sup>+x<sup>17</sup>+x<sup>14</sup>+1</sup>       | 8            | 13, 16, 17, 18 |
| 2           | 22             |  x<sup>22</sup>+x<sup>21</sup>+1</sup>           | 10           | 20, 21         |
| 3           | 23             |  x<sup>23</sup>+x<sup>22</sup>+x<sup>21</sup>+x<sup>8</sup>+1</sup> | 10           | 7, 20, 21, 22  |
A register is clocked if its clocking bit (orange) agrees with the clocking bit of one or both of the other two registers. 
<p align="center">
	<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/A5-1_GSM_cipher.svg/350px-A5-1_GSM_cipher.svg.png">  
</p>
Hence at each step at least two or three registers are clocked, and each register steps with probability 3/4.

> Source: [Wikipedia](https://en.wikipedia.org/wiki/A5/1)

## Finding the Keystream
Suppose that, after a particular step, the values in the registers are:

X = (x<sub>0</sub>, x<sub>1</sub>, . . . , x<sub>18</sub>) = (1010101010101010101)
Y = (y<sub>0</sub>, y<sub>1</sub>, . . . , y<sub>21</sub>) = (1100110011001100110011) 
Z = (z<sub>0</sub>, z<sub>1</sub>, . . . , z<sub>22</sub>) = (11100001111000011110000)

Our goal is to print the next keystream bits, so that if we had some ciphertext, we could use XOR to decode it.

### Implementation
```python
def main():
    numKeystreamBits = 114
    
    # Initialize
    x = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
    y = [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]
    z = [1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0]

    keystream = ""

    print("Starting State:")
    printState(x,y,z)

    for i in range(numKeystreamBits):
        majority = vote(x[8], y[10], z[10])
        if (x[8] == majority):
            clockedX(x)
        if (y[10] == majority):
            clockedY(y)
        if (z[10] == majority):
            clockedZ(z)
        
        # Keystream bit defined by last bit of each LFSR
        keystream = str(x[len(x)-1] ^ y[len(y)-1] ^ z[len(z)-1]) + keystream

    print("Ending State:")
    printState(x, y, z)

    print(str(numKeystreamBits) + "-bit keystream: " + keystream)

# X register is clocked
def clockedX(x):
    newBit = x[13] ^ x[16] ^ x[17] ^ x[18]
    return shift(x, newBit)

def clockedY(y):
    newBit = y[20] ^ y[21]
    return shift(y, newBit)

def clockedZ(z):
    newBit = z[7] ^ z[20] ^ z[21] ^ z[22]
    return shift(z, newBit)

def shift(arr, newBit):
    # print("arr:    "+ str(arr))
    arr.pop(-1) # pop off the last element
    arr.insert(0, newBit) # add new bit to the front
    return arr

# Find if 0 or 1 is more popular across x[8], y[10], and z[10] (aka the clocking bits)
def vote(xBit,yBit,zBit):
    
    return (xBit & yBit) ^ (xBit & zBit) ^ (yBit & zBit)

def printState(x,y,z):
    print("x: " + "".join(map(str, x)))
    print("y: " + "".join(map(str, y)))
    print("z: " + "".join(map(str, z)))

if __name__ == "__main__":
    main()
```

### Output
```
Starting State:
x: 1010101010101010101
y: 1100110011001100110011
z: 11100001111000011110000
Ending State:
x: 1000101010101011110
y: 0000000000000010000000
z: 00001111001010000100100
114-bit keystream: 010110101011111110011000011101000111001110000100101000101010100111000101110111100110011000000111100000111011000001
```