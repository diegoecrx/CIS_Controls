#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.4.2 Ensure nodev option set on /var partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.4.2 - Set nodev on /var partition ==="

if findmnt -nk /var > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var\s" /etc/fstab | grep -q "nodev"; then
            sed -i '/\s\/var\s/ s/defaults/defaults,nodev/' /etc/fstab
            echo " - Added nodev option to /var in /etc/fstab"
        else
            echo " - nodev option already set for /var in /etc/fstab"
        fi
    fi
    
    mount -o remount /var
    echo " - Remounted /var"
else
    echo " - /var is not a separate partition."
fi

echo " - nodev configuration for /var complete"
