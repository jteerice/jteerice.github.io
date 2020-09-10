#!/bin/bash
filename=`echo "$1" | cut -d '.' -f1`
mypost="$(date +%Y-%m-%d)-$filename.md"
echo "$1 --> /_posts/$mypost"
mv $1 ~/zacheller.github.io/_posts/$mypost
git add ~/zacheller.github.io/* 2> /dev/null

