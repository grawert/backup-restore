#!/bin/bash

## Set global script variables

RESTORE_ISO_FILE="restore.iso"

#BACKUP_HOME="/backup/adminnode"
BACKUP_HOME="/var/tmp"
BACKUP_RSYNC="${BACKUP_HOME}/TREE"
BACKUP_FILE="${BACKUP_HOME}/backup.tar.gz"

GRML_ISO="${BACKUP_HOME}/grml64-small_2017.05.iso"
GRML_DIR="grml"

## check if we run as root user

[[ "$EUID" == "0" ]] || { echo "Need to be run as root user!"; exit 1; }

## check if tools are installed

[[ -x $(command -v tar) ]] || { echo "tar is not installed!"; exit 1; }
[[ -x $(command -v date) ]] || { echo "date is not installed!"; exit 1; }
[[ -x $(command -v rsync) ]] || { echo "rsnyc is not installed!"; exit 1; }
[[ -x $(command -v mkisofs) ]] || { echo "mkisofs is not installed!"; exit 1; }
