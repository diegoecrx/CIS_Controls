#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.1.2.3.1 Ensure separate partition exists for /home
# Compatible with OCI (Oracle Cloud Infrastructure)
# NOTE: This is a manual review item - requires partition creation during install

echo "=== CIS 1.1.2.3.1 - Ensure separate partition exists for /home ==="
echo "NOTE: This control requires a separate partition for /home."
echo "For new installations, create a custom partition setup during installation."
echo "For existing systems, this requires creating a new partition and migrating data."
echo ""

# Check current status
if findmnt -nk /home > /dev/null 2>&1; then
    echo "PASS: /home is mounted as a separate partition"
    findmnt -nk /home
else
    echo "FAIL: /home is NOT a separate partition"
    echo "Manual intervention required to create separate partition for /home"
fi
