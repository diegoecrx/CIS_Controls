#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.9
# Ensure sshd GSSAPIAuthentication is disabled
# This script disables GSSAPI authentication

set -e

echo "CIS 4.2.9 - Configuring sshd GSSAPIAuthentication..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure GSSAPIAuthentication
if grep -Eq '^\s*GSSAPIAuthentication\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*GSSAPIAuthentication\s.*|GSSAPIAuthentication no|' /etc/ssh/sshd_config
else
    echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^GSSAPIAuthentication" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.9 remediation complete."