#!/bin/bash

## Define interfaces by kernel names in order of appearance

set -e

ROOTFS_MOUNT='/mnt'
UDEV_RULES_FILE="${ROOTFS_MOUNT}/etc/udev/rules.d/70-persistent-net.rules"

echo > $UDEV_RULES_FILE

interfaces=$(find /sys/class/net -type l -not -lname '*virtual*' | sort)
for interface in $interfaces; do
    [[ $interface =~ .*/(.+)$ ]] || { echo "Could not extract interface name"; exit 1; }
    
    ifname=${BASH_REMATCH[1]}
    mac=$(cat ${interface}/address)

    UDEV_RULE="SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"${mac}\", ATTR{dev_id}==\"0x0\", ATTR{type}==\"1\", KERNEL==\"${ifname}\", NAME=\"${ifname}\""

    echo "${UDEV_RULE}" >> $UDEV_RULES_FILE
done
