#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.3
# Ensure logrotate is configured
# This script provides PRINT ONLY (site specific)

echo "CIS 5.1.3 - Checking logrotate configuration..."
echo "==========================================="
echo ""
echo "Current logrotate.conf settings:"
cat /etc/logrotate.conf | head -30
echo ""
echo "Logrotate.d configurations:"
ls -la /etc/logrotate.d/
echo ""
echo "Review and edit /etc/logrotate.conf and /etc/logrotate.d/*"
echo "to ensure logs are rotated according to site policy."
echo ""
echo "CIS 5.1.3 - Manual review required."