#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.1.3
# Ensure journald is configured to send logs to rsyslog

set -e

echo "CIS 5.1.1.3 - Configuring journald to forward to rsyslog..."

# Backup
cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Configure ForwardToSyslog
if grep -q "^ForwardToSyslog" /etc/systemd/journald.conf; then
    sed -i 's/^ForwardToSyslog.*/ForwardToSyslog=yes/' /etc/systemd/journald.conf
elif grep -q "^#ForwardToSyslog" /etc/systemd/journald.conf; then
    sed -i 's/^#ForwardToSyslog.*/ForwardToSyslog=yes/' /etc/systemd/journald.conf
else
    echo "ForwardToSyslog=yes" >> /etc/systemd/journald.conf
fi

# Reload journald
systemctl reload-or-try-restart systemd-journald.service

echo "Verifying configuration:"
grep -E "^ForwardToSyslog" /etc/systemd/journald.conf

echo "CIS 5.1.1.3 remediation complete."