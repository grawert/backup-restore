#!/bin/bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/config.sh
DISK="${BACKUP_HOME}/restore.qcow2"
EFI_FIRMWARE="/usr/share/qemu/ovmf-x86_64-code.bin"

if [[ $DISK =~ \.(.+)$ ]]; then
    DISK_FORMAT=${BASH_REMATCH[1]}
else
    DISK_FORMAT="qcow2"
fi

[[ -z "$1" ]] || DISK=$1
[[ -z "$2" ]] || ISO_IMAGE=$2

qemu-system-x86_64 \
 -no-user-config \
 -nographic \
 -m 4G \
 -enable-kvm \
 -name "restore-to-vm" \
 -bios "${EFI_FIRMWARE}" \
 -device virtio-serial-pci \
 -serial mon:stdio \
 -drive file="${RESTORE_ISO_FILE}",format=raw,if=none,readonly=on,id=cd0 \
 -device ide-cd,bus=ide.0,unit=0,drive=cd0,id=ide0-0-0,bootindex=3 \
 -drive file="${DISK}",format=${DISK_FORMAT},if=none,id=d0 \
 -device virtio-blk-pci,drive=d0,id=vda,bootindex=2 \
 -netdev user,id=hostnet0,restrict=y \
 -device virtio-net-pci,netdev=hostnet0,id=net0,mac="00:25:b5:a0:00:fe" \
 -netdev user,id=hostnet1,restrict=y \
 -device virtio-net-pci,netdev=hostnet1,id=net1,mac="00:25:b5:b0:02:d0"
