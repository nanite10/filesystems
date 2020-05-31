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
