#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.1.2.1.3 Ensure nosuid option set on /tmp partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.1.3 - Set nosuid on /tmp partition ==="

if findmnt -nk /tmp > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/tmp\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/tmp\s" /etc/fstab | grep -q "nosuid"; then
            sed -i '/\s\/tmp\s/ s/defaults/defaults,nosuid/' /etc/fstab
            echo " - Added nosuid option to /tmp in /etc/fstab"
        else
            echo " - nosuid option already set for /tmp in /etc/fstab"
        fi
    fi
    
    mount -o remount /tmp
    echo " - Remounted /tmp"
else
    echo " - /tmp is not a separate partition. Please run 1.1.2.1.1 first."
fi

echo " - nosuid configuration for /tmp complete"
