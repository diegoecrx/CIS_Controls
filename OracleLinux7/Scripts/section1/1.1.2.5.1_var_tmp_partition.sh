#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.1.2.5.1 Ensure separate partition exists for /var/tmp
# Compatible with OCI (Oracle Cloud Infrastructure)

echo "=== CIS 1.1.2.5.1 - Ensure separate partition exists for /var/tmp ==="

if findmnt -nk /var/tmp > /dev/null 2>&1; then
    echo "PASS: /var/tmp is mounted as a separate partition"
    findmnt -nk /var/tmp
else
    echo "FAIL: /var/tmp is NOT a separate partition"
    echo "Manual intervention required to create separate partition for /var/tmp"
fi
