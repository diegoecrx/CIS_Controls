#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 6.1.13
# Ensure SUID and SGID files are reviewed
# NOTE: This script identifies files - manual review required

echo "CIS 6.1.13 - Auditing SUID and SGID files..."
echo "=============================================================="
echo "NOTE: This script identifies SUID/SGID files for manual review."
echo "Verify each file is legitimate and required."
echo ""

echo "SUID files (Set User ID):"
find / -xdev -type f -perm -4000 2>/dev/null | while read -r file; do
    ls -l "$file"
done

echo ""
echo "SGID files (Set Group ID):"
find / -xdev -type f -perm -2000 2>/dev/null | while read -r file; do
    ls -l "$file"
done

echo ""
echo "=============================================================="
echo "Review each file above. Remove SUID/SGID if not required:"
echo "  chmod u-s <file>  # Remove SUID"
echo "  chmod g-s <file>  # Remove SGID"
echo "CIS 6.1.13 audit complete."