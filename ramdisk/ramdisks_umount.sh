#!/bin/bash

umount /mnt/xfsram
zpool destroy zfsram
umount /mnt/xfsrtram
zpool destroy zfsrtram
