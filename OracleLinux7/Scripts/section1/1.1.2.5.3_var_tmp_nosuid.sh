#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.5.3 Ensure nosuid option set on /var/tmp partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.5.3 - Set nosuid on /var/tmp partition ==="

if findmnt -nk /var/tmp > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var/tmp\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var/tmp\s" /etc/fstab | grep -q "nosuid"; then
            sed -i '/\s\/var\/tmp\s/ s/defaults/defaults,nosuid/' /etc/fstab
            echo " - Added nosuid option to /var/tmp in /etc/fstab"
        else
            echo " - nosuid option already set for /var/tmp in /etc/fstab"
        fi
    fi
    
    mount -o remount /var/tmp
    echo " - Remounted /var/tmp"
else
    echo " - /var/tmp is not a separate partition."
fi

echo " - nosuid configuration for /var/tmp complete"
