---
layout: post
title: Workflow, or How I Make this Blog
---

## Purpose
I received an email from someone that wanted to know how I constructed my website and what my workflow looks like. And, in drafting my response, I realized I may as well make it public in case others are interested.

## Creation
I use Jekyll, a static site generator with built-in support for Github Pages. I first started with the basic Jekyll [repo](https://github.com/jekyll/jekyll), but wanted a more interesting look. So I found a Jekyll theme I liked and forked the repo for it. I named it `<github-username>.github.io>`, and then cloned it. I followed the included README for configuring my version. I modified the color scheme, replaced the background, added new icons, and changed and added some default page tabs, and I updated the `_config.yml` file. I also added a custom domain for my Github Pages site. At this point, the blog was ready to go. 

## Adding Posts
All the posts are expected in Kramdown, the default Markdown renderer for Jekyll. The files that contain the posts must be written in this format and include a header in the following format:
```
---
layout: post
title: <your-title>
---
```
Also note, that if you want to use a colon in your title you have to use the character code `&#58;` to get it to render.

The posts also have to be titled in the following format: `YYYY-MM-DD-<title>.md`, where `<title>` can include dashes. Then, those files need to be placed inside the `_posts` folder.

## Workflow
I wrote two simple scripts to make this process faster.

**title.sh**:

```
#!/bin/bash                                                                                                             

echo "--- 
layout: post 
title: $2 
--- 
$(cat $1)" > $1
```

The first argument is the filename and the second argument is the title which is usually put in quotes.

**post.sh**:

```
#!/bin/bash 
filename=`echo "$1" | cut -d '.' -f1` 
mypost="$(date +%Y-%m-%d)-$filename.md" 
echo "$1 --> /_posts/$mypost" 
mv $1 ~/<url>/_posts/$mypost
```

For this one, simply pass the filename as the first argument. It renames the post with the date and moves it into the `_posts` folder.

## Running Locally
To check that everything looks as it should, I run `jekyll serve` in the root directory of my repo. The page is then served on `localhost:4000` by default.

## Updating Live Site
Pushing changes to the site is fairly simple with Git.

```
$ cd <username>.github.io
$ git add _posts/*
$ git commit -m "<hopefully descriptive message>"
$ git push
```
