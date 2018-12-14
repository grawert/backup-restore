# xorriso -as mkisofs -r -V "Backup $HOSTNAME" \
#  -hide-rr-moved \
#  -boot-info-table \
#  -boot-load-size 4 \
#  -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
#  -no-emul-boot \
#  -eltorito-alt-boot -e boot/efi.img \
#  -no-emul-boot \
#  -o restore.iso \
#  grml_original
mkisofs -r -V "BACKUP" \
 -o restore.iso \
 -c boot/isolinux/boot.cat \
 -b boot/isolinux/isolinux.bin \
 -no-emul-boot -boot-load-size 4 -boot-info-table \
 -eltorito-alt-boot \
 -eltorito-platform 0xEF -eltorito-boot boot/efi.img \
 -no-emul-boot \
 grml_original
