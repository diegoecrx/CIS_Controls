#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.3 Ensure SELinux policy is configured
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.3 - Configure SELinux policy ==="

SELINUX_CONFIG="/etc/selinux/config"

if [ -f "$SELINUX_CONFIG" ]; then
    # Set SELINUXTYPE to targeted
    if grep -q "^SELINUXTYPE=" "$SELINUX_CONFIG"; then
        sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' "$SELINUX_CONFIG"
    else
        echo "SELINUXTYPE=targeted" >> "$SELINUX_CONFIG"
    fi
    echo " - Set SELINUXTYPE=targeted in $SELINUX_CONFIG"
else
    echo "ERROR: $SELINUX_CONFIG not found"
    exit 1
fi

echo " - SELinux policy configuration complete"
