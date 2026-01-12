#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.5.2 Ensure nodev option set on /var/tmp partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.5.2 - Set nodev on /var/tmp partition ==="

if findmnt -nk /var/tmp > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var/tmp\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var/tmp\s" /etc/fstab | grep -q "nodev"; then
            sed -i '/\s\/var\/tmp\s/ s/defaults/defaults,nodev/' /etc/fstab
            echo " - Added nodev option to /var/tmp in /etc/fstab"
        else
            echo " - nodev option already set for /var/tmp in /etc/fstab"
        fi
    fi
    
    mount -o remount /var/tmp
    echo " - Remounted /var/tmp"
else
    echo " - /var/tmp is not a separate partition."
fi

echo " - nodev configuration for /var/tmp complete"
