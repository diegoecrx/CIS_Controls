#!/bin/bash
# CIS Oracle Linux 7 - 1.4.1 Ensure ASLR is enabled
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.4.1 - Enable Address Space Layout Randomization (ASLR) ==="

# Set in sysctl.d
SYSCTL_FILE="/etc/sysctl.d/60-kernel_sysctl.conf"

if ! grep -q "^kernel.randomize_va_space" "$SYSCTL_FILE" 2>/dev/null; then
    echo "kernel.randomize_va_space = 2" >> "$SYSCTL_FILE"
    echo " - Added kernel.randomize_va_space = 2 to $SYSCTL_FILE"
else
    sed -i 's/^kernel.randomize_va_space.*/kernel.randomize_va_space = 2/' "$SYSCTL_FILE"
    echo " - Updated kernel.randomize_va_space = 2 in $SYSCTL_FILE"
fi

# Apply immediately
sysctl -w kernel.randomize_va_space=2
echo " - Applied kernel.randomize_va_space=2 to running system"

echo " - ASLR configuration complete"
