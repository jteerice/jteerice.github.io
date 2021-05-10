---
layout: post
title: eps1.91_redwheelbarr0w.txt - Mysterious Envelope Solution
---

Included in the pages of *eps1.91_redwheelbarr0w.txt* is a mysterious envelope. The journal mentions that the envelope arrives with no message inside it. On the outside there is standard postmarking plus a message from Hot Carla.

![outside](/images/red_wheelbarrow/envelope-out.png)

Checking the inside, the text `BANK OF E SAVINGS AND LOAN` is repeated ad infinitum. Except, in one section there are a lot of spelling errors and missing spaces at seemingly random parts of the phrase.

![inside](/images/red_wheelbarrow/envelope-in-annotated.png)

Curious... I started writing out which characters were missing in each line. After finding 3 spaces is a row, I was pretty sure I was on the wrong path. I continued a little while longer just to check: `AND_CD___INAENDB`. I then had the idea to count the number of characters in the phrase.
```
$ echo -n "BANK OF E SAVINGS AND LOAN" | wc -c
26
```
What else has 26 characters? The English alphabet. For each wonky string, I wrote down the index of the missing character (0-25). For example: the string `ANK OF E SAVINGS AND LOAN` becomes `0`, and the string `BANKOF E SAVINGS AND LOAN` becomes `4`. I then translated that into the corresponding letter at that position in the alphabet using Python.


```py
>>> positions = [24, 14, 20, 17, 2, 20, 17, 17, 4, 13, 19, 18, 8, 19, 20, 0, 19, 8, 14, 13, 2, 0, 13, 13, 14, 19, 0, 5, 5, 4, 2, 19, 18, 19, 0, 6, 4, 19, 22, 14, 19, 14, 2, 14, 12, 12, 20, 13, 8, 2, 0, 19, 4, 20, 18, 4, 3, 4, 0, 3, 3, 17, 14, 15, 8, 13, 11, 8, 1, 17, 0, 17, 24, 4, 13, 2, 24, 2, 11, 14, 15, 4, 3, 8, 0, 21, 14, 11, 19, 22, 14, 13, 4, 23, 19, 12, 4, 18, 18, 0, 6, 4, 8, 13, 22, 14, 17, 3, 18, 4, 0, 17, 2, 7]
>>> result = ''
>>> for num in positions:
...     result += chr(num + 97) # 0->a, 1->b, etc
...
>>> print result
yourcurrentsituationcannotaffectstagetwotocommunicateusedeaddropinlibraryencyclopediavoltwonextmessageinwordsearch
```

The cleaned up final message reads:
> Your current situation cannot affect Stage Two. To communicate, use dead drop in library Encyclopedia, Vol. 2. Next message in word search.