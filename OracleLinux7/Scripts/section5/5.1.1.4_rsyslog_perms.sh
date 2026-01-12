#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.1.4
# Ensure rsyslog default file permissions are configured

set -e

echo "CIS 5.1.1.4 - Configuring rsyslog file permissions..."

# Backup
cp /etc/rsyslog.conf /etc/rsyslog.conf.bak.$(date +%Y%m%d)

# Configure FileCreateMode
if grep -q '^\$FileCreateMode' /etc/rsyslog.conf; then
    sed -i 's/^\$FileCreateMode.*/\$FileCreateMode 0640/' /etc/rsyslog.conf
else
    echo '$FileCreateMode 0640' >> /etc/rsyslog.conf
fi

# Restart rsyslog
systemctl restart rsyslog

echo "Verifying configuration:"
grep -E '^\$FileCreateMode' /etc/rsyslog.conf

echo "CIS 5.1.1.4 remediation complete."