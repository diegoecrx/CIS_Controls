#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.18
# Ensure sshd MaxStartups is configured
# This script configures MaxStartups

set -e

echo "CIS 4.2.18 - Configuring sshd MaxStartups..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure MaxStartups
if grep -Eq '^\s*MaxStartups\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*MaxStartups\s.*|MaxStartups 10:30:60|' /etc/ssh/sshd_config
else
    echo "MaxStartups 10:30:60" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^MaxStartups" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.18 remediation complete."