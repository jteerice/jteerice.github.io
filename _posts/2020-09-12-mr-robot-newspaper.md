---
layout: post
title: eps1.91_redwheelbarr0w.txt - Newspaper Solution
---

Inside *eps1.91_redwheelbarr0w.txt*, there is a newspaper clipping with Wellick sightings on the front and a word search on the back that Mr. Robot wanted to get his hands on.

**Front**:
![newspaper-front](/images/red_wheelbarrow/newspaper-front.JPG)
**Back**:
![newspaper-back](/images/red_wheelbarrow/newspaper-back.JPG)

My first observation was that the word search has suspiciously short words. I then noticed that the first 5 letters were `ROTXV` and the last 8 letters were `ENDROTXV`.
```
# Original
ROTXVDETGPIXD
CWFIDQTSTITGB
XCTSJEDCRWDXR
TDUTKXARDGEQP
RZJEUPRXAXING
TFJTHIHIPIJHD
UQPRZSDDGXBEA
TBTCIPIXDCADD
ZUDGCTMIBTHHP
VTXCEGPNTGEPB
EWATIENDROTXV

# One Line
ROTXVDETGPIXDCWFIDQTSTITGBXCTSJEDCRWDXRTDUTKXARDGEQPRZJEUPRXAXINGTFJTHIHIPIJHDUQPRZSDDGXBEATBTCIPIXDCADDZUDGCTMIBTHHPVTXCEGPNTGEPBEWATIENDROTXV

# One Line, removing ROTXV and ENDROTXV
DETGPIXDCWFIDQTSTITGBXCTSJEDCRWDXRTDUTKXARDGEQPRZJEUPRXAXINGTFJTHIHIPIJHDUQPRZSDDGXBEATBTCIPIXDCADDZUDGCTMIBTHHPVTXCEGPNTGEPBEWATI

# Use my rotsolver script for plaintext
$ rotsolver DETGPIXDCWFIDQTSTITGBXCTSJEDCRWDXRTDUTKXARDGEQPRZJEUPRXAXINGTFJTHIHIPIJHDUQPRZSDDGXBEATBTCIPIXDCADDZUDGCTMIBTHHPVTXCEGPNTGEPBEWATI | grep 15
OPERATIONHQTOBEDETERMINEDUPONCHOICEOFEVILCORPBACKUPFACILITYREQUESTSTATUSOFBACKDOORIMPLEMENTATIONLOOKFORNEXTMESSAGEINPRAYERPAMPHLET ; ROT15
```
The cleaned up final message reads:
> Operation HQ to be determined upon choice of Evil Corp backup facility. Request status of backdoor implementation. Look for next message in prayer pamphlet.

