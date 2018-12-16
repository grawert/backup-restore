#!/bin/bash

ISO_IMAGE=/var/tmp/restore.iso
DISK=/var/lib/libvirt/images/restore.qcow2

[[ -z "$1" ]] || ISO_IMAGE=$1
[[ -z "$2" ]] || DISK=$2

qemu-system-x86_64 \
 -m 1024 \
 -enable-kvm \
 -name "restore-to-vm" \
 -bios /usr/share/qemu/ovmf-x86_64-code.bin \
 -device virtio-serial-pci \
 -serial mon:stdio \
 -drive file=${ISO_IMAGE},format=raw,if=none,readonly=on,id=cd0 \
 -device ide-cd,bus=ide.0,unit=0,drive=cd0,id=ide0-0-0,bootindex=3 \
 -drive file=${DISK},format=qcow2,if=none,id=d0 \
 -device virtio-blk-pci,drive=d0,id=vda,bootindex=2
