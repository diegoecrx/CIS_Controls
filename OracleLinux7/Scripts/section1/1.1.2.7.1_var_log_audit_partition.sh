#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.7.1 Ensure separate partition exists for /var/log/audit
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.1.2.7.1 - Ensure separate partition exists for /var/log/audit ==="

if findmnt -nk /var/log/audit > /dev/null 2>&1; then
    echo "PASS: /var/log/audit is mounted as a separate partition"
    findmnt -nk /var/log/audit
else
    echo "FAIL: /var/log/audit is NOT a separate partition"
    echo "Manual intervention required to create separate partition for /var/log/audit"
fi
