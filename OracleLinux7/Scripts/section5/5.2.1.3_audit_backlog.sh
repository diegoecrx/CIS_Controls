#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.1.3
# Ensure audit_backlog_limit is sufficient

set -e

echo "CIS 5.2.1.3 - Configuring audit backlog limit..."

# Update grub configuration
grubby --update-kernel ALL --args 'audit_backlog_limit=8192'

# Also update /etc/default/grub for persistence
if grep -q "^GRUB_CMDLINE_LINUX=" /etc/default/grub; then
    if ! grep -q "audit_backlog_limit=" /etc/default/grub; then
        sed -i 's/\(GRUB_CMDLINE_LINUX="[^"]*\)/\1 audit_backlog_limit=8192/' /etc/default/grub
    fi
fi

echo "Verifying configuration:"
grubby --info ALL | grep -E "^args" | head -2

echo ""
echo "NOTE: A reboot is required for changes to take effect."

echo "CIS 5.2.1.3 remediation complete."