#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.1.7
# Ensure rsyslog is not configured to receive logs from a remote client

set -e

echo "CIS 5.1.1.7 - Disabling rsyslog remote reception..."

# Backup
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak.$(date +%Y%m%d) 2>/dev/null || true

# Remove/comment out imtcp module loading (new format)
sed -i 's/^module(load="imtcp")/#module(load="imtcp")/' /etc/rsyslog.conf
sed -i 's/^input(type="imtcp"/#input(type="imtcp"/' /etc/rsyslog.conf

# Remove/comment out imtcp module loading (old format)
sed -i 's/^\$ModLoad imtcp/#\$ModLoad imtcp/' /etc/rsyslog.conf
sed -i 's/^\$InputTCPServerRun/#\$InputTCPServerRun/' /etc/rsyslog.conf

# Also check rsyslog.d files
for f in /etc/rsyslog.d/*.conf; do
    if [ -f "$f" ]; then
        sed -i 's/^module(load="imtcp")/#module(load="imtcp")/' "$f"
        sed -i 's/^input(type="imtcp"/#input(type="imtcp"/' "$f"
        sed -i 's/^\$ModLoad imtcp/#\$ModLoad imtcp/' "$f"
        sed -i 's/^\$InputTCPServerRun/#\$InputTCPServerRun/' "$f"
    fi
done

# Restart rsyslog
systemctl restart rsyslog

echo "Verifying no remote reception configured:"
grep -E "imtcp|InputTCPServerRun" /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2>/dev/null || echo "No remote reception configured"

echo "CIS 5.1.1.7 remediation complete."