#!/bin/bash

echo "---
layout: post
title: $2
---

$(cat $1)" > $1
