#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.1.2.6.3 Ensure nosuid option set on /var/log partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.6.3 - Set nosuid on /var/log partition ==="

if findmnt -nk /var/log > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var/log\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var/log\s" /etc/fstab | grep -q "nosuid"; then
            sed -i '/\s\/var\/log\s/ s/defaults/defaults,nosuid/' /etc/fstab
            echo " - Added nosuid option to /var/log in /etc/fstab"
        else
            echo " - nosuid option already set for /var/log in /etc/fstab"
        fi
    fi
    
    mount -o remount /var/log
    echo " - Remounted /var/log"
else
    echo " - /var/log is not a separate partition."
fi

echo " - nosuid configuration for /var/log complete"
