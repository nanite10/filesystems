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
