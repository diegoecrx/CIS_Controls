#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.1.2.1
# Ensure at is restricted to authorized users
# This script configures at.allow and at.deny

set -e

echo "CIS 4.1.2.1 - Restricting at to authorized users..."

# Check if at is installed
if ! rpm -q at &>/dev/null; then
    echo "at is not installed. Skipping."
    exit 0
fi

# Determine group (daemon or root)
if grep -Pq -- '^daemon\b' /etc/group; then
    l_group="daemon"
else
    l_group="root"
fi

# Create /etc/at.allow if it doesn't exist
[ ! -e "/etc/at.allow" ] && touch /etc/at.allow

# Set ownership and permissions on at.allow
chown root:"$l_group" /etc/at.allow
chmod u-x,g-wx,o-rwx /etc/at.allow

# If at.deny exists, set proper permissions
if [ -e "/etc/at.deny" ]; then
    chown root:"$l_group" /etc/at.deny
    chmod u-x,g-wx,o-rwx /etc/at.deny
fi

echo "Verifying permissions:"
ls -l /etc/at.allow
[ -e "/etc/at.deny" ] && ls -l /etc/at.deny

echo "CIS 4.1.2.1 remediation complete."