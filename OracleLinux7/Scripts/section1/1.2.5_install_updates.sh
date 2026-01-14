#!/bin/bash
# CIS Oracle Linux 7 - 1.2.5 Ensure updates, patches, and additional security software are installed
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.2.5 - Install updates and patches ==="

echo "Checking for available updates..."
if yum check-update; then
    echo "PASS: System is up to date"
else
    echo "Updates are available. Installing..."
    yum update -y
    echo " - Updates installed"
    
    # Check if reboot is needed
    if needs-restarting -r > /dev/null 2>&1; then
        echo " - Reboot is required to complete updates"
    else
        echo " - No reboot required"
    fi
fi

echo " - Update check complete"
