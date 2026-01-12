#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.5
# Ensure sshd Banner is configured
# This script configures SSH banner

set -e

echo "CIS 4.2.5 - Configuring sshd Banner..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Check if Banner is already set
if grep -Eq '^\s*Banner\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*Banner\s.*|Banner /etc/issue.net|' /etc/ssh/sshd_config
else
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^Banner" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.5 remediation complete."