---
layout: post
title: Reverse Engineering&#58; HackTheBox/Spooky_License
---

## HackTheBox - Spooky License - Write-up

After downloading, we get one binary file. Running the ```file``` command tells us we have a 64-bit pie executable, dynamically linked, and stripped.

Both ```strings``` and ```ltrace``` fail to yield anything meaningful. When we try to run the binary, we see that the program requires an argument be passed to is.
```
./spookylicence <license>
```

If we pass an argument to the program, we are told that it is an invalid license format.

### Reversing

Something I appreciate about Binary Ninja, is it does an amazing job of putting us right at ```main``` and providing a good function signature. Anyways, the first thing we see is that the program expects and argument and that the argument needs to be ```0x20``` bytes long, or 32 characters.
```
00001180      if (argc != 2)
00001189          puts(str: "./spookylicence <license>")
0000118e          rax = -1
000011af      else if (strlen(argv[1]) != 0x20)
000011b8          puts(str: "Invalid License Format")
000011bd          rax = -1
```

The next part is just the program doing some bit mangling and comparing, and if all compares check out, we are prompted that the license is correct. The argument we pass to the program cna safely be assumed to be the flag.

Whenever I see overcomplicated math/bit logic being applied in a reverse engineering challenge, I always look to ```angr``` to save the day.

### Angr

For any readers that don't know, Angr is a symbolic execution and reverseing framework. Symbolic execution means that instead of defined variables, angr keeps track of "symbols" and symbolic constraints of what values certain variables can hold to reach certain areas of the program. The nitty gritty behind the angr API is beyond the scope of this program, but more information can be found [here](https://angr.io/). The following script below yields the correct result.
```python
#!/usr/bin/env python3

import angr, claripy
import logging

goal = 0x187d
not_goal = [0x1189, 0x11b8]

def hook(l=None):
    if l:
        locals().update(l)
    import IPython
    IPython.embed(banner1='', confirm_exit=False)
    exit(0)

logging.getLogger('angr').setLevel(logging.INFO)

p = angr.Project("./spookylicence", main_opts={'base_addr': 0})

argv1 = claripy.BVS("argv1", 100*8)
initial_state = p.factory.entry_state(args=["./spookylicence", argv1])
sm = p.factory.simgr(initial_state, veritesting=True)

sm.explore(find=goal, avoid=not_goal)

if not sm.found:
    print("No solution found")
    hook(locals())

else:
    print("Solution found!")
    found = sm.found[0]
    flag = found.solver.eval(argv1, cast_to=bytes)
    print(repr(flag))

    hook(locals())
```

Et voila!
