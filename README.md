# File Bases Backup & Restore

Scripts to make a file based backup of a Linux filesystem using `rsync` and
`tar`. Restore is using a `GRML` rescue image containing the backup tarball.

## Configuration

Edit `config.sh` to set the `BACKUP_HOME` directory. This is where backup
files are created and the rescue image is created.

## Download GRML iso image

Download the GRML iso-image and place it into `BACKUP_HOME` directory.

```shell
curl -O -L http://download.grml.org/grml64-small_2017.05.iso
```

## Backup

Create a backup of the filesystem with rsync. The parameter `savestate` is
creating a tarball of the backed up files. The tarball will be saved to
`BACKUP_HOME` directory.

```shell
bash backup.sh savestate
```

## Create the rescue image

Create a rescue image containing the backup tarball. Once the image is bootet,
it will create partitions and filesystems on the disk defined with `DISK`
inside `restore.sh`.

```shell
bash create_iso_image.sh
```

# Boot rescue image using qemu

```shell
bash qemu-restore.sh
```
