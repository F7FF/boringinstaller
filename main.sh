#!/bin/bash

#This is the "main" shell file, intended to be curled and bashed by the installation medium.

echo "Welcome to the Boring Installer!"
echo "-----  OUTPUT OF FDISK  -----"
fdisk -l
echo "----- END OF FDISK LIST -----"
echo "First, choose the disk you'd like to install to. ALL DATA ON THE DISK WILL BE LOST!"
echo "(eg. "/dev/sda", "/dev/nvme0")"

read DISKNAME

read -p "Choose a username: " USERNAME
read -p "Choose a password: " PASSWORD
read -P "Choose a computer name: " SYSTEMNAME
read -p "Choose a password for the root user: " ROOTPASSWORD
#TODO: ask the user if they'd like to install Nvidia drivers

echo "Target disk set to 'DISKNAME'"

echo "BEGINNING OF INSTALLATION"
echo "(BI 1) Setting RTC to local TZ and synchronizing clock..."

timedatectl set-local-rtc 1 #needed so we don't mess up the Windows clock on dualbooting systems. Note this only applies to the installer
timedatectl                 #sync RTC to local for installation

echo "(BI 2) Clearing and formatting disk partitions..."

#TODO: in future, make it possible to install without clearing the disk? just clear anything that isn't an NTFS/EXT4/BTRFS partition
parted -s "$DISKNAME" mklabel gpt || { echo "Error creating GPT table."; exit 1; } #make a new GPT table

#use parted to make two partitions - an EFI partition (eg. /dev/sdX1) and a BTRFS partition (eg. /dev/sdX2)
parted -s "$DISKNAME" mkpart ESP fat32 1MiB 1024MiB || { echo "Error creating EFI partition."; exit 1; }
parted -s "$DISKNAME" mkpart archlinux btrfs 1025MiB 100% || { echo "Error creating main partition."; exit 1; }

#THIS IS A TESTING VERSION
