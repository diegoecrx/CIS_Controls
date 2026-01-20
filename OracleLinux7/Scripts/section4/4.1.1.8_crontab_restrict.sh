#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.1.1.8
# Ensure crontab is restricted to authorized users
# This script configures cron.allow and cron.deny

set -e

echo "CIS 4.1.1.8 - Restricting crontab to authorized users..."

# Create /etc/cron.allow if it doesn't exist
[ ! -e "/etc/cron.allow" ] && touch /etc/cron.allow

# Set ownership and permissions on cron.allow
chown root:root /etc/cron.allow
chmod u-x,g-wx,o-rwx /etc/cron.allow

# If cron.deny exists, set proper permissions
if [ -e "/etc/cron.deny" ]; then
    chown root:root /etc/cron.deny
    chmod u-x,g-wx,o-rwx /etc/cron.deny
fi

echo "Verifying permissions:"
ls -l /etc/cron.allow
[ -e "/etc/cron.deny" ] && ls -l /etc/cron.deny

echo "CIS 4.1.1.8 remediation complete."