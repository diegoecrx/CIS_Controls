#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.2.2
# Ensure permissions on SSH private host key files are configured
# This script sets proper permissions on private SSH keys

set -e

echo "CIS 4.2.2 - Setting permissions on SSH private host key files..."

# Find SSH key group if exists
l_skgn="$(grep -Po -- '^(ssh_keys|_?ssh)\b' /etc/group 2>/dev/null || true)"

if [ -n "$l_skgn" ]; then
    l_sgroup="$l_skgn"
    l_mfix="u-x,g-wx,o-rwx"
else
    l_sgroup="root"
    l_mfix="u-x,go-rwx"
fi

# Find and fix private key permissions
if [ -d /etc/ssh ]; then
    for keyfile in /etc/ssh/ssh_host_*_key; do
        if [ -f "$keyfile" ]; then
            echo "Fixing permissions on $keyfile"
            chmod $l_mfix "$keyfile"
            chown root:"$l_sgroup" "$keyfile"
        fi
    done
fi

echo "Verifying permissions:"
ls -l /etc/ssh/ssh_host_*_key 2>/dev/null || echo "No private keys found"

echo "CIS 4.2.2 remediation complete."