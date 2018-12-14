qemu-system-x86_64 --enable-kvm \
 -name "restore-to-vm" \
 -m 1024 \
 -bios /usr/share/qemu/ovmf-x86_64-code.bin \
 -drive file=/var/tmp/restore.iso,format=raw,if=none,id=cd0,readonly=on \
 -device ide-cd,bus=ide.0,unit=0,drive=cd0,id=ide0-0-0,bootindex=1 \
 -drive file=/var/lib/libvirt/images/test.qcow2,format=qcow2,if=none,id=virtio-d0 \
 -device virtio-blk-pci,drive=virtio-d0,id=vda,bootindex=2
