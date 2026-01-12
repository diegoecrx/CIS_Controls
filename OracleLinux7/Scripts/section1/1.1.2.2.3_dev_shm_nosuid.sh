#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.2.3 Ensure nosuid option set on /dev/shm partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.2.3 - Set nosuid on /dev/shm partition ==="

cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)

if grep -q "^\s*[^#].*\s/dev/shm\s" /etc/fstab; then
    if ! grep "^\s*[^#].*\s/dev/shm\s" /etc/fstab | grep -q "nosuid"; then
        sed -i '/\s\/dev\/shm\s/ s/defaults/defaults,nosuid/' /etc/fstab
        echo " - Added nosuid option to /dev/shm in /etc/fstab"
    else
        echo " - nosuid option already set for /dev/shm in /etc/fstab"
    fi
fi

mount -o remount /dev/shm
echo " - Remounted /dev/shm"
echo " - nosuid configuration for /dev/shm complete"
