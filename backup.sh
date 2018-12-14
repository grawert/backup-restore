#!/bin/bash

## desc: backup a server, e.g. admin-node for desaster recovery
##
## version: 0.4
## date: 2018-12-06
## author: Thorsten Schifferdecker
## author: Peter Hoffmann
## author: Uwe Grawert

BASEDIR=$(dirname $0)
source ${BASEDIR}/config.sh
TIMESTAMP=$(date --iso-8601=minutes)

set -e
set -x

[[ -d $BACKUP_HOME ]] || mkdir -p $BACKUP_HOME

function backup_root_filesystem {
  rsync \
    --archive \
    --xattrs \
    --hard-links \
    --delete-after \
    --numeric-ids \
    --exclude='/lost+found' \
    --exclude='/backup/*' \
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
    --exclude='/var/cache/*' \
    --exclude='/var/chef/cache/*' \
    --exclude='/var/log/lastlog' \
    --exclude='/var/tmp/*' \
    / $BACKUP_RSYNC 2> ${BACKUP_HOME}/error.log-${TIMESTAMP}
}

function create_backup_tarball {
  tar \
    --create \
    --gzip \
    --numeric-owner \
    --file=${BACKUP_HOME}/${HOSTNAME}-${TIMESTAMP}.tar.gz \
    -C $BACKUP_RSYNC . \
    2>&1 | egrep -v 'leading|ignored' >> ${BACKUP_HOME}/error.log-${TIMESTAMP}
}

backup_root_filesystem

[[ "$1" == "savestate" ]] && create_backup_tarball
