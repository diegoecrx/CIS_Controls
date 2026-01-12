#!/bin/bash
# CIS Oracle Linux 7 - 1.6.4 Ensure access to /etc/motd is configured
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.4 - Configure /etc/motd permissions ==="

if [ -f /etc/motd ]; then
    chown root:root "$(readlink -e /etc/motd)"
    chmod u-x,go-wx "$(readlink -e /etc/motd)"
    echo " - Set permissions on /etc/motd"
else
    echo " - /etc/motd does not exist (OK - no action needed)"
fi

echo " - /etc/motd permissions configuration complete"
