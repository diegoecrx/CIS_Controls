#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.1.4 Ensure noexec option set on /tmp partition
# Compatible with OCI (Oracle Cloud Infrastructure)
# WARNING: Setting noexec may prevent installation of some 3rd party software

set -e

echo "=== CIS 1.1.2.1.4 - Set noexec on /tmp partition ==="
echo "WARNING: Setting noexec may prevent installation of some 3rd party software!"

if findmnt -nk /tmp > /dev/null 2>&1; then
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    
    if grep -q "^\s*[^#].*\s/tmp\s" /etc/fstab; then
        if ! grep "^\s*[^#].*\s/tmp\s" /etc/fstab | grep -q "noexec"; then
            sed -i '/\s\/tmp\s/ s/defaults/defaults,noexec/' /etc/fstab
            echo " - Added noexec option to /tmp in /etc/fstab"
        else
            echo " - noexec option already set for /tmp in /etc/fstab"
        fi
    fi
    
    mount -o remount /tmp
    echo " - Remounted /tmp"
else
    echo " - /tmp is not a separate partition. Please run 1.1.2.1.1 first."
fi

echo " - noexec configuration for /tmp complete"
