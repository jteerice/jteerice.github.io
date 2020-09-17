---
layout: post
title: eps1.91_redwheelbarr0w.txt - Multiplication Table Solution
---

On the last page of *eps1.91_redwheelbarr0w.txt*, is another challenge. In the May 26th entry in the journal, Elliot mentions waking up to Mr. Robot doing a bunch of multiplication tables. Later that day, Mr. Robot takes the journal from him, and Leon talks to a Dark Army agent. So, I checked the back page of the journal/composition notebook for a multiplication table.

The multiplication table in the back of the book has an additional row and column. It also has the letters AN written on the top left around the `1` and the letters MZ written at the end columns and rows near the `13`'s.

![multiplication-table](/images/red_wheelbarrow/multiplication-table.JPG)

AN and MZ were familiar because I've solved ROT13 ciphers with the `tr` command before, e.g.:
```
echo nopqrst | tr '[a-z]' '[n-za-m]'
abcdefg
```

There also are numbers imprinted on the opposite page, likely the encoded message.

![imprint](/images/red_wheelbarrow/imprint.JPG)

```
2 33 8 10 0 54 0 20 55
0 9 0 15 14 25 36 0 63
0 90 144 0 10 0 8 5 0
9 0 63 65 0 15 63 27
12 0 32 0 104 42 0 10
0 5 5 0 2 33 24 0
6 27 108 84
```

With numbers as the ciphertext opposite from the multiplication table, the table began to seem like a number-based tabula recta. There are only 13 rows/columns and given the multiple written characters, the letters must repeat, i.e. `1`-`13` would match up for both A-M and N-Z. `0` is notably absent on the table, and I thought it was likely to be punctuation or spacing given the frequency.

![multiplication-table-annotated](/images/red_wheelbarrow/multiplication-table-annotated
.jpg)

Some numbers like `8` or `36` show up in several places on the chart, and there was no clear way to decipher which place was correct. Then, at each position there were two letters possible from both the row and the column that could combine for the message. Here is an example of `8`:

![multiplication-table-annotated2](/images/red_wheelbarrow/multiplication-table-annotated2.jpg)

The message in `8` could be some combination of any of the letters in the rows and columns (`AN`, `BO`, `DQ`, or `HU`). There was also no guarantee that repeated numbers had the same hidden characters, though some ended up being so. To save time, I created a Python program to generate a list of the potential combinations.

```py
import sys

if len(sys.argv) < 2:
	print 'usage: python solve.py <args>'
	exit()

strings = sys.argv[2:]
res = str(sys.argv[1]) + ': ' + str(strings) + " :"

for i in range(len(strings)):
	for j in range(i+1, len(strings)):

		res += " " + strings[i][0] + strings[j][0]
		res += " " + strings[i][0] + strings[j][1]
		res += " " + strings[i][1] + strings[j][0]
		res += " " + strings[i][1] + strings[j][1]

		res += " " + strings[j][0] + strings[i][0]
		res += " " + strings[j][0] + strings[i][1]
		res += " " + strings[j][1] + strings[i][0]
		res += " " + strings[j][1] + strings[i][1]

print res
```

Luckily there were repeated numbers which saved me some time. Here was my output for each number in the message organized by line:

```md
# First Line - 2 33 8 10 0 54 0 20 55
2: ['AN', 'BO'] : AB AO NB NO BA BN OA ON
33: ['KX', 'CP'] : KC KP XC XP CK CX PK PX
8: ['AN', 'BO', 'DQ', 'HU'] : AB AO NB NO BA BN OA ON AD AQ ND NQ DA DN QA QN AH AU NH NU HA HN UA UN BD BQ OD OQ DB DO QB QO BH BU OH OU HB HO UB UO DH DU QH QU HD HQ UD UQ
10: ['AN', 'BO', 'ER', 'JW'] : AB AO NB NO BA BN OA ON AE AR NE NR EA EN RA RN AJ AW NJ NW JA JN WA WN BE BR OE OR EB EO RB RO BJ BW OJ OW JB JO WB WO EJ EW RJ RW JE JR WE WR
0: 
54: ['IV', 'FS'] : IF IS VF VS FI FV SI SV
0: 
20: ['BO', 'DQ', 'ER', 'JW'] : BD BQ OD OQ DB DO QB QO BE BR OE OR EB EO RB RO BJ BW OJ OW JB JO WB WO DE DR QE QR ED EQ RD RQ DJ DW QJ QW JD JQ WD WQ EJ EW RJ RW JE JR WE WR
55: ['ER', 'KX'] : EK EX RK RX KE KR XE XR

# Second Line - 0 9 0 15 14 25 36 0 63
0: 
9: ['AN', 'IV', 'CP', 'CP'] : AI AV NI NV IA IN VA VN AC AP NC NP CA CN PA PN AC AP NC NP CA CN PA PN IC IP VC VP CI CV PI PV IC IP VC VP CI CV PI PV CC CP PC PP CC CP PC PP
0: 
15: ['CP', 'ER'] : CE CR PE PR EC EP RC RP
14: ['BO', 'GT'] : BG BT OG OT GB GO TB TO
25: ['ER', 'ER'] : EE ER RE RR EE ER RE RR
36: ['IV', 'DQ', 'LY', 'CP', 'FS', 'FS'] : ID IQ VD VQ DI DV QI QV IL IY VL VY LI LV YI YV IC IP VC VP CI CV PI PV IF IS VF VS FI FV SI SV IF IS VF VS FI FV SI SV DL DY QL QY LD LQ YD YQ DC DP QC QP CD CQ PD PQ DF DS QF QS FD FQ SD SQ DF DS QF QS FD FQ SD SQ LC LP YC YP CL CY PL PY LF LS YF YS FL FY SL SY LF LS YF YS FL FY SL SY CF CS PF PS FC FP SC SP CF CS PF PS FC FP SC SP FF FS SF SS FF FS SF SS
0: 
63: ['GT', 'IV'] : GI GV TI TV IG IT VG VT

# Third Line - 0 90 144 0 10 0 8 5 0
0: 
90: ['JW', 'IV'] : JI JV WI WV IJ IW VJ VW
144: ['LY', 'LY'] : LL LY YL YY LL LY YL YY
0: 
10: ['AN', 'BO', 'ER', 'JW'] : AB AO NB NO BA BN OA ON AE AR NE NR EA EN RA RN AJ AW NJ NW JA JN WA WN BE BR OE OR EB EO RB RO BJ BW OJ OW JB JO WB WO EJ EW RJ RW JE JR WE WR
0: 
8: ['AN', 'BO', 'DQ', 'HU'] : AB AO NB NO BA BN OA ON AD AQ ND NQ DA DN QA QN AH AU NH NU HA HN UA UN BD BQ OD OQ DB DO QB QO BH BU OH OU HB HO UB UO DH DU QH QU HD HQ UD UQ
5: ['AN', 'ER'] : AE AR NE NR EA EN RA RN
0: 

# Fourth Line - 9 0 63 65 0 15 63 27
9: ['AN', 'IV', 'CP', 'CP'] : AI AV NI NV IA IN VA VN AC AP NC NP CA CN PA PN AC AP NC NP CA CN PA PN IC IP VC VP CI CV PI PV IC IP VC VP CI CV PI PV CC CP PC PP CC CP PC PP
0: 
63: ['GT', 'IV'] : GI GV TI TV IG IT VG VT
65: ['ER', 'MZ'] : EM EZ RM RZ ME MR ZE ZR
0: 
15: ['CP', 'ER'] : CE CR PE PR EC EP RC RP
63: ['GT', 'IV'] : GI GV TI TV IG IT VG VT
27: ['CP', 'IV'] : CI CV PI PV IC IP VC VP

# Fifth Line - 12 0 32 0 104 42 0 10
12: ['CP', 'DQ', 'BO', 'FS', 'AN', 'LY'] : CD CQ PD PQ DC DP QC QP CB CO PB PO BC BP OC OP CF CS PF PS FC FP SC SP CA CN PA PN AC AP NC NP CL CY PL PY LC LP YC YP DB DO QB QO BD BQ OD OQ DF DS QF QS FD FQ SD SQ DA DN QA QN AD AQ ND NQ DL DY QL QY LD LQ YD YQ BF BS OF OS FB FO SB SO BA BN OA ON AB AO NB NO BL BY OL OY LB LO YB YO FA FN SA SN AF AS NF NS FL FY SL SY LF LS YF YS AL AY NL NY LA LN YA YN
0: 
32: ['DQ', 'HU'] : DH DU QH QU HD HQ UD UQ
0: 
104: ['HU', 'MZ'] : HM HZ UM UZ MH MU ZH ZU
42: ['GT', 'FS'] : GF GS TF TS FG FT SG ST
0: 
10: ['AN', 'BO', 'ER', 'JW'] : AB AO NB NO BA BN OA ON AE AR NE NR EA EN RA RN AJ AW NJ NW JA JN WA WN BE BR OE OR EB EO RB RO BJ BW OJ OW JB JO WB WO EJ EW RJ RW JE JR WE WR

# Sixth Line - 0 5 5 0 2 33 24 0
0: 
5: ['AN', 'ER'] : AE AR NE NR EA EN RA RN
5: ['AN', 'ER'] : AE AR NE NR EA EN RA RN
0: 
2: ['AN', 'BO'] : AB AO NB NO BA BN OA ON
33: ['KX', 'CP'] : KC KP XC XP CK CX PK PX
24: ['BO', 'LY', 'CP', 'HU', 'DQ', 'FS'] : BL BY OL OY LB LO YB YO BC BP OC OP CB CO PB PO BH BU OH OU HB HO UB UO BD BQ OD OQ DB DO QB QO BF BS OF OS FB FO SB SO LC LP YC YP CL CY PL PY LH LU YH YU HL HY UL UY LD LQ YD YQ DL DY QL QY LF LS YF YS FL FY SL SY CH CU PH PU HC HP UC UP CD CQ PD PQ DC DP QC QP CF CS PF PS FC FP SC SP HD HQ UD UQ DH DU QH QU HF HS UF US FH FU SH SU DF DS QF QS FD FQ SD SQ
0: 

# Seventh Line - 6 27 108 84
6: ['AN', 'FS', 'BO', 'CP'] : AF AS NF NS FA FN SA SN AB AO NB NO BA BN OA ON AC AP NC NP CA CN PA PN FB FO SB SO BF BS OF OS FC FP SC SP CF CS PF PS BC BP OC OP CB CO PB PO
27: ['CP', 'IV'] : CI CV PI PV IC IP VC VP
108: ['IV', 'LY'] : IL IY VL VY LI LV YI YV
84: ['LY', 'GT'] : LG LT YG YT GL GY TL TY
```

I considered writing another script to output all the possible strings, but I felt that sorting through the output wouldn't be any more efficient than trying to assemble a message by hand.

```md
# First Line - 2 33 8 10 0 54 0 20 55
2: BA
33: CK
8: DO
10: OR
0: 
54: IS
0: 
20: WO
55: RK

# Second Line - 0 9 0 15 14 25 36 0 63
0: 
9: IN
0: 
15: PR
14: OG
25: RE
36: SS
0: 
63: IT

# Third Line - 0 90 144 0 10 0 8 5 0
0: 
90: WI
144: LL
0: 
10: BE
0: 
8: DO
5: NE
0: 

# Fourth Line - 9 0 63 65 0 15 63 27
9: IN
0: 
63: TI
65: ME
0: 
15: CR
63: IT
27: IC

# Fifth Line - 12 0 32 0 104 42 0 10
12: AL
0: 
32: HQ
0: 
104: MU
42: ST
0: 
10: BE

# Sixth Line - 0 5 5 0 2 33 24 0
0: 
5: NE
5: AR
0: 
2: BA
33: CK
24: UP
0: 

# Seventh Line - 6 27 108 84
6: FA
27: CI
108: LI
84: TY
```
Some parts were trickier than others, but using `0` as a space made some answers obvious, e.g. `IS`, `IN`, `IT`, `BE`, `HQ`. I'm pretty confident I found the right message.

```md
# By Line
BACKDOOR IS WORK IN
 PROGRESS IT
 WILL BE DONE 
IN TIME CRITIC
AL HQ MUST BE
 NEAR BACKUP 
FACILITY

# One Line
BACKDOOR IS WORK IN PROGRESS IT WILL BE DONE IN TIME CRITICAL HQ MUST BE NEAR BACKUP FACILITY
```

The cleaned up final message reads:
> Backdoor is work in progress; it will be done in time. Critical HQ must be near backup facility.