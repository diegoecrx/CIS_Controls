#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.16
# Ensure sshd MaxAuthTries is configured
# This script configures MaxAuthTries

set -e

echo "CIS 4.2.16 - Configuring sshd MaxAuthTries..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure MaxAuthTries
if grep -Eq '^\s*MaxAuthTries\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*MaxAuthTries\s.*|MaxAuthTries 4|' /etc/ssh/sshd_config
else
    echo "MaxAuthTries 4" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^MaxAuthTries" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.16 remediation complete."