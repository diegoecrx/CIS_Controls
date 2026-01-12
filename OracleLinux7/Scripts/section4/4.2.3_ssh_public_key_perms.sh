#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.3
# Ensure permissions on SSH public host key files are configured
# This script sets proper permissions on public SSH keys

set -e

echo "CIS 4.2.3 - Setting permissions on SSH public host key files..."

# Find and fix public key permissions
if [ -d /etc/ssh ]; then
    for keyfile in /etc/ssh/ssh_host_*_key.pub; do
        if [ -f "$keyfile" ]; then
            echo "Fixing permissions on $keyfile"
            chmod u-x,go-wx "$keyfile"
            chown root:root "$keyfile"
        fi
    done
fi

echo "Verifying permissions:"
ls -l /etc/ssh/ssh_host_*_key.pub 2>/dev/null || echo "No public keys found"

echo "CIS 4.2.3 remediation complete."