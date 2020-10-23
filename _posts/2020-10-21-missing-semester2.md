---
layout: post
title: ./missing-semester - Editors (Vim) - Exercises
---
Course located at: [missing.csail.mit.edu](https://missing.csail.mit.edu/)
## Exercises
* Complete vimtutor. Note: it looks best in a 80x24 (80 columns by 24 lines) terminal window.
* Download our basic vimrc and save it to ~/.vimrc. Read through the well-commented file (using Vim!), and observe how Vim looks and behaves slightly differently with the new config.
* Install and configure a plugin: ctrlp.vim.
	* Create the plugins directory with mkdir -p ~/.vim/pack/vendor/start
	* Download the plugin: cd ~/.vim/pack/vendor/start; git clone https://github.com/ctrlpvim/ctrlp.vim
	* Read the documentation for the plugin. Try using CtrlP to locate a file by navigating to a project directory, opening Vim, and using the Vim command-line to start :CtrlP.
	* Customize CtrlP by adding configuration to your ~/.vimrc to open CtrlP by pressing Ctrl-P.
* To practice using Vim, re-do the Demo from lecture on your own machine.

	```py
	import sys

	def fizz_buzz(limit):
	    for i in range(1, limit+1):
		if i % 3 == 0:
		    print('fizz', end='')
		if i % 5 == 0:
		    print('buzz', end='')
		if i % 3 and i % 5:
		    print(i)

	def main()
	    fizz_buzz(int(sys.argv[1]))

	if __name__ == '__main__':
	    main()
	```
* Use Vim for all your text editing for the next month. Whenever something seems inefficient, or when you think “there must be a better way”, try Googling it, there probably is. If you get stuck, come to office hours or send us an email.
	* I've been using Vim as my primary editor for the last couple months, and have improved noticeably.
* Configure your other tools to use Vim bindings (see instructions above).
	* I used `set -o vi` to put my terminal in vi mode.
	* I also downloaded Vimium.
* Further customize your ~/.vimrc and install more plugins.
* (Advanced) Convert XML to JSON (example file) using Vim macros. Try to do this on your own, but you can look at the macros section above if you get stuck.

	```
	$ wget https://missing.csail.mit.edu/2020/files/example-data.xml
	$ cp example-data.xml example-data.json
	$ vim example-data.json

	:s/<people>/{\r\t"people": {/g
	j
	:s/<person>/\t\t"person": [\r\t\t\t{/g
	:%s/  <person>/\t\t\t{
	:%s/    <name>\(.*\)<\/name>/\t\t\t\t"name": "\1",/g
	:%s/    <email>\(.*\)<\/email>/\t\t\t\t"email": "\1"/g
	:%s/  <\/person>/\t\t\t},
	Gddlxo<Tab><Tab>]<Enter><Tab>}<Enter>}
	```

