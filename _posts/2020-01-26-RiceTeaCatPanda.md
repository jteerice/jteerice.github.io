---
layout: post
title: CTF - RiceTeaCatPanda
---
CTF location: riceteacatpanda.wtf
## Cryptography
### Title: Don't Give The GIANt a COOKie
Description: It was just a typical day in the bakery for Delphine. She was preparing her famous chocolate cake, when all of a sudden a GIANt burst through the doors of her establishment and demanded a cookie. Being the strong-willed girl she was, Delphine refused and promptly threw her rolling pin at the GIANt. Doing what any sensible being would do when faced with projectiles, the GIANt let out a shriek and ran out of the shop. Delphine smiled to herself, it was another day well done. But oh? What's this? It seems the GIANt dropped this behind while he was screaming and scrambling out of the shop.

69acad26c0b7fa29d2df023b4744bf07
```
$ echo '69acad26c0b7fa29d2df023b4744bf07' > hashes
$ hashcat -m 0 ./hashes /usr/share/wordlists/rockyou.txt --force
...
69acad26c0b7fa29d2df023b4744bf07:chocolate mmm
...
rtcp{chocolate_mmm}
```
## General Skills
### Title: Come Eat Grandma

Description: 
Oh, my bad, this spreadsheet appears to be missing its commas.
 
Go to the google spreadsheet version history (only visible if logged in with a google account). The second version contains the following line:
```
rtcp{D0n't_E^t_Gr4NDmA_734252}
```
## Web
### Robots. Yeah, I know, pretty obvious.
Description: So, we know that Delphine is a cook. A  wonderful one, at that. But did you know that GIANt used to make robots?  Yeah, GIANt robots.
```
https://riceteacatpanda.wtf/robots.txt
User-agent: *
Disallow: 
/robot-nurses
/flag

https://riceteacatpanda.wtf/robot-nurses
rtcp{r0b0t5_4r3_g01ng_t0_t4k3_0v3r_4nd_w3_4r3_s0_scr3w3d}
```
## Forensics
### BTS-Crazed
Description: My friend made this cool remix, and it's  pretty good, but everyone says there's a deeper meaning in the music.  To be honest, I can't really tell - the second drop's 808s are just too epic. https://github.com/JEF1056/riceteacatpanda/raw/master/BTS-Crazed (75)/Save Me.mp3
```
$ strings Save\ Me.mp3 | grep -oE "rtcp{.*}"
rtcp{j^cks0n_3ats_r1c3}
```
### Allergic College Application
Description: I was writing my common app essay in Mandarin when my cat got on my lap and sneezed. Being allergic, I sneezed with him, and when I blew my nose into a tissue, the text for my essay turned really weird! Get out, Bad Kitty!
```
$ wget "https://riceteacatpanda.wtf/files/8959389a6bf2afe7e9dcf65c7545f799/Common_App_Essay.txt?token=eyJ0ZWFtX2lkIjpudWxsLCJ1c2VyX2lkIjoyMTgxLCJmaWxlX2lkIjo1fQ.Xj8hVw.O8bCYY5GuX2tddvJvDBu0OZq5to"
$ mv Common_App_Essay.txt\?token\=eyJ0ZWFtX2lkIjpudWxsLCJ1c2VyX2lkIjoyMTgxLCJmaWxlX2lkIjo1fQ.Xj8hVw.O8bCYY5GuX2tddvJvDBu0OZq5to app
$ python3
>>> f = open ('app', encoding='gb2312').readlines()
>>> f
end of output: {我_只_修改_了_两_次}
OR
cat app | iconv -f GBK -t UTF-8

rtcp{我_只_修改_了_两_次}
```
### cat-chat
Description: nyameowmeow nyameow nyanya meow purr  nyameowmeow nyameow nyanya meow purr nyameowmeow nyanyanyanya nyameow  meow purr meow nyanyanyanya nya purr nyanyanyanya nya meownyameownya  meownyameow purr nyanya nyanyanya purr meowmeownya meowmeowmeow nyanya  meownya meowmeownya purr meowmeowmeow meownya purr nyanyanyanya nya  nyameownya nya !!!!


nya and meow are repeated a lot together, trial and error led to nya being `.` and meow being `-` in morse code. I tested and wrote a `sed` command to parse cat-chat into morse which I saved into meow_to_morse.sh: `sed 's/nya/./g;s/meow/-/g;s/purr//g'`

I downloaded a morse decoder from git.
```
git clone https://github.com/mk12/morse.git /opt/morse
cd $_
make
ln -s /opt/morse/bin/morse ~/bin/morse
```
I also copied all the chat from the discord channel into the file meows.txt.
```
$ cat meows.txt | ./meow_to_morse.sh | morse -d | grep RTCP |  sed 's/?/_/g'  #output is in all caps
RTCP:TH15_1Z_A_C4T_CH4T_N0T_A_M3M3_CH4T

rtcp{TH15_1Z_A_C4T_CH4T_N0T_A_M3M3_CH4T}
```
### catch-at
Description: 636274425917865984

Navigate to https://discordapp.com/channels/624036526157987851/633364891616411667/636274425917865984

Copy output from message at the id 636274425917865984: 
```
$ echo "meowmeowmeow nyanyanyanya purr meownyanyanya meownyameowmeow purr meow nyanyanyanya nya purr nyameowmeow nyameow meownyameowmeow meowmeownyanyameowmeow purr nyanyanyanya nya nyameownya nya nyameowmeowmeowmeownya nyanyanya purr nyameow purr nyameownyanya nyanya meow meow nyameownyanya nya purr nyanyanya meowmeowmeow meowmeow nya meow nyanyanyanya nyanya meownya meowmeownya meowmeowmeownyanyanya purr nyameowmeow meowmeowmeowmeowmeow nyameowmeow nyanyameowmeownyameow meownyanya nyameowmeowmeowmeow nyanyanyanyanya meownyameownya meowmeowmeowmeowmeow nyameownya meownyanya nyanyameowmeownyameow nyanyanyanya nyanyanyanyameow nyanyanya nyanyameowmeownyameow nyanyanya nyanyanyameowmeow nyanyanyanyameow nyameownya meownyameownya nyanyanyanya nyanyameowmeownyameow nyanyameownya nyanyanyameowmeow nyanyanyanyameow meow nyanyameow nyameownya nyanyanyameowmeow nyanyanyanyanya" | ./meow_to_morse.sh | morse -d | sed 's/?/_/g'
OHBYTHEWAY,HERE'SALITTLESOMETHING:W0W_D15C0RD_H4S_S34RCH_F34TUR35

rtcp{W0W_D15C0RD_H4S_S34RCH_F34TUR35}
```
### Chugalug's Footpads
Description: Chugalug makes footpads that he can chug and lug. However, his left one is different from his right... I wonder why?
```
$ xxd -c1 left.jpg > l && xxd -c1 right.jpg > r
$ grep -Fxvf r l | cut -d " " -f4 | tr -d "\n"
rtcp{Th3ze_^r3_n0TcH4nC1a5}
```
### BASmati ricE 64
Description: There's a flag in that bowl somewhere... Replace all zs with _ in your flag and wrap in rtcp{...}.
```
$ steghide extract -sf rice.jpg -xf extracted.txt
$ cat extracted.txt | base64 | sed 's/z/_/g'
s0m3t1m35_th1ng5_Ar3_3nc0D3d

rtcp{s0m3t1m35_th1ng5_Ar3_3nc0D3d}
```
### League of Asian Grandmas
Description: We recently intercepted an exorbitantly delicious and commodious shipment containing cleaned rice, unrealistically sweet-smelling jackfruit, elegantly peeled rambutan, seedless lychee, large, round and plump grapes, succulent nectarines, viscid peaches, and fried rice (among other things).  I'm not too sure, but this seems a tad bit suspicious, don't you think? Just looking at this makes me dizzy....

I stitched the 4 provided pictures together in GIMP. Unswirl the text to find the flag. It is very hard to read, so it took some guessing.
```
rtcp{y3p_n0th1ng_to_s33_h3re}
```

## Misc

### Strong Password
Description: Eat, Drink, Pet, Hug, Repeat!

Eat rice, drink tea, pet cat, hug panda
```
rtcp{rice_tea_cat_panda}
```
### Off-Topic
Description: #off-topic

Go to the #off-topic channel on discord, and it has a subtitle: who here knows the name of the catpanda in the server picture?
The catpanda in the server picture is the same as the one on the riceteacatpanda.wtf home page. The associated text with the picture is Jubie.
```
<img class="w-100 mx-auto d-block" style="max-width: 350px;" src="/files/71a3cdff21828480efb3bd1a2203c159/riceteacatpanda.png" alt="Jubie">

rtcp{Jubie}
```
### A Friend In Need Is A Friend Indeed
Description: Hm, I see a lot of potential friends in the midst of that discord, but... one is not like the others; maybe I'll slide into their dms and strike up a conversation about passwords!

Join RTCP slack channel and message bot Jade, whose status says “Listening to people's worries". Message the flag from Strong Password, rice_tea_cat_panda, since she likes passwords. Responds with:
You're such a great friend! Here, have a flag!
```
rtcp{awaken_winged_sun_dragon_of_ra}
```
### Survey!
Description: Wew a survey!!! Free points are always nice :3

Fill out the survey and recieve the flag.
```
rtcp{th^nk5_f0r_p14y1ng}
```
