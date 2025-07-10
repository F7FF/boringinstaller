#!/bin/bash

#This is the "main" shell file, intended to be curled and bashed by the installation medium.

echo "Welcome to the Boring Installer!"
echo "First, choose the disk you'd like to install to. ALL DATA ON THE DISK WILL BE LOST!"
echo "(eg. "/dev/sda", "/dev/nvme0")"

read diskname

echo "Target disk set to '$diskname'"

echo "BEGINNING OF INSTALLATION"
echo "(BI 1) Setting RTC to local TZ and synchronizing clock..."

timedatectl set-local-rtc 1 #needed so we don't mess up the Windows clock on dualbooting systems. Note this only applies to the installer
timedatectl                 #sync RTC to local for installation

echo "(BI 2) Clearing and formatting disk partitions..."

#in future, make it possible to install without clearing the disk? just clear anything that isn't an NTFS/EXT4/BTRFS partition
#parted -s 
