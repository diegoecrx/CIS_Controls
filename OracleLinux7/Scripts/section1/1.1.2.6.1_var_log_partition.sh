#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.6.1 Ensure separate partition exists for /var/log
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.1.2.6.1 - Ensure separate partition exists for /var/log ==="

if findmnt -nk /var/log > /dev/null 2>&1; then
    echo "PASS: /var/log is mounted as a separate partition"
    findmnt -nk /var/log
else
    echo "FAIL: /var/log is NOT a separate partition"
    echo "Manual intervention required to create separate partition for /var/log"
fi
