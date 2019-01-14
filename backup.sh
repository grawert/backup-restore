#!/bin/bash

## Create backup of root filesystem when called with parameter `backup`
## Create a backup tarball when called with parameter `tar`

BASEDIR=$(dirname $0)
source ${BASEDIR}/config.sh
FQDN=$(hostname --fqdn)
TIMESTAMP=$(date --iso-8601=minutes)
TARBALL="${HOSTNAME}-${TIMESTAMP}.tar.gz"

set -e
set -x

function backup_root_filesystem {
    rsync \
      --archive \
      --xattrs \
      --hard-links \
      --delete-after \
      --numeric-ids \
      --exclude="${BACKUP_HOME}/*" \
      --exclude-from="${BASEDIR}/exclude-files.txt" \
      / $RSYNC_DIR >> ${BACKUP_HOME}/error.log-${TIMESTAMP} 2>&1
}

function save_diskinfo {
    [[ -f "${BACKUP_HOME}/${DISKINFO_FILE}" ]] && return

    for BLOCK_DEVICE in $(lsblk -d -o KNAME | grep -v 'sr[0-9]\|KNAME'); do
        parted "/dev/${BLOCK_DEVICE}" print free >> "${BACKUP_HOME}/${DISKINFO_FILE}"
    done

    lsblk -fs >> "${BACKUP_HOME}/${DISKINFO_FILE}"
}

function create_backup_tarball {
    tar \
      --create \
      --gzip \
      --acls \
      --xattrs \
      --force-local \
      --label="${FQDN}-${TIMESTAMP}" \
      --file="${BACKUP_HOME}/${TARBALL}" \
      --directory="${RSYNC_DIR}" . \
      >> ${BACKUP_HOME}/error.log-${TIMESTAMP} 2>&1

    ln --symbolic --force "${BACKUP_HOME}/${TARBALL}" "${BACKUP_HOME}/${LATEST_BACKUP}"
}

[[ -d "$BACKUP_HOME" ]] || mkdir -p "$BACKUP_HOME"
[[ -d "$RSYNC_DIR" ]] || mkdir -p "$RSYNC_DIR"

save_diskinfo

[[ "$1" == "backup" ]] && backup_root_filesystem
[[ "$1" == "tar" ]] && create_backup_tarball
