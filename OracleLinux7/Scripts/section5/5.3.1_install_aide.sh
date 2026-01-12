#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.3.1
# Ensure AIDE is installed

set -e

echo "CIS 5.3.1 - Installing and initializing AIDE..."

# Install AIDE
yum install -y aide

echo "Initializing AIDE database (this may take several minutes)..."
aide --init

# Move the new database to the active location
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

echo "Verifying installation:"
rpm -q aide
ls -la /var/lib/aide/aide.db.gz

echo ""
echo "NOTE: Review /etc/aide.conf for site-specific configuration."

echo "CIS 5.3.1 remediation complete."