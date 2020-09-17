SEEDLabs - BOF

```
# disable address space randomization which randomizes the starting address of heap and stack
$ sudo sysctl -w kernel.randomize_va_space=0

# link /bin/sh to another shell that does not have dash's countermeasures
$ sudo ln -sf /bin/zsh /bin/sh
```


