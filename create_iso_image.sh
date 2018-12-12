mkisofs -pad -l -r -J -v -V "Backup $HOSTNAME" -no-emul-boot -boot-load-size 4 \
 -boot-info-table \
 -b boot/isolinux/isolinux.bin \
 -c boot/isolinux/boot.cat \
 -hide-rr-moved \
 -o restore.iso \
 grml_original
