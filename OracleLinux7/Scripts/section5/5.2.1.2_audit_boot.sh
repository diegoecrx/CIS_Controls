#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.1.2
# Ensure auditing for processes that start prior to auditd is enabled

set -e

echo "CIS 5.2.1.2 - Enabling audit for early boot processes..."

# Update grub configuration
grubby --update-kernel ALL --args 'audit=1'

# Also update /etc/default/grub for persistence
if grep -q "^GRUB_CMDLINE_LINUX=" /etc/default/grub; then
    if ! grep -q "audit=1" /etc/default/grub; then
        sed -i 's/\(GRUB_CMDLINE_LINUX="[^"]*\)/\1 audit=1/' /etc/default/grub
    fi
fi

echo "Verifying configuration:"
grubby --info ALL | grep -E "^args" | head -2

echo ""
echo "NOTE: A reboot is required for changes to take effect."

echo "CIS 5.2.1.2 remediation complete."