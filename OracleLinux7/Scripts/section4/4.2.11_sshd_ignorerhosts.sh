#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.11
# Ensure sshd IgnoreRhosts is enabled
# This script enables IgnoreRhosts

set -e

echo "CIS 4.2.11 - Configuring sshd IgnoreRhosts..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# Configure IgnoreRhosts
if grep -Eq '^\s*IgnoreRhosts\s+' /etc/ssh/sshd_config; then
    sed -i 's|^\s*IgnoreRhosts\s.*|IgnoreRhosts yes|' /etc/ssh/sshd_config
else
    echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^IgnoreRhosts" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.11 remediation complete."