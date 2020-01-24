#!/bin/bash

# Clean up existing disks
while read pool; do
  echo "Destroying zpool $pool"
  zpool destroy "$pool" > /dev/null
done < <(zpool list -o name -H)

while read pool; do
  echo "Unmounting xfs filesystem $pool"
  umount "$pool" > /dev/null
done < <(grep "xfs" /proc/mounts | grep dev | grep -v "\/dev/vda" | awk '{print $1}')

while read mdraid; do
  mdadm --stop "/dev/$mdraid"
done < <(grep "^md" /proc/mdstat  | awk '{print $1}' | sort)

while read blockdevice; do
  echo "Wiping /dev/$blockdevice"
  wipefs -a /dev/$blockdevice
  timeout 5 dd if=/dev/zero of=/dev/$blockdevice > /dev/null
done < <(ls /sys/block/ | grep "vd[a-z]\|sd[a-z]" | grep -v "^vda$")

# Create filesystems
zpool create zfs mirror /dev/vdb /dev/vdc
zfs set recordsize=4K zfs
zfs set mountpoint=/mnt/zfs zfs
mkdir -p /mnt/zfs/brick

zpool create zfsrt mirror /dev/vdf /dev/vdg
zpool add zfsrt special mirror /dev/vdd /dev/vde
zfs set recordsize=4K zfsrt
zfs set mountpoint=/mnt/zfsrt zfsrt
mkdir -p /mnt/zfsrt/brick

zpool create zfstier mirror /dev/vdj /dev/vdk
zpool add zfstier special mirror /dev/vdh /dev/vdi
zfs set recordsize=4K zfstier
zfs set mountpoint=/mnt/zfstier zfstier
zfs set special_small_blocks=32K zfstier
mkdir -p /mnt/zfstier/brick

echo "y" | mdadm --create --quiet --force /dev/md0 --level=1 --raid-devices=2 /dev/vdl /dev/vdm
echo "y" | mdadm --create --quiet --force /dev/md1 --level=1 --raid-devices=2 /dev/vdn /dev/vdo
echo "y" | mdadm --create --quiet --force /dev/md2 --level=1 --raid-devices=2 /dev/vdp /dev/sda

for device in md0 md1 md2; do parted -s /dev/$device mklabel gpt; parted -s -a optimal /dev/$device mkpart primary 0% 100%FREE; done

mkfs.xfs -f /dev/md0p1
mkdir -p /mnt/xfs
mount -t xfs /dev/md0p1 /mnt/xfs
mkdir -p /mnt/xfs/brick

mkfs.xfs -m reflink=0 -r rtdev=/dev/md1p1 /dev/md2p1
mkdir -p /mnt/xfsrt
mount -t xfs -o rtdev=/dev/md1p1 /dev/md2p1 /mnt/xfsrt
mkdir -p /mnt/xfsrt/brick
