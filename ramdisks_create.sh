#!/bin/bash

modprobe brd rd_size=1000000
mkfs.xfs -f /dev/ram0
mkdir -p /mnt/xfsram
mount /dev/ram0 /mnt/xfsram

modprobe brd rd_size=1000000
zpool create zfsram /dev/ram1
zfs set mountpoint=/mnt/zfsram zfsram
zfs set recordsize=4K zfsram

modprobe brd rd_size=1000000
for device in vdf; do wipefs -a /dev/$device; parted -s /dev/$device mklabel gpt; parted -s -a optimal /dev/$device mkpart primary 0% 100%FREE; done
mkfs.xfs -f -m reflink=0 -r rtdev=/dev/vdf1 /dev/ram2
mkdir -p /mnt/xfsrtram
mount -t xfs -o rtdev=/dev/vdf1 /dev/ram2 /mnt/xfsrtram

modprobe brd rd_size=1000000
zpool create zfsrtram /dev/vdi
zfs set mountpoint=/mnt/zfsrtram zfsrtram
zfs set recordsize=4K zfsrtram
zpool add zfsrtram special /dev/ram3
