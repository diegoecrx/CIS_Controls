#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.2.1 Ensure /dev/shm is a separate partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.2.1 - Configure /dev/shm partition ==="

# Backup fstab
cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)

# Check if entry already exists in fstab
if ! grep -q "^\s*tmpfs\s*/dev/shm" /etc/fstab; then
    echo "tmpfs   /dev/shm        tmpfs defaults,rw,nosuid,nodev,noexec,relatime,size=2G 0 0" >> /etc/fstab
    echo " - Added /dev/shm entry to /etc/fstab"
else
    echo " - /dev/shm entry already exists in /etc/fstab"
fi

# Remount /dev/shm
mount -o remount /dev/shm
echo " - Remounted /dev/shm"

echo " - /dev/shm partition configuration complete"
