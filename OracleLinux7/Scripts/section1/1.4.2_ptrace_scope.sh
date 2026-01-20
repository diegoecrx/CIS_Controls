#!/bin/bash
export PATH="/sbin:/usr/sbin:$PATH"
# CIS Oracle Linux 7 - 1.4.2 Ensure ptrace_scope is restricted
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.4.2 - Restrict ptrace_scope ==="

SYSCTL_FILE="/etc/sysctl.d/60-kernel_sysctl.conf"
PARAM="kernel.yama.ptrace_scope"
VALUE="1"

# Create the sysctl.d directory if it doesn't exist
mkdir -p /etc/sysctl.d

# Remove any existing settings from all sysctl files (including vendor files)
for f in /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i "/^[[:space:]]*${PARAM}[[:space:]]*=/d" "$f" 2>/dev/null || true
    fi
done

# Add the correct setting to our config file
echo "$PARAM = $VALUE" >> "$SYSCTL_FILE"
echo " - Added $PARAM = $VALUE to $SYSCTL_FILE"

# Apply immediately
sysctl -w ${PARAM}=${VALUE}
echo " - Applied ${PARAM}=${VALUE} to running system"

echo " - ptrace_scope configuration complete"
