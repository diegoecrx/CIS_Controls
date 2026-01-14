#!/bin/bash
# CIS Oracle Linux 7 - 1.1.2.4.1 Ensure separate partition exists for /var
# Compatible with OCI (Oracle Cloud Infrastructure)
# NOTE: This is a manual review item - requires partition creation during install

echo "=== CIS 1.1.2.4.1 - Ensure separate partition exists for /var ==="
echo "NOTE: This control requires a separate partition for /var."
echo "For new installations, create a custom partition setup during installation."
echo "For existing systems, this requires creating a new partition and migrating data."
echo ""

if findmnt -nk /var > /dev/null 2>&1; then
    echo "PASS: /var is mounted as a separate partition"
    findmnt -nk /var
else
    echo "FAIL: /var is NOT a separate partition"
    echo "Manual intervention required to create separate partition for /var"
fi
