#!/bin/bash

mypost="$(date +%Y-%m-%d)-$1.md"
echo "$1 --> /_posts/$mypost"
mv $1 ~/zacheller.github.io/_posts/$mypost
git add ~/zacheller.github.io/* 2> /dev/null

