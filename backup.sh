#!/bin/bash

## Create backup of root filesystem
## Create a backup tarball when called with parameter "savestate"

BASEDIR=$(dirname $0)
source ${BASEDIR}/config.sh
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
      --exclude='/lost+found' \
      --exclude='/backup_2nd_BB/*' \
      --exclude='/docker-backup/*' \
      --exclude='/dev/*' \
      --exclude='/proc/*' \
      --exclude='/sys/*' \
      --exclude='/run/*' \
      --exclude='/home/*' \
      --exclude='/mnt/*' \
      --exclude='/tmp/*' \
      --exclude='/srv/www/htdocs/*' \
      --exclude='/var/chef/cache/*' \
      --exclude='/var/log/lastlog' \
      --exclude='/var/tmp/*' \
      --exclude="${BACKUP_HOME}/*" \
      / $RSYNC_DIR 2> ${BACKUP_HOME}/error.log-${TIMESTAMP}
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
      --label="${HOSTNAME}-${TIMESTAMP}" \
      --file="${BACKUP_HOME}/${TARBALL}" \
      --directory="${RSYNC_DIR}" .

    ln --symbolic --force "${BACKUP_HOME}/${TARBALL}" "${BACKUP_HOME}/${LATEST_BACKUP}"
}

[[ -d "$BACKUP_HOME" ]] || mkdir -p "$BACKUP_HOME"
[[ -d "$RSYNC_DIR" ]] || mkdir -p "$RSYNC_DIR"

save_diskinfo
backup_root_filesystem

[[ "$1" == "savestate" ]] && create_backup_tarball
