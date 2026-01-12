#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.4.3 Ensure nosuid option set on /var partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.4.3 - Set nosuid on /var partition ==="

if findmnt -nk /var > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var\s" /etc/fstab | grep -q "nosuid"; then
            sed -i '/\s\/var\s/ s/defaults/defaults,nosuid/' /etc/fstab
            echo " - Added nosuid option to /var in /etc/fstab"
        else
            echo " - nosuid option already set for /var in /etc/fstab"
        fi
    fi
    
    mount -o remount /var
    echo " - Remounted /var"
else
    echo " - /var is not a separate partition."
fi

echo " - nosuid configuration for /var complete"
