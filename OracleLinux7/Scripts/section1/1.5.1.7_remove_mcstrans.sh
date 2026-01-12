#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.7 Ensure the MCS Translation Service (mcstrans) is not installed
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.7 - Remove mcstrans ==="

if rpm -q mcstrans > /dev/null 2>&1; then
    yum remove -y mcstrans
    echo " - mcstrans removed"
else
    echo " - mcstrans is not installed"
fi

echo " - mcstrans check complete"
