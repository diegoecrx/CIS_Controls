#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.4.8
# Ensure audit tools are 755 or more restrictive

set -e

echo "CIS 5.2.4.8 - Configuring audit tools permissions..."

chmod go-w /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules

echo "Verifying permissions:"
stat -c "%n %a" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules

echo "CIS 5.2.4.8 remediation complete."