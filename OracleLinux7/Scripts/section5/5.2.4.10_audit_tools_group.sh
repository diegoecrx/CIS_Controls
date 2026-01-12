#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.4.10
# Ensure audit tools belong to group root

set -e

echo "CIS 5.2.4.10 - Configuring audit tools group ownership..."

chgrp root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules

echo "Verifying group ownership:"
stat -c "%n %G" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules

echo "CIS 5.2.4.10 remediation complete."