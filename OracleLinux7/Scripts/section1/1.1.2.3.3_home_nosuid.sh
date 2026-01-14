#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.3.3 Ensure nosuid option set on /home partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.3.3 - Set nosuid on /home partition ==="

if findmnt -nk /home > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/home\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/home\s" /etc/fstab | grep -q "nosuid"; then
            sed -i '/\s\/home\s/ s/defaults/defaults,nosuid/' /etc/fstab
            echo " - Added nosuid option to /home in /etc/fstab"
        else
            echo " - nosuid option already set for /home in /etc/fstab"
        fi
    fi
    
    mount -o remount /home
    echo " - Remounted /home"
else
    echo " - /home is not a separate partition. Please run 1.1.2.3.1 first."
fi

echo " - nosuid configuration for /home complete"
