#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.4.1 through 4.4.2.4.4
# Ensure pam_unix is properly configured
# WARNING: PAM configuration - PRINT ONLY to avoid lockout

set -e

echo "CIS 4.4.2.4.x - Checking pam_unix configuration..."
echo "=============================================="
echo "WARNING: THIS SCRIPT DOES NOT APPLY CHANGES"
echo "Incorrect PAM configuration can lock you out!"
echo "=============================================="
echo ""

echo "Current pam_unix configuration in system-auth:"
grep -i "pam_unix" /etc/pam.d/system-auth 2>/dev/null

echo ""
echo "Current pam_unix configuration in password-auth:"
grep -i "pam_unix" /etc/pam.d/password-auth 2>/dev/null

echo ""
echo "Required pam_unix configuration:"
echo "  - Remove 'nullok' option (4.4.2.4.1)"
echo "  - Remove 'remember=' option from pam_unix (use pam_pwhistory instead) (4.4.2.4.2)"
echo "  - Add 'sha512' for strong hashing (4.4.2.4.3)"
echo "  - Add 'use_authtok' option (4.4.2.4.4)"
echo ""
echo "Example password line:"
echo "  password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok"

echo "CIS 4.4.2.4.x check complete - manual configuration required."