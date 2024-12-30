#!/bin/sh

IMAGE="$1"

cat <<EOF | sfdisk "$IMAGE"
label: dos
label-id: 0x5452574f
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        2048, size=       16384, type=53, bootable
EOF
