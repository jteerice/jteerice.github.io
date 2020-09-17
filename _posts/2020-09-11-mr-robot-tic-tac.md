---
layout: post
title: eps1.91_redwheelbarr0w.txt - Tic-tac-toe Solution
---

There's a page ripped out of Tolstoy's *Resurrection* with many games of tic-tac-toe in the margins that's tucked inside the pages of *eps1.91_redwheelbarr0w.txt*.

**Front**:
![first-page](/images/red_wheelbarrow/tic.JPG)

**Back**:
![second-page](/images/red_wheelbarrow/tac.JPG)

In most of the games, `O` looks one turn away from winning against `X`. There are always two `X`'s and 1-3 `O`'s. The one game where `X` plays 3 times is crossed out, and the `X` in the top-right corner is replaced with an `O`. There are also games where the 2 `X`'s are in the same place and the `O`'s are placed differently. My first inclination was that this was a pigpen cipher, based on the location of the two `X`'s. 

I decided to assign letters to the different arrangements of `X`'s in the hope that there were enough characters for the frequency analysis built into [quipqiup.com](quipqiup.com) to decipher the plaintext.
```
X|X|   X| |    | |    | |X   | |    | |    | |X  X| |X   | |   X| |    | |    | |    |X| 
 | |    | |    | |X   | |    | |   X| |    | |    | |    | |    | |   X| |    | |    | |  
 | |   X| |   X| |    |X|   X|X|    |X|   X| |    | |   X| |X   |X|   X| |    |X|X   |X|  
  A      B      C      D      E      F      G      H      I      J      K      L      M

X| |    | |    | |    | |X   | |    | |X   |X|    | |    | |    | |    | |    | |    | |  
X| |    | |X  X| |X  X| |   X| |    | |X  X| |    | |    | |    | |    | |    | |    | | 
 | |    |X|    | |    | |    | |X   | |    | |    | |    | |    | |    | |    | |    | |  
  N      O      P      Q      R      S      T      U      V      W      X      Y      Z
```
I wrote out the corresponding characters on each page left-to-right and top-to-bottom. I spaced them apart in my notes in the same shape as they appear on the pages, so I could easily find my place.
```
# Page 1
ABCDAEF
GDHIJK
EILDMG
BCBADMJ
NCCHIBJ
E
A
B
N
I
O
P
NCBIKDP

# Page 2
DPDQHD
R
A
R
A
E
L
D
A
S
N
R
A
E
AHRHTM
EAD

# All Together
ABCDAEFGDHIJKEILDMGBCBADMJNCCHIBJEABNIOPNCBIKDPDPDQHDRARAELDASNRAEAHRHTMEAD
```
I pasted my string into [quipqiup.com](quipqiup.com), selected statistics mode, and received an answer:
```
TIMETABLE UNCHANGED LIMITED COMMUNICATION FROM IN HERE REQUEST STAGE TWO STATUS UPDATE
```

The cleaned up final message reads:

> Timetable unchanged. Limited communication from in here. Request stage two status update.