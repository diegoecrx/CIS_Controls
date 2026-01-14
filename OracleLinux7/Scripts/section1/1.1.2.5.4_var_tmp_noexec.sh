#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.5.4 Ensure noexec option set on /var/tmp partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.5.4 - Set noexec on /var/tmp partition ==="

if findmnt -nk /var/tmp > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var/tmp\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var/tmp\s" /etc/fstab | grep -q "noexec"; then
            sed -i '/\s\/var\/tmp\s/ s/defaults/defaults,noexec/' /etc/fstab
            echo " - Added noexec option to /var/tmp in /etc/fstab"
        else
            echo " - noexec option already set for /var/tmp in /etc/fstab"
        fi
    fi
    
    mount -o remount /var/tmp
    echo " - Remounted /var/tmp"
else
    echo " - /var/tmp is not a separate partition."
fi

echo " - noexec configuration for /var/tmp complete"
