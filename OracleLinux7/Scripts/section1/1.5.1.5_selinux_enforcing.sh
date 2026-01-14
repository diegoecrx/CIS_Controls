#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.5 Ensure the SELinux mode is enforcing
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.5 - Ensure SELinux mode is enforcing ==="

SELINUX_CONFIG="/etc/selinux/config"

# Set to enforcing mode
setenforce 1 2>/dev/null || echo " - Note: Cannot set enforcing mode at runtime"

if [ -f "$SELINUX_CONFIG" ]; then
    sed -i 's/^SELINUX=.*/SELINUX=enforcing/' "$SELINUX_CONFIG"
    echo " - Set SELINUX=enforcing in $SELINUX_CONFIG"
fi

echo " - Current SELinux status:"
getenforce

echo " - SELinux enforcing mode configuration complete"
