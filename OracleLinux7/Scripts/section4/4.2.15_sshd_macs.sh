#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.2.15
# Ensure sshd MACs are configured
# This script configures strong MACs

set -e

echo "CIS 4.2.15 - Configuring sshd MACs..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

MACS="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"

# Configure MACs
if grep -Eq '^\s*MACs\s+' /etc/ssh/sshd_config; then
    sed -i "s|^\s*MACs\s.*|MACs $MACS|" /etc/ssh/sshd_config
else
    echo "MACs $MACS" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^MACs" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.15 remediation complete."