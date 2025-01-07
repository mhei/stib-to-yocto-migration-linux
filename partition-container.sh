#!/bin/sh

IMAGE="$1"
PARTSCHEME="$2"

if [ "$PARTSCHEME" = 1 ]; then
	cat <<-EOF | sfdisk "$IMAGE"
	label: dos
	label-id: 0x5452574f
	device: /dev/mmcblk0
	unit: sectors
	
	/dev/mmcblk0p1 : start=        2048, size=       16384, type=53, bootable
	EOF
else
	cat <<-EOF | sfdisk "$IMAGE"
	label: dos
	label-id: 0x5452574f
	device: /dev/mmcblk0
	unit: sectors
	
	/dev/mmcblk0p1 : start=          16, size=       73729, type= b
	/dev/mmcblk0p2 : start=       73745, size=       68077, type=53, bootable
	EOF
fi
