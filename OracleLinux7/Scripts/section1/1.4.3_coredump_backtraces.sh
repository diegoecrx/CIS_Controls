#!/bin/bash
# CIS Oracle Linux 7 - 1.4.3 Ensure core dump backtraces are disabled
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.4.3 - Disable core dump backtraces ==="

COREDUMP_CONF="/etc/systemd/coredump.conf"

# Create file if it doesnt exist
if [ ! -f "$COREDUMP_CONF" ]; then
    echo "[Coredump]" > "$COREDUMP_CONF"
fi

# Add or update ProcessSizeMax
if grep -q "^ProcessSizeMax" "$COREDUMP_CONF" 2>/dev/null; then
    sed -i 's/^ProcessSizeMax.*/ProcessSizeMax=0/' "$COREDUMP_CONF"
else
    echo "ProcessSizeMax=0" >> "$COREDUMP_CONF"
fi

echo " - Set ProcessSizeMax=0 in $COREDUMP_CONF"
echo " - Core dump backtraces disabled"
