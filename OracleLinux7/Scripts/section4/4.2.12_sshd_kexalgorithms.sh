#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.12
# Ensure sshd KexAlgorithms is configured
# This script configures strong key exchange algorithms

set -e

echo "CIS 4.2.12 - Configuring sshd KexAlgorithms..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

KEXALGS="curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256"

# Configure KexAlgorithms
if grep -Eq '^\s*KexAlgorithms\s+' /etc/ssh/sshd_config; then
    sed -i "s|^\s*KexAlgorithms\s.*|KexAlgorithms $KEXALGS|" /etc/ssh/sshd_config
else
    echo "KexAlgorithms $KEXALGS" >> /etc/ssh/sshd_config
fi

echo "Verifying configuration:"
grep -i "^KexAlgorithms" /etc/ssh/sshd_config

echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo "CIS 4.2.12 remediation complete."