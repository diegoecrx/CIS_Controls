#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.7.4 Ensure noexec option set on /var/log/audit partition
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.1.2.7.4 - Set noexec on /var/log/audit partition ==="

if findmnt -nk /var/log/audit > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/var/log/audit\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/var/log/audit\s" /etc/fstab | grep -q "noexec"; then
            sed -i '/\s\/var\/log\/audit\s/ s/defaults/defaults,noexec/' /etc/fstab
            echo " - Added noexec option to /var/log/audit in /etc/fstab"
        else
            echo " - noexec option already set for /var/log/audit in /etc/fstab"
        fi
    fi
    
    mount -o remount /var/log/audit
    echo " - Remounted /var/log/audit"
else
    echo " - /var/log/audit is not a separate partition."
fi

echo " - noexec configuration for /var/log/audit complete"
