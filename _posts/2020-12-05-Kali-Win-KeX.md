---
layout: post
title: Setup Kali Linux GUI on WSL2
---

I followed the [Kali Guide](https://www.kali.org/docs/wsl/win-kex/#install-win-kex), but ran into some issues so I thought I'd make a post on what worked for me. These instructions are more streamlined, and the main difference is that they include installing dbus-x11.

## Install Kali Linux in WSL2

* Open PowerShell as administrator and run:

	```
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
	```
* Restart

* Open PowerShell as administrator and run:

	```
	dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
	dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
	```
* Restart
* Download and run [Kernel Update Package for x64 Machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

* Open PowerShell as administrator and run: 
	```
	wsl --set-default-version 2
	```

* Install Kali Linux from Microsoft Store, launch it, set up user account

## Win-KeX Setup

* Run: 
	```
	sudo apt update && sudo apt upgrade && sudo apt install kali-win-kex dbus-x11
	```

## Run Win-KeX

* To start Win-KeX in Window mode with sound support, run: 
	```
	kex --win -s
	```
* To start Win-KeX in Enhanced Session Mode with sound support and ARM workaround, run:
	```
	kex --esm --ip -s
	```
* To start Win-KeX in Seamless mode with sound support, run:
	```
	kex --sl -s
	```

## Optional: Windows Terminal

To make launching my preferred KeX mode simple, I added the following profile to my Windows Terminal's settings.json file:
```
{
	"guid": "{55ca431a-3a87-5fb3-83cd-11ececc031d2}",
	"hidden": false,
	"name": "Kali Seamless",
	"commandline": "wsl -d kali-linux kex --sl --wtstart -s",
	"startingDirectory" : "//wsl$/kali-linux/home/kali"
},
```

You can check [here](https://www.kali.org/docs/wsl/win-kex/#optional-steps) for additional configurations. Do note, that you cannot put multiple profiles in your settings.json with the same "guid" field, as only one option will show.

### Adding an Icon

If you want to add an icon in your Windows Terminal tab, you have to take a couple extra steps.

* Grab a Kali Menu icon from anywhere you want, though make sure its a PNG.

* In File Explorer, put `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState` in your search bar.

* Paste the PNG into the RoamingState Folder

* Add an additional line into your profile like so:

```
{
	"guid": "{55ca431a-3a87-5fb3-83cd-11ececc031d2}",
	"hidden": false,
      	"icon": "ms-appdata:///roaming/<filename>.png",
	"name": "Kali Seamless",
	"commandline": "wsl -d kali-linux kex --sl --wtstart -s",
	"startingDirectory" : "//wsl$/kali-linux/home/kali"
},
```

