#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.5.3.1
# Ensure nologin is not listed in /etc/shells
# This script removes nologin from /etc/shells

set -e

echo "CIS 4.5.3.1 - Removing nologin from /etc/shells..."

# Backup
cp /etc/shells /etc/shells.bak.$(date +%Y%m%d)

# Remove nologin entries
sed -i '/\/nologin/d' /etc/shells

echo "Verifying /etc/shells:"
cat /etc/shells

echo ""
echo "CIS 4.5.3.1 remediation complete."