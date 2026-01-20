#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.6.1 Ensure message of the day is configured properly
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.6.1 - Configure message of the day ==="

MOTD_FILE="/etc/motd"

# Create proper MOTD without OS version info
cat > "$MOTD_FILE" << 'EOF'
Authorized uses only. All activity may be monitored and reported.
EOF

# Verify no OS-specific escape sequences
if grep -qE '\\[mrsv]' "$MOTD_FILE" 2>/dev/null; then
    sed -i 's/\\[mrsv]//g' "$MOTD_FILE"
fi

echo " - Configured /etc/motd with warning banner"
echo " - MOTD contents:"
cat "$MOTD_FILE"

echo ""
echo "CIS 1.6.1 remediation complete."
