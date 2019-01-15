# File Based Backup & Restore

Scripts to make a file based backup of a Linux filesystem using _rsync_ and
_tar_. Restore is using a [GRML](http://grml.org/) rescue image containing the
backup tarball.

## Configuration

Edit _config.sh_ to set the `BACKUP_HOME` directory. This is where backup
files are created and the rescue image is created. Define files and directories
to exclude from backup in file _exclude-files.txt_.

## Download GRML iso image

Download the _GRML_ iso-image and place it inside `BACKUP_HOME` directory.

```shell
curl -O -L http://download.grml.org/grml64-small_2017.05.iso
```

## Backup

Create a backup of the filesystem with rsync. The parameter `backup` is creating
a backup tree of the filesystem at `BACKUP_HOME`. The parameter `tar` will
create a tarball of the backup tree which is saved to `BACKUP_HOME` directory.

```shell
bash backup.sh backup
```

```shell
bash backup.sh tar
```

## Adapt _restore.sh_

The _restore.sh_ script is executed automatically when the restore ISO image
is booting. The script is creating partition tables and filesystems. It is
configured to recreate the admin nodes for CCIE environments.

If this is not suitable the _restore.sh_ script needs to be adapted before
creating the rescue ISO image. Partition and filesystem informations of the
backed up system is stored at `BACKUP_HOME`/diskinfo.txt.

## Create the rescue image

Create a rescue image containing the backup tarball and _restore.sh_.
Once the image is bootet, it will create partitions and filesystems on the
disk defined with `DISK` inside _restore.sh_.

```shell
bash create_iso_image.sh
```

# Boot rescue image using qemu

For testing purposes the restore image can be booted in isolated environment
using qemu. The network interface configuration might have to be adapted.

```shell
bash qemu-restore.sh
```
