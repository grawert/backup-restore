#!/bin/bash

DISK=/dev/vda
GRML_DCSDIR="/lib/live/mount/medium"

parted $DISK mklabel gpt
parted $DISK mkpart primary fat16 1M    213M	# /boot/efi
parted $DISK mkpart primary       213M  1024M	# /boot
parted $DISK mkpart primary       1024M 100%	# LVM

parted $DISK name 1 UEFI
parted $DISK name 2 LXBOOT
parted $DISK name 3 LVM
parted $DISK set 1 boot on

pvcreate "${DISK}3"
vgcreate systemVG "${DISK}3"

lvcreate --name LVRoot --size 5G systemVG
lvcreate --name LVSwap --size 1G systemVG
lvcreate --name LVvar --size 1G systemVG
lvcreate --name LVtftp --size 1G systemVG

mkfs -t vfat "${DISK}1"
mkfs -t ext3 "${DISK}2"
mkfs -t ext4 /dev/systemVG/LVRoot
mkfs -t ext4 /dev/systemVG/LVvar
mkfs -t ext3 /dev/systemVG/LVtftp

mount /dev/systemVG/LVRoot /mnt
mkdir -p /mnt/boot /mnt/srv/tftpboot /mnt/var
mount "${DISK}2" /mnt/boot
mkdir /mnt/boot/efi
mount "${DISK}1" /mnt/boot/efi
mount /dev/systemVG/LVvar /mnt/var
mount /dev/systemVG/LVtftp /mnt/srv/tftpboot

tar --verbose --extract --file="${GRML_DCSDIR}/backup.tar.gz" --directory=/mnt

mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
mount -t proc /proc /mnt/proc

cat > /mnt/etc/fstab <<EOF
devpts /dev/pts devpts mode=0620,gid=5 0 0
proc /proc proc defautls 0 0

/dev/systemVG/LVRoot / ext4 defaults 1 1
/dev/${DISK}2 /boot ext3 defaults 1 2
/dev/${DISK}1 /boot/efi vfat defaults 0 0
/dev/systemVG/LVRoot / ext4 defaults 1 1
EOF

chroot /mnt grub2-mkconfig -o /boot/grub2/grub.cfg
chroot /mnt grub2-mkconfig -o /boot/efi/EFI/sles/grub.cfg
chroot /mnt grub2-install $DISK
