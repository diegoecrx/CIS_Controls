#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.2.4
# Ensure sshd access is configured
# This script configures SSH access control

set -e

echo "CIS 4.2.4 - Configuring sshd access..."

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d%H%M%S)

# For OCI, allow opc user and root (if needed for recovery)
# Adjust this list based on your environment
ALLOWED_USERS="opc root"

# Check if AllowUsers is already set
if grep -Eq '^\s*AllowUsers\s+' /etc/ssh/sshd_config; then
    echo "AllowUsers is already configured:"
    grep -i "^AllowUsers" /etc/ssh/sshd_config
else
    # Add AllowUsers directive
    echo "AllowUsers $ALLOWED_USERS" >> /etc/ssh/sshd_config
    echo " - Added AllowUsers: $ALLOWED_USERS"
fi

echo ""
echo "Verifying configuration:"
grep -Ei "^(Allow|Deny)(Users|Groups)" /etc/ssh/sshd_config || echo "No access directives found"

echo ""
echo "Reloading sshd..."
systemctl reload-or-try-restart sshd.service

echo ""
echo "CIS 4.2.4 remediation complete."
echo "NOTE: Ensure your user is in the AllowUsers list before disconnecting!"
