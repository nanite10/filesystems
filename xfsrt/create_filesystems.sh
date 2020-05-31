#!/bin/bash

filesystem_name="$1"

if ! [ -d "/mnt/$filesystem_name" ]; then exit 1; fi

if ! grep -q "[[:blank:]]/mnt/$filesystem_name[[:blank:]]" /proc/mounts; then exit 1; fi

if ! [ -d "/mnt/$filesystem_name/brick" ]; then exit 1; fi

gluster volume create "$filesystem_name" replica 2 c8s01:/mnt/$filesystem_name/brick c8s02:/mnt/$filesystem_name/brick force
gluster volume start "$filesystem_name"
cat: cat: No such file or directory
#!/bin/bash

filesystem_name="$1"

if ! [ -d "/mnt/$filesystem_name" ]; then exit 1; fi

if ! grep -q "[[:blank:]]/mnt/$filesystem_name[[:blank:]]" /proc/mounts; then exit 1; fi

if ! [ -d "/mnt/$filesystem_name/brick" ]; then exit 1; fi

gluster volume create "$filesystem_name" replica 2 c8s01:/mnt/$filesystem_name/brick c8s02:/mnt/$filesystem_name/brick force
gluster volume start "$filesystem_name"
[root@c8s01 ~]# cat create_filesystems.sh
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
zpool create zfs /dev/vdb
zfs set recordsize=4K zfs
zfs set mountpoint=/mnt/zfs zfs
mkdir -p /mnt/zfs/brick

zpool create zfsrt /dev/vdf
zpool add zfsrt special /dev/vdd
zfs set recordsize=4K zfsrt
zfs set mountpoint=/mnt/zfsrt zfsrt
mkdir -p /mnt/zfsrt/brick

zpool create zfstier /dev/vdj
zpool add zfstier special /dev/vdh
zfs set recordsize=4K zfstier
zfs set mountpoint=/mnt/zfstier zfstier
zfs set special_small_blocks=32K zfstier
mkdir -p /mnt/zfstier/brick

#echo "y" | mdadm --create --quiet --force /dev/md0 --level=1 --raid-devices=2 /dev/vdl /dev/vdm
#echo "y" | mdadm --create --quiet --force /dev/md1 --level=1 --raid-devices=2 /dev/vdn /dev/vdo
#echo "y" | mdadm --create --quiet --force /dev/md2 --level=1 --raid-devices=2 /dev/vdp /dev/sda

#for device in md0 md1 md2; do parted -s /dev/$device mklabel gpt; parted -s -a optimal /dev/$device mkpart primary 0% 100%FREE; done
for device in vdl vdn vdp; do parted -s /dev/$device mklabel gpt; parted -s -a optimal /dev/$device mkpart primary 0% 100%FREE; done

mkfs.xfs -f /dev/vdl1
mkdir -p /mnt/xfs
mount -t xfs /dev/vdl1 /mnt/xfs
mkdir -p /mnt/xfs/brick

mkfs.xfs -m reflink=0 -r rtdev=/dev/vdn1 /dev/vdp1
mkdir -p /mnt/xfsrt
mount -t xfs -o rtdev=/dev/vdn1 /dev/vdp1 /mnt/xfsrt
mkdir -p /mnt/xfsrt/brick
