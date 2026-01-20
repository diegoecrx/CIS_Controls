#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 6.1.14
# Audit system file permissions
# NOTE: This script audits - manual review required

echo "CIS 6.1.14 - Auditing system file permissions..."
echo "=============================================================="
echo "NOTE: This script audits package file permissions."
echo "Review and correct any discrepancies found."
echo ""

echo "Checking RPM package file permissions..."
rpm -Va --nomtime --nosize --nomd5 --nolinkto --noconfig --noghost | /bin/awk '{ print } END { if (NR==0) print "none" }'

echo ""
echo "=============================================================="
echo "If output shows discrepancies, investigate and correct them."
echo "Use 'rpm -V <package>' to check specific packages."
echo "CIS 6.1.14 audit complete."