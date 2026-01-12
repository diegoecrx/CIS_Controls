#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.6.4 Ensure noexec option set on /var/log partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.6.4 - Set noexec on /var/log partition ==="

if findmnt -nk /var/log > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var/log\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var/log\s" /etc/fstab | grep -q "noexec"; then
            sed -i '/\s\/var\/log\s/ s/defaults/defaults,noexec/' /etc/fstab
            echo " - Added noexec option to /var/log in /etc/fstab"
        else
            echo " - noexec option already set for /var/log in /etc/fstab"
        fi
    fi
    
    mount -o remount /var/log
    echo " - Remounted /var/log"
else
    echo " - /var/log is not a separate partition."
fi

echo " - noexec configuration for /var/log complete"
