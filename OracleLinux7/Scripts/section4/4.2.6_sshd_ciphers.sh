#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.6
# Ensure sshd Ciphers are configured
# This script configures strong SSH ciphers

set -e

echo "CIS 4.2.6 - Configuring sshd Ciphers..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

CIPHERS="chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"

# Check if Ciphers is already set
if grep -Eq '^\s*Ciphers\s+' /etc/ssh/sshd_config; then
    sed -i "s|^\s*Ciphers\s.*|Ciphers $CIPHERS|" /etc/ssh/sshd_config
else
    echo "Ciphers $CIPHERS" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^Ciphers" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.6 remediation complete."