#!/bin/bash

## Unpack GRML iso image, copy backup to rootfs and create restore iso image

BASEDIR=$(dirname $0)
source "${BASEDIR}/config.sh"
WORKDIR=$BACKUP_HOME
TIMESTAMP=$(date --iso-8601=date)

set -e
set -x

function unpack_grml_iso {
    mkdir -p "$GRML_DIR"

    MOUNTDIR=$(mktemp -d)

    mount -o loop "${GRML_ISO}" "${MOUNTDIR}"
    rsync -a "${MOUNTDIR}/" "${GRML_DIR}/"
    umount "${MOUNTDIR}"

    rmdir "${MOUNTDIR}"
}

function grub_enable_serial_console {
    GRUBDIR="${GRML_DIR}/boot/grub"
    rsync -a --update \
        "${BASEDIR}/grml-grub-boot-entry.cfg" \
        "${GRUBDIR}/00-serial_default.cfg"
}

function set_boot_parameters {
    BOOTPARAMDIR="${GRML_DIR}/bootparams"

    mkdir -p "${BOOTPARAMDIR}"
    echo "lvm scripts" > "${BOOTPARAMDIR}/bootparams"
}

function copy_restore_files_to_image {
    SCRIPTSDIR="${GRML_DIR}/scripts"

    mkdir -p "${SCRIPTSDIR}"

    rsync -a --update "${BASEDIR}/restore.sh" "${SCRIPTSDIR}/00-restore.sh"
    chmod 0755 "${SCRIPTSDIR}/00-restore.sh"

    rsync -a --update "${BASEDIR}/udev-net.rules" "${GRML_DIR}/udev-net.rules"

    chmod 0755 "${SCRIPTSDIR}/00-restore.sh"
    rsync -a --update \
        "${BACKUP_HOME}/${DISKINFO_FILE}" \
        "${GRML_DIR}/${DISKINFO_FILE}"

    zcat "${BACKUP_HOME}/${LATEST_BACKUP}" | \
        split -d -b $ISO_MAX_FILE_SIZE - "${GRML_DIR}/${TAR_SPLIT_VOLUME_NAME}"
}

function create_restore_iso {
    mkisofs \
     -r \
     -V "${HOSTNAME}-${TIMESTAMP}" \
     -o "${RESTORE_ISO_FILE}" \
     -eltorito-catalog boot/isolinux/boot.cat \
     -eltorito-boot boot/isolinux/isolinux.bin \
     -no-emul-boot \
     -boot-load-size 4 \
     -boot-info-table \
     -eltorito-alt-boot \
     -eltorito-boot boot/efi.img \
     -no-emul-boot \
     "${GRML_DIR}"
}

[[ -d "${GRML_DIR}" ]] || unpack_grml_iso

set_boot_parameters
grub_enable_serial_console
copy_restore_files_to_image
create_restore_iso
