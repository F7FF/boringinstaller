#!/bin/bash

#This is the "main" shell file, intended to be curled and bashed by the installation medium.

echo "Welcome to the Boring Installer!"
echo "First, take a look at the output of fdisk and see what the device identifier of your target drive is (eg. /dev/sda, or /dev/nvme0)"
echo "-----  OUTPUT OF FDISK  -----"
fdisk -l
echo "----- END OF FDISK LIST -----"
echo "Choose the disk you'd like to install to. ALL DATA ON THE DISK WILL BE LOST!"
echo "(for example, "/dev/sda", "/dev/nvme0")"

read -p "Installation target: " DISKNAME

read -p "Choose a username: " USERNAME
read -p "Choose a password: " USERPASSWORD
read -p "Choose a computer name: " SYSTEMNAME
read -p "Choose a password for the root user: " ROOTPASSWORD
#TODO: ask the user if they'd like to install Nvidia drivers

echo "Target disk set to '$DISKNAME'"

echo "BEGINNING OF INSTALLATION"
echo "(BI 1) Setting RTC to local TZ and synchronizing clock (to prevent clock confusion on dualbooters)..."

timedatectl set-local-rtc 1 #needed so we don't mess up the Windows clock on dualbooting systems. Note this only applies to the installer
timedatectl                 #sync RTC to local for installation

echo "(BI 2) Clearing and formatting disk partitions..."

#TODO: in future, make it possible to install without clearing the disk? just clear anything that isn't an NTFS/EXT4/BTRFS partition
#TODO: consider using sfdisk?
parted -s "$DISKNAME" mklabel gpt || { echo "Error creating GPT table."; exit 1; } #make a new GPT table

#use parted to make two partitions - an EFI partition (eg. /dev/sdX1) and a BTRFS partition (eg. /dev/sdX2)
parted -s "$DISKNAME" mkpart ESP fat32 1MiB 1024MiB || { echo "Error creating EFI partition."; exit 1; }
parted -s "$DISKNAME" mkpart archlinux btrfs 1024MiB 100% || { echo "Error creating main partition."; exit 1; }

#TODO: if we don't create the disk from scratch, we don't neccessarily know what the numbers of the partitions are, so we should be careful to find them.
#Also, we need to add a "p" for NVME drives (and maybe MMC too?)
EFIPARTITION="${DISKNAME}1"
MAINPARTITION="${DISKNAME}2"

echo "EFI partition name:  $EFIPARTITION"
echo "Main partition name: $MAINPARTITION"

echo "(BI 3) Formatting the newly created partitions..."

mkfs.fat -F 32 "$EFIPARTITION" || { echo "Error while formatting EFI partition"; exit 1; }
mkfs.btrfs -f "$MAINPARTITION" || { echo "Error while formatting main BTRFS partition"; exit 1; }

echo "(BI 4) Mounting the newly created filesystems at /mnt and /mnt/boot..."

#mount the BTRFS partition and enable compression. genfstab will copy this parameter over to the main installaton later. Level 9 is chosen as a good blend between speed and compression.
mount -o compress=zstd:9 "$MAINPARTITION" /mnt || { echo "Failed to mount main partition!"; exit 1; }

#the EFI partition is mounted in /boot of the new system for UEFI config
mount --mkdir "$EFIPARTITION" /mnt/boot || { echo "Failed to mount EFI partition!"; exit 1; }

#TODO: configure mirrors here?

echo "(BI 5) Bootstrapping main installation and installing starter packages"

#Here comes the big pacstrap line, where we create the new OS structure and install all premade packages.
pacstrap -K /mnt base linux-zen linux-firmware plasma-meta kde-applications-meta ffmpeg pipewire-jack gnu-free-fonts pyside6 cron tesseract-data-eng firefox flatpak nvidia-open mesa vulkan-radeon spectacle kate sddm sddm-kcm networkmanager ufw dosfstools btrfs-progs exfatprogs ntfs-3g os-prober network-manager-applet nm-connection-editor iwd plasma-nm grub efibootmgr sudo dhcpcd || { echo "Error while pacstrapping!"; exit 1;}

echo "(BI 6) chrooting into installation and configuring..."

#generating fstab before we chroot...
genfstab -U /mnt >> /mnt/etc/fstab || { echo "Error while generating fstab!"; exit 1; }

#chroot into the mountpoint for the rest of this script
arch-chroot /mnt || { echo "Error while chrooting!"; exit 1; }

locale-gen #Generate locale file at /etc/locale.gen
#uncomment a line here?

#set hostname
echo "$SYSTEMNAME" >> /mnt/etc/hostname 

#possibly initramfs here?

#set root password
echo "$ROOTPASSWORD" | passwd root --stdin || { echo "Failed to set root password!"; exit 1; }

#make user
useradd -m "$USERNAME" || { echo "Failed to create user ${USERNAME}!"; exit 1; }
echo "${USERNAME} ALL=(ALL) ALL #added on installation by the Boring Installer" >> /etc/sudoers
echo "$USERPASSWORD" | passwd "$USERNAME" --stdin | { echo "Failed to set user password!"; exit 1; }


#configuring GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCHGRUB || { echo "Error while configuring GRUB!"; exit 1; }
grub-mkconfig -o /boot/grub/grub.cfg || { echo "Error while creating grub.cfg!"; exit 1; }
#not sure about this, do we set efi directory to /mnt/boot?

systemctl enable sddm #needed to get to the login

#systemctl enable systemd-networkd #needed for internet
#systemctl enable systemd-resolved #needed for internet...?

systemctl enable NetworkManager #needed for internet! capitals are important!

#set local RTC 1, to make Windows dualbooting easier
timedatectl set-local-rtc 1

#TODO: create a file on the user's desktop, explaining any next steps (setting locale?)

echo "Installation complete! Reboot whenever you're ready."
