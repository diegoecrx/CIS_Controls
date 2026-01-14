#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.2.4 Ensure noexec option set on /dev/shm partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.2.4 - Set noexec on /dev/shm partition ==="

cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)

if grep -q "^\s*[^#].*\s/dev/shm\s" /etc/fstab; then
    if ! grep "^\s*[^#].*\s/dev/shm\s" /etc/fstab | grep -q "noexec"; then
        sed -i '/\s\/dev\/shm\s/ s/defaults/defaults,noexec/' /etc/fstab
        echo " - Added noexec option to /dev/shm in /etc/fstab"
    else
        echo " - noexec option already set for /dev/shm in /etc/fstab"
    fi
fi

mount -o remount /dev/shm
echo " - Remounted /dev/shm"
echo " - noexec configuration for /dev/shm complete"
