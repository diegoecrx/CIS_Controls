#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.4 Ensure the SELinux mode is not disabled
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.4 - Ensure SELinux mode is not disabled ==="

SELINUX_CONFIG="/etc/selinux/config"

# Set to enforcing mode (recommended)
setenforce 1 2>/dev/null || echo " - Note: Cannot set enforcing mode (may already be in enforcing or system restrictions)"

if [ -f "$SELINUX_CONFIG" ]; then
    if grep -q "^SELINUX=" "$SELINUX_CONFIG"; then
        sed -i 's/^SELINUX=.*/SELINUX=enforcing/' "$SELINUX_CONFIG"
    else
        echo "SELINUX=enforcing" >> "$SELINUX_CONFIG"
    fi
    echo " - Set SELINUX=enforcing in $SELINUX_CONFIG"
fi

echo " - Current SELinux status:"
getenforce

echo " - SELinux mode configuration complete"
