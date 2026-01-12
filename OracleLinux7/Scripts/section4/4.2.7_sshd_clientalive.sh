#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.7
# Ensure sshd ClientAliveInterval and ClientAliveCountMax are configured
# This script configures SSH client alive settings

set -e

echo "CIS 4.2.7 - Configuring sshd ClientAlive settings..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure ClientAliveInterval
if grep -Eq '^\s*ClientAliveInterval\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*ClientAliveInterval\s.*|ClientAliveInterval 15|' /etc/ssh/sshd_config
else
    echo "ClientAliveInterval 15" >> /etc/ssh/sshd_config
fi

# Configure ClientAliveCountMax
if grep -Eq '^\s*ClientAliveCountMax\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*ClientAliveCountMax\s.*|ClientAliveCountMax 3|' /etc/ssh/sshd_config
else
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -Ei "^ClientAlive" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.7 remediation complete."