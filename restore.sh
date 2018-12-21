#!/bin/bash

DISK='/dev/vda'
ROOTFS_MOUNT='/mnt'
GRML_DCSDIR='/lib/live/mount/medium'
EXT4_FEATURES='^metadata_csum,has_journal,extent,huge_file,flex_bg,uninit_bg,dir_nlink,extra_isize'

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
mkfs -t ext4 -O $EXT4_FEATURES /dev/systemVG/LVRoot
mkfs -t ext4 -O $EXT4_FEATURES /dev/systemVG/LVvar
mkfs -t ext3 /dev/systemVG/LVtftp

mkswap /dev/mapper/systemVG-LVSwap

mount /dev/systemVG/LVRoot $ROOTFS_MOUNT
mkdir -p $ROOTFS_MOUNT/boot $ROOTFS_MOUNT/srv/tftpboot
mount "${DISK}2" $ROOTFS_MOUNT/boot
mkdir $ROOTFS_MOUNT/boot/efi
mount "${DISK}1" $ROOTFS_MOUNT/boot/efi
mount /dev/systemVG/LVtftp $ROOTFS_MOUNT/srv/tftpboot

tar --verbose --extract --same-owner --file="${GRML_DCSDIR}/backup.tar.gz" --directory=$ROOTFS_MOUNT

mount -o bind /dev $ROOTFS_MOUNT/dev
mount -o bind /sys $ROOTFS_MOUNT/sys
mount -t proc /proc $ROOTFS_MOUNT/proc

cat > $ROOTFS_MOUNT/etc/fstab <<EOF
/dev/systemVG/LVSwap swap                 swap       defaults              0 0
/dev/systemVG/LVRoot /                    ext4       defaults              1 1
${DISK}2             /boot                ext3       defaults              1 2
${DISK}1             /boot/efi            vfat       umask=0002,utf8=true  0 0
/dev/systemVG/LVtftp /srv/tftpboot        ext3       defaults              1 2
/dev/systemVG/LVvar  /var                 ext4       defaults              1 2
EOF

chroot $ROOTFS_MOUNT grub2-mkconfig -o /boot/grub2/grub.cfg
chroot $ROOTFS_MOUNT grub2-mkconfig -o /boot/efi/EFI/sles/grub.cfg
chroot $ROOTFS_MOUNT grub2-install $DISK

for KERNEL in $(ls $ROOTFS_MOUNT/boot/vmlinuz-*); do
    [[ $KERNEL =~ vmlinuz-(.*) ]] || { echo "Could not extract Kernel version"; exit 1; }
    KERNEL_VERSION=${BASH_REMATCH[1]}
    chroot $ROOTFS_MOUNT dracut --force --kver $KERNEL_VERSION
done
