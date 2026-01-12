#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.22
# Ensure sshd UsePAM is enabled
# This script enables PAM for SSH

set -e

echo "CIS 4.2.22 - Configuring sshd UsePAM..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure UsePAM
if grep -Eq '^\s*UsePAM\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*UsePAM\s.*|UsePAM yes|' /etc/ssh/sshd_config
else
    echo "UsePAM yes" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^UsePAM" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.22 remediation complete."