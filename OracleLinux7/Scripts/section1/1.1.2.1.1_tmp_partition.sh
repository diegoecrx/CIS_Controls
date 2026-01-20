#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.1.2.1.1 Ensure /tmp is a separate partition
# This script configures /tmp as a separate tmpfs partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.1.1 - Configure /tmp partition ==="

# Check if /tmp is already mounted
if findmnt -nk /tmp > /dev/null 2>&1; then
    echo " - /tmp is already mounted"
else
    echo " - Configuring /tmp as tmpfs"
    
    # Backup fstab
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    # Check if entry already exists in fstab
    if ! grep -q "^\s*tmpfs\s*/tmp" /etc/fstab; then
        echo "tmpfs   /tmp    tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
        echo " - Added /tmp entry to /etc/fstab"
    fi
fi

# Mount /tmp if not already mounted
if ! findmnt -nk /tmp > /dev/null 2>&1; then
    mount /tmp
    echo " - Mounted /tmp"
else
    # Remount with proper options
    mount -o remount,noexec,nodev,nosuid /tmp
    echo " - Remounted /tmp with secure options"
fi

echo " - /tmp partition configuration complete"
