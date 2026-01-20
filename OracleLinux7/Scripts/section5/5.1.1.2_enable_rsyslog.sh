#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.1.2
# Ensure rsyslog service is enabled

set -e

echo "CIS 5.1.1.2 - Enabling rsyslog service..."

systemctl --now enable rsyslog

echo "Verifying service status:"
systemctl is-enabled rsyslog

echo "CIS 5.1.1.2 remediation complete."