#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.2.4
# Ensure journald is configured to write logfiles to persistent disk

set -e

echo "CIS 5.1.2.4 - Configuring journald persistent storage..."

# Backup
cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Configure Storage
if grep -q "^Storage" /etc/systemd/journald.conf; then
    sed -i 's/^Storage.*/Storage=persistent/' /etc/systemd/journald.conf
elif grep -q "^#Storage" /etc/systemd/journald.conf; then
    sed -i 's/^#Storage.*/Storage=persistent/' /etc/systemd/journald.conf
else
    echo "Storage=persistent" >> /etc/systemd/journald.conf
fi

# Create persistent journal directory
mkdir -p /var/log/journal

# Restart journald
systemctl restart systemd-journald.service

echo "Verifying configuration:"
grep -E "^Storage" /etc/systemd/journald.conf

echo "CIS 5.1.2.4 remediation complete."