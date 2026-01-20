#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.2.4.9
# Ensure audit tools are owned by root

set -e

echo "CIS 5.2.4.9 - Configuring audit tools ownership..."

chown root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules

echo "Verifying ownership:"
stat -c "%n %U" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules

echo "CIS 5.2.4.9 remediation complete."