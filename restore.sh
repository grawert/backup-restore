DISK=/dev/sda

parted $DISK mklabel gpt
parted $DISK mkpart primary  1M 3M
parted $DISK mkpart primary fat16 3M 213M		# /boot/efi
parted $DISK mkpart primary 513M 1024M			# /boot
parted $DISK mkpart primary 1024M 100%			# LVM

parted $DISK name 1 legacy_boot
parted $DISK name 2 UEFI
parted $DISK name 3 lxboot
parted $DISK name 4 primary
parted $DISK set 1 bios_grub on
parted $DISK set 2 boot on

pvcreate "${DISK}4"
vgcreate systemVG "${DISK}4"

lvcreate --name LVRoot --size 5G systemVG
lvcreate --name LVSwap --size 1G systemVG
lvcreate --name LVvar --size 1G systemVG
lvcreate --name LVtftp --size 1G systemVG

mkfs -t vfat "${DISK}2"
mkfs -t ext3 "${DISK}3"
mkfs -t ext4 /dev/systemVG/LVRoot
mkfs -t ext4 /dev/systemVG/LVvar
mkfs -t ext3 /dev/systemVG/LVtftp

mount /dev/systemVG/LVRoot /mnt
mkdir -p /mnt/boot /mnt/srv/tftpboot /mnt/var
mount "${DISK}3" /mnt/boot
mkdir /mnt/boot/efi
mount "${DISK}2" /mnt/boot/efi
mount /dev/systemVG/LVvar /mnt/var
mount /dev/systemVG/LVtftp /mnt/srv/tftpboot

tar -xf backup.tar.gz -C /mnt
mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
mount -t proc /proc /mnt/proc

echo > /mnt/etc/fstab <<EOF
devpts /dev/pts devpts mode=0620,gid=5 0 0
proc /proc proc defautls 0 0

/dev/systemVG/LVRoot / ext4 defaults 1 1
/dev/${DISK}3 /boot ext3 defaults 1 2
/dev/${DISK}2 /boot/efi vfat defaults 0 0
/dev/systemVG/LVRoot / ext4 defaults 1 1
EOF

chroot /mnt grub2-mkconfig -o /boot/grub2/grub.cfg
chroot /mnt grub2-mkconfig -o /boot/efi/EFI/BOOT/grub.cfg
chroot /mnt grub2-install $DISK
