#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.3.1 through 4.4.2.3.4
# Ensure pam_pwhistory module is enabled with proper settings
# WARNING: PAM configuration - PRINT ONLY to avoid lockout

set -e

echo "CIS 4.4.2.3.x - Checking pam_pwhistory configuration..."
echo "=============================================="
echo "WARNING: THIS SCRIPT DOES NOT APPLY CHANGES"
echo "Incorrect PAM configuration can lock you out!"
echo "=============================================="
echo ""

echo "Current pam_pwhistory configuration in system-auth:"
grep -i "pam_pwhistory" /etc/pam.d/system-auth 2>/dev/null || echo "pam_pwhistory not configured"

echo ""
echo "Current pam_pwhistory configuration in password-auth:"
grep -i "pam_pwhistory" /etc/pam.d/password-auth 2>/dev/null || echo "pam_pwhistory not configured"

echo ""
echo "To configure pam_pwhistory, add this line to password section:"
echo "  password required pam_pwhistory.so remember=24 enforce_for_root try_first_pass use_authtok"
echo ""
echo "Place it after pam_pwquality.so and before pam_unix.so"

echo "CIS 4.4.2.3.x check complete - manual configuration required."