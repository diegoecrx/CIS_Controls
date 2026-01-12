#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.3.2 Ensure nodev option set on /home partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.3.2 - Set nodev on /home partition ==="

if findmnt -nk /home > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/home\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/home\s" /etc/fstab | grep -q "nodev"; then
            sed -i '/\s\/home\s/ s/defaults/defaults,nodev/' /etc/fstab
            echo " - Added nodev option to /home in /etc/fstab"
        else
            echo " - nodev option already set for /home in /etc/fstab"
        fi
    fi
    
    mount -o remount /home
    echo " - Remounted /home"
else
    echo " - /home is not a separate partition. Please run 1.1.2.3.1 first."
fi

echo " - nodev configuration for /home complete"
