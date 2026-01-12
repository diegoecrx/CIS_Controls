#!/bin/bash
# CIS Oracle Linux 7 - 1.6.1 Ensure message of the day is configured properly
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.1 - Configure message of the day ==="

MOTD_FILE="/etc/motd"

# Remove or configure /etc/motd
if [ -f "$MOTD_FILE" ]; then
    # Remove OS info references
    sed -i 's/\\m//g; s/\\r//g; s/\\s//g; s/\\v//g' "$MOTD_FILE"
    echo " - Cleaned /etc/motd of OS references"
else
    echo " - /etc/motd does not exist (OK)"
fi

echo " - MOTD configuration complete"
