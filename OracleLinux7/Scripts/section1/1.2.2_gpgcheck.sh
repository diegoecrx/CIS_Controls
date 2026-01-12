#!/bin/bash
# CIS Oracle Linux 7 - 1.2.2 Ensure gpgcheck is globally activated
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.2.2 - Enable gpgcheck globally ==="

# Set gpgcheck=1 in yum.conf
if [ -f /etc/yum.conf ]; then
    sed -i 's/^gpgcheck\s*=\s*.*/gpgcheck=1/' /etc/yum.conf
    if ! grep -q "^gpgcheck" /etc/yum.conf; then
        echo "gpgcheck=1" >> /etc/yum.conf
    fi
    echo " - Set gpgcheck=1 in /etc/yum.conf"
fi

# Set gpgcheck=1 in all repo files
find /etc/yum.repos.d/ -name "*.repo" -exec sed -ri 's/^gpgcheck\s*=\s*.*/gpgcheck=1/' {} \;
echo " - Set gpgcheck=1 in all /etc/yum.repos.d/*.repo files"

echo " - gpgcheck configuration complete"
