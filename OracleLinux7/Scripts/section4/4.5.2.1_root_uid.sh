#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.2.1
# Ensure root is the only UID 0 account
# This script provides audit check - PRINT ONLY (affects root)

echo "CIS 4.5.2.1 - Checking UID 0 accounts..."
echo "==========================================="
echo ""
echo "[AUDIT] This control requires manual verification."
echo ""
echo "Checking for accounts with UID 0:"
awk -F: '($3 == 0) { print $1 }' /etc/passwd
echo ""
echo "Only 'root' should be listed above."
echo ""
echo "If other accounts have UID 0, they should be removed or"
echo "assigned a different UID."
echo ""
echo "CIS 4.5.2.1 - Manual review required."