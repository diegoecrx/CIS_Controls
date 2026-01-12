#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.2.3
# Ensure journald is configured to compress large log files

set -e

echo "CIS 5.1.2.3 - Configuring journald compression..."

# Backup
cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Configure Compress
if grep -q "^Compress" /etc/systemd/journald.conf; then
    sed -i 's/^Compress.*/Compress=yes/' /etc/systemd/journald.conf
elif grep -q "^#Compress" /etc/systemd/journald.conf; then
    sed -i 's/^#Compress.*/Compress=yes/' /etc/systemd/journald.conf
else
    echo "Compress=yes" >> /etc/systemd/journald.conf
fi

# Restart journald
systemctl restart systemd-journald.service

echo "Verifying configuration:"
grep -E "^Compress" /etc/systemd/journald.conf

echo "CIS 5.1.2.3 remediation complete."