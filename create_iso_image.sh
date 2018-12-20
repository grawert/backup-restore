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
    
    mkdir -p $GRML_DIR

    MOUNTDIR=$(mktemp -d)

    mount -o loop $GRML_ISO $MOUNTDIR
    rsync -a $MOUNTDIR/ $GRML_DIR/
    umount $MOUNTDIR

    rmdir $MOUNTDIR

    popd
}

function set_boot_parameters {
    BOOTPARAMDIR="${GRML_DIR}/bootparams"

    pushd $WORKDIR

    mkdir -p $BOOTPARAMDIR
    echo "scripts" > "${BOOTPARAMDIR}/bootparams"

    popd
}

function copy_restore_files_to_image {
    SCRIPTSDIR="${GRML_DIR}/scripts"

    pushd $WORKDIR

    mkdir -p $SCRIPTSDIR
    rsync -a --update "${BASEDIR}/restore.sh" "${SCRIPTSDIR}/00-restore.sh"
    chmod 0755 "${SCRIPTSDIR}/00-restore.sh"

    rsync -a --update $BACKUP_FILE "${GRML_DIR}/backup.tar.gz"

    popd
}

function create_restore_iso {
    mkisofs \
     -r \
     -V "${HOSTNAME}-${TIMESTAMP}" \
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

unpack_grml_iso
set_boot_parameters
copy_restore_files_to_image
create_restore_iso
