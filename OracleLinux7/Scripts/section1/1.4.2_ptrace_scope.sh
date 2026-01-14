#!/bin/bash
# CIS Oracle Linux 7 - 1.4.2 Ensure ptrace_scope is restricted
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.4.2 - Restrict ptrace_scope ==="

SYSCTL_FILE="/etc/sysctl.d/60-kernel_sysctl.conf"

if ! grep -q "^kernel.yama.ptrace_scope" "$SYSCTL_FILE" 2>/dev/null; then
    echo "kernel.yama.ptrace_scope = 1" >> "$SYSCTL_FILE"
    echo " - Added kernel.yama.ptrace_scope = 1 to $SYSCTL_FILE"
else
    sed -i 's/^kernel.yama.ptrace_scope.*/kernel.yama.ptrace_scope = 1/' "$SYSCTL_FILE"
    echo " - Updated kernel.yama.ptrace_scope = 1 in $SYSCTL_FILE"
fi

# Apply immediately
sysctl -w kernel.yama.ptrace_scope=1
echo " - Applied kernel.yama.ptrace_scope=1 to running system"

echo " - ptrace_scope configuration complete"
