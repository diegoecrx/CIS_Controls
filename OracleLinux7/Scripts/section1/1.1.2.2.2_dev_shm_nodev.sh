#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.2.2 Ensure nodev option set on /dev/shm partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.2.2 - Set nodev on /dev/shm partition ==="

cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)

if grep -q "^\s*[^#].*\s/dev/shm\s" /etc/fstab; then
    if ! grep "^\s*[^#].*\s/dev/shm\s" /etc/fstab | grep -q "nodev"; then
        sed -i '/\s\/dev\/shm\s/ s/defaults/defaults,nodev/' /etc/fstab
        echo " - Added nodev option to /dev/shm in /etc/fstab"
    else
        echo " - nodev option already set for /dev/shm in /etc/fstab"
    fi
fi

mount -o remount /dev/shm
echo " - Remounted /dev/shm"
echo " - nodev configuration for /dev/shm complete"
