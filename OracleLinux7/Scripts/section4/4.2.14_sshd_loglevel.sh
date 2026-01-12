#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.14
# Ensure sshd LogLevel is configured
# This script configures LogLevel

set -e

echo "CIS 4.2.14 - Configuring sshd LogLevel..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure LogLevel
if grep -Eq '^\s*LogLevel\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*LogLevel\s.*|LogLevel VERBOSE|' /etc/ssh/sshd_config
else
    echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^LogLevel" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.14 remediation complete."