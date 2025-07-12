# boringinstaller
A boring way to quickly install a preconfigured Arch desktop.

*In its current state, this script is very VERY new and contains a lot of bugs. It can get to a stable desktop, but Nvidia GPU drivers need more configuring - be wary!*

## But why?
This installer is intended to take a relatively modern desktop/laptop with a blankable disk (see requirements) and make a pre-configured Arch KDE system. I've left a lot of documentation to help explain the process and the choices that I made.

This repo is only really intended for me. I've been enjoying a lot of KDE-based distros, but a lot of them are either very inflexible or very difficult to configure. I figured an easy and relatively foolproof Arch configuration script might help with that. I find `archinstall` to be a little unreliable and I want a desktop that is consistent and reliable across multiple machines, without having to tailor each one... so a premade installer makes sense.

### Good Things About This Installer:
- OOTB HDR support using KDE and Wayland.
- `pacman` has excellent repositories.
- The Arch wiki has great tutorials on further modifications. This is not a full OS, this is just a script to get Arch working quickly.
- BTRFS compression enabled OOTB to help game assets load faster and store more densely.
- RTC is automatically configured to local time (not UTC), to avoid pains when dualbooting with Windows.
- Some common tools are pre-installed, although really you could do that yourself if you wanted.

### Bad Things About This Installer:
- This installer uses modern-ish GPU drivers (namely `mesa` and Nvidia >570), so some older hardware might not work well. As a general rule, if it's post-2016, it'll be OK. Of course, you can always mess with it *after* the installation.
- This configuration is heavier than most Arch installations. Still lighter than Windows, but this ain't gonna run on a C2D.
- Flatpak is used to install Steam. Some people don't like it.
- I am a singular doofus with not much testing capability, so only use this script on a computer that you don't mind messing up.

## Current Problems:
- **This installer requires a SATA/SCSI `/dev/sdX`-style disk at the moment, NVME drives won't (quite!) work yet. Sorry! I'm working on it.
- It is probably missing some drivers/fixes at the moment.
- I'd like to make the package list tidier so that each package has an explainer.
- Nvidia is buggered, as usual. It does install the packages, but the drivers arn't enabled.
*Please, PLEASE notify me of any bugs! Also let me know if you think a package should be included/excluded.*

## Installation
1: Follow the [Arch installation guide](https://wiki.archlinux.org/title/Installation_guide) to prepare and boot from a live Arch environment (go up to step 1.7).

2: To start the script, the computer must have internet. Either use an ethernet connection or iuse `iwctl` to connect to WiFi, just like the Arch wiki page says.

3: Run `curl https://raw.githubusercontent.com/F7FF/boringinstaller/refs/heads/main/main.sh > main.sh` to download the script to the installation ramdisk, run `chmod 777 main.sh` to allow it to be executed, and run `./main.sh | tee stdout log.txt` to execute it. The installer will ask a few questions and then install Arch to the drive specified.
(Note that `curl`ing and `bash`ing random scripts with root privelege on an installation medium is **sketchy as hell** and should be avoided unless you trust the source of the script. Thank you for trusting me, I'll try not to bugger up your computer.)

4: Once the installer finishes, you may need to give GRUB priority in BIOS. After that, it should be smooth booting from there.
