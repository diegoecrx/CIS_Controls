#!/bin/bash
# CIS Oracle Linux 7 - 1.6.5 Ensure access to /etc/issue is configured
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.5 - Configure /etc/issue permissions ==="

if [ -f /etc/issue ]; then
    chown root:root "$(readlink -e /etc/issue)"
    chmod u-x,go-wx "$(readlink -e /etc/issue)"
    echo " - Set permissions on /etc/issue"
else
    echo " - /etc/issue does not exist"
fi

echo " - /etc/issue permissions configuration complete"
