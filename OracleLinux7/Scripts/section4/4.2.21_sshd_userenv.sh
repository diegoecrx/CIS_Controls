#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.21
# Ensure sshd PermitUserEnvironment is disabled
# This script disables user environment

set -e

echo "CIS 4.2.21 - Configuring sshd PermitUserEnvironment..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure PermitUserEnvironment
if grep -Eq '^\s*PermitUserEnvironment\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*PermitUserEnvironment\s.*|PermitUserEnvironment no|' /etc/ssh/sshd_config
else
    echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^PermitUserEnvironment" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.21 remediation complete."