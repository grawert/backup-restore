# File Based Backup & Restore

Scripts to make a file based backup of a Linux filesystem using _tar_. Restore
is using a [GRML](http://grml.org/) rescue image containing the backup tarball.

## Configuration

Edit _config.sh_ to set the `BACKUP_HOME` directory. This is where backup
files and the rescue image is created. Define files and directories to exclude
from backup in file _exclude-files.txt_.

## Backup

Create a backup of the filesystem with _tar_ which is saved to `BACKUP_HOME`
directory. A link to the latest backup is created with name _backup.tar.gz_.

```shell
bash backup.sh
```

## Restore

### Adapt _restore.sh_

The _restore.sh_ script is executed automatically when the restore ISO image
is booting. The script is creating partition tables and filesystems. It is
configured to recreate the admin nodes for CCIE environments.

If this is not suitable the _restore.sh_ script needs to be adapted before
creating the rescue ISO image. Partition and filesystem informations of the
backed up system is stored at `BACKUP_HOME`/diskinfo.txt.

### Create the rescue image

Download the _GRML_ iso-image and place it inside `BACKUP_HOME` directory.

```shell
curl -O -L http://download.grml.org/grml64-small_2017.05.iso
```

Create a rescue image containing the backup tarball and _restore.sh_.
Once the image is booted, it will create partitions and filesystems on the
disk defined with `DISK` inside _restore.sh_.

```shell
bash create_iso_image.sh
```

### Create virtual disk for qemu

```shell
qemu-img create -f qcow2 restore.qcow2 50g
```

### Boot rescue image using qemu

For restore testing the restore image can be booted in isolated environment
using qemu. The network interface configuration might have to be adapted.

```shell
bash qemu-restore.sh
```
