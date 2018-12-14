#!/bin/bash

## Unpack GRML iso image, copy backup to rootfs and create restore iso image

BASEDIR=$(dirname $0)
source ${BASEDIR}/config.sh
WORKDIR="/var/tmp"
TIMESTAMP=$(date --iso-8601=date)

set -e
set -x

function unpack_grml_iso {
    pushd $WORKDIR
    
    mkdir -p $GRML_DIR $ROOTFS_DIR

    MOUNTDIR=$(mktemp -d)

    mount -o loop $GRML_ISO $MOUNTDIR
    rsync -a $MOUNTDIR/ $GRML_DIR/
    umount $MOUNTDIR

    mount -t squashfs -o loop $ROOTFS_FILE $MOUNTDIR
    rsync -a $MOUNTDIR/ $ROOTFS_DIR/
    umount $MOUNTDIR

    rmdir $MOUNTDIR

    popd
}

function copy_backup_to_rootfs {
    BACKUPDIR="${ROOTFS_DIR}/backup"
    
    pushd $WORKDIR

    mkdir -p $BACKUPDIR
    rsync -a $BACKUP_FILE $BACKUPDIR/backup.tar.gz
    rsync -a $BASEDIR/restore.sh $BACKUPDIR/

    rm -f $ROOTFS_FILE
    mksquashfs $ROOTFS_DIR $ROOTFS_FILE

    popd
}

function create_restore_iso {
    mkisofs -r -V "${HOSTNAME}-${TIMESTAMP}" \
     -o $WORKDIR/$RESTORE_ISO_FILE \
     -c boot/isolinux/boot.cat \
     -b boot/isolinux/isolinux.bin \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
     -eltorito-alt-boot \
     -eltorito-platform 0xEF -eltorito-boot boot/efi.img \
     -no-emul-boot \
     $WORKDIR/$GRML_DIR
}

[[ -d "${WORKDIR}/${GRML_DIR}" && -d "${WORKDIR}/${ROOTFS_DIR}" ]] || unpack_grml_iso

copy_backup_to_rootfs
create_restore_iso
