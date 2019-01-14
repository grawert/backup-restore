#!/bin/bash

## Set global script variables

BACKUP_HOME="/backup/adminnode"

RESTORE_ISO_FILE="${BACKUP_HOME}/restore.iso"
GRML_ISO="${BACKUP_HOME}/grml64-small_2017.05.iso"
GRML_DIR="${BACKUP_HOME}/grml"
RSYNC_DIR="${BACKUP_HOME}/TREE"

LATEST_BACKUP="backup.tar.gz"
DISKINFO_FILE='diskinfo.txt'
TAR_SPLIT_VOLUME_NAME="backup"
ISO_MAX_FILE_SIZE="2G"

## check if we run as root user

[[ "$EUID" == "0" ]] || { echo "Need to be run as root user!"; exit 1; }

## check if tools are installed

[[ -x $(command -v tar) ]] || { echo "tar is not installed!"; exit 1; }
[[ -x $(command -v date) ]] || { echo "date is not installed!"; exit 1; }
[[ -x $(command -v rsync) ]] || { echo "rsnyc is not installed!"; exit 1; }
[[ -x $(command -v lsblk) ]] || { echo "lsblk is not installed!"; exit 1; }
[[ -x $(command -v parted) ]] || { echo "parted is not installed!"; exit 1; }
[[ -x $(command -v mkisofs) ]] || { echo "mkisofs is not installed!"; exit 1; }
