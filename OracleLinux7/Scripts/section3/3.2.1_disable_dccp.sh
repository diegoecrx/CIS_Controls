#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.2.1
# Ensure dccp kernel module is not available
# This script disables the dccp kernel module

set -e

echo "CIS 3.2.1 - Disabling dccp kernel module..."

MODULE_NAME="dccp"

# Create modprobe config to prevent loading
if ! grep -qE "^\s*install\s+$MODULE_NAME\s+/bin/(true|false)" /etc/modprobe.d/*.conf 2>/dev/null; then
    echo "install $MODULE_NAME /bin/false" >> /etc/modprobe.d/${MODULE_NAME}.conf
    echo "Module $MODULE_NAME set to not loadable."
fi

# Blacklist the module
if ! grep -qE "^\s*blacklist\s+$MODULE_NAME" /etc/modprobe.d/*.conf 2>/dev/null; then
    echo "blacklist $MODULE_NAME" >> /etc/modprobe.d/${MODULE_NAME}.conf
    echo "Module $MODULE_NAME blacklisted."
fi

# Unload the module if currently loaded
if lsmod | grep -q "^$MODULE_NAME\s"; then
    modprobe -r $MODULE_NAME 2>/dev/null || echo "Could not unload $MODULE_NAME - may require reboot."
fi

echo "CIS 3.2.1 remediation complete - dccp module disabled."