#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.8
# Ensure sshd DisableForwarding is enabled
# This script disables SSH forwarding

set -e

echo "CIS 4.2.8 - Configuring sshd DisableForwarding..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure DisableForwarding
if grep -Eq '^\s*DisableForwarding\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*DisableForwarding\s.*|DisableForwarding yes|' /etc/ssh/sshd_config
else
    echo "DisableForwarding yes" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^DisableForwarding" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.8 remediation complete."