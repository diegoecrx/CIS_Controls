#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.19
# Ensure sshd PermitEmptyPasswords is disabled
# This script disables empty passwords for SSH

set -e

echo "CIS 4.2.19 - Configuring sshd PermitEmptyPasswords..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure PermitEmptyPasswords
if grep -Eq '^\s*PermitEmptyPasswords\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*PermitEmptyPasswords\s.*|PermitEmptyPasswords no|' /etc/ssh/sshd_config
else
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^PermitEmptyPasswords" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.19 remediation complete."