#!/bin/bash

## Create backup tarball of root filesystem

BASEDIR=$(dirname $0)
source ${BASEDIR}/config.sh
FQDN=$(hostname --fqdn)
TIMESTAMP=$(date --iso-8601=minutes)
TARBALL="${HOSTNAME}-${TIMESTAMP}.tar.gz"

set -x

function save_diskinfo {
    [[ -f "${BACKUP_HOME}/${DISKINFO_FILE}" ]] && return

    for BLOCK_DEVICE in $(lsblk -d -o KNAME | grep -v 'sr[0-9]\|KNAME'); do
        parted "/dev/${BLOCK_DEVICE}" print free >> "${BACKUP_HOME}/${DISKINFO_FILE}"
    done

    lsblk -fs >> "${BACKUP_HOME}/${DISKINFO_FILE}"
}


function backup_root_filesystem_with_tar {
    tar \
      --create \
      --gzip \
      --acls \
      --xattrs \
      --xattrs-include=security.selinux \
      --xattrs-include=security.capability \
      --anchored \
      --force-local \
      --label="${FQDN}-${TIMESTAMP}" \
      --exclude="${BACKUP_HOME}/*" \
      --exclude-from="${BASEDIR}/exclude-files.txt" \
      --file="${BACKUP_HOME}/${TARBALL}" \
      "/" \
      >> ${BACKUP_HOME}/error.log-${TIMESTAMP} 2>&1

    ln --symbolic --force "${BACKUP_HOME}/${TARBALL}" "${BACKUP_HOME}/${LATEST_BACKUP}"
}

[[ -d "$BACKUP_HOME" ]] || mkdir -p "$BACKUP_HOME"

save_diskinfo
backup_root_filesystem_with_tar
