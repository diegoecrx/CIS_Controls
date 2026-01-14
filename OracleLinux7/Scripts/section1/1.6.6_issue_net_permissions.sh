#!/bin/bash
# CIS Oracle Linux 7 - 1.6.6 Ensure access to /etc/issue.net is configured
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.6 - Configure /etc/issue.net permissions ==="

if [ -f /etc/issue.net ]; then
    chown root:root "$(readlink -e /etc/issue.net)"
    chmod u-x,go-wx "$(readlink -e /etc/issue.net)"
    echo " - Set permissions on /etc/issue.net"
else
    echo " - /etc/issue.net does not exist"
fi

echo " - /etc/issue.net permissions configuration complete"
