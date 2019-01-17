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

function save_diskinfo {
    [[ -f "${BACKUP_HOME}/${DISKINFO_FILE}" ]] && return

    for BLOCK_DEVICE in $(lsblk -d -o KNAME | grep -v 'sr[0-9]\|KNAME'); do
        parted "/dev/${BLOCK_DEVICE}" print free >> "${BACKUP_HOME}/${DISKINFO_FILE}"
    done

    lsblk -fs >> "${BACKUP_HOME}/${DISKINFO_FILE}"
}

function backup_root_filesystem_with_rsync {

    [[ -d "$RSYNC_DIR" ]] || mkdir -p "$RSYNC_DIR"

    rsync \
      --archive \
      --xattrs \
      --hard-links \
      --delete-after \
      --numeric-ids \
      --exclude="${BACKUP_HOME}/*" \
      --exclude-from="${BASEDIR}/exclude-files.txt" \
      / $RSYNC_DIR >> ${BACKUP_HOME}/error.log-${TIMESTAMP} 2>&1
   
    save_diskinfo
}

function create_backup_tarball_from_rsync {
    tar \
      --create \
      --gzip \
      --acls \
      --xattrs \
      --xattrs-include=security.selinux \
      --xattrs-include=security.capability \
      --force-local \
      --label="${FQDN}-${TIMESTAMP}" \
      --file="${BACKUP_HOME}/${TARBALL}" \
      --directory="${RSYNC_DIR}" . \
      >> ${BACKUP_HOME}/error.log-${TIMESTAMP} 2>&1

    ln --symbolic --force "${BACKUP_HOME}/${TARBALL}" "${BACKUP_HOME}/${LATEST_BACKUP}"
}

function backup_root_filesystem_with_tar {
    tar \
      --create \
      --gzip \
      --acls \
      --xattrs \
      --xattrs-include=security.selinux \
      --xattrs-include=security.capability \
      --force-local \
      --label="${FQDN}-${TIMESTAMP}" \
      --exclude="${BACKUP_HOME}/*" \
      --exclude-from="${BASEDIR}/exclude-files.txt" \
      --file="${BACKUP_HOME}/${TARBALL}" \
      --directory="/" . \
      >> ${BACKUP_HOME}/error.log-${TIMESTAMP} 2>&1

    ln --symbolic --force "${BACKUP_HOME}/${TARBALL}" "${BACKUP_HOME}/${LATEST_BACKUP}"
}

[[ -d "$BACKUP_HOME" ]] || mkdir -p "$BACKUP_HOME"

[[ "$1" == "rsync" ]] && backup_root_filesystem_with_rsync
[[ "$1" == "backup" ]] && backup_root_filesystem_with_tar
[[ "$1" == "tar" ]] && create_backup_tarball_from_rsync
