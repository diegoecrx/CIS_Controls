#!/bin/bash
# CIS Oracle Linux 7 - 1.4.4 Ensure core dump storage is disabled
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.4.4 - Disable core dump storage ==="

COREDUMP_CONF="/etc/systemd/coredump.conf"

# Create file if it doesnt exist
if [ ! -f "$COREDUMP_CONF" ]; then
    echo "[Coredump]" > "$COREDUMP_CONF"
fi

# Add or update Storage
if grep -q "^Storage" "$COREDUMP_CONF" 2>/dev/null; then
    sed -i 's/^Storage.*/Storage=none/' "$COREDUMP_CONF"
else
    echo "Storage=none" >> "$COREDUMP_CONF"
fi

echo " - Set Storage=none in $COREDUMP_CONF"
echo " - Core dump storage disabled"
