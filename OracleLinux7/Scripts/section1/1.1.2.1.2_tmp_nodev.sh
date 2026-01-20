#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.1.2.1.2 Ensure nodev option set on /tmp partition
# This script sets nodev option on /tmp partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.1.2 - Set nodev on /tmp partition ==="

# Check if /tmp exists as a partition
if findmnt -nk /tmp > /dev/null 2>&1; then
    # Backup fstab
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    # Add nodev if not present in fstab for /tmp
    if grep -q "^\s*[^#].*\s/tmp\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/tmp\s" /etc/fstab | grep -q "nodev"; then
            sed -i '/\s\/tmp\s/ s/defaults/defaults,nodev/' /etc/fstab
            echo " - Added nodev option to /tmp in /etc/fstab"
        else
            echo " - nodev option already set for /tmp in /etc/fstab"
        fi
    fi
    
    # Remount /tmp with nodev
    mount -o remount /tmp
    echo " - Remounted /tmp"
else
    echo " - /tmp is not a separate partition. Please run 1.1.2.1.1 first."
fi

echo " - nodev configuration for /tmp complete"
