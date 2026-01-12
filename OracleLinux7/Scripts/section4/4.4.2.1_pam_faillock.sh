#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.1.1 through 4.4.2.1.4
# Ensure pam_faillock module is enabled with proper settings
# WARNING: PAM configuration - PRINT ONLY to avoid lockout

set -e

echo "CIS 4.4.2.1.x - Checking pam_faillock configuration..."
echo "=============================================="
echo "WARNING: THIS SCRIPT DOES NOT APPLY CHANGES"
echo "Incorrect PAM configuration can lock you out!"
echo "=============================================="
echo ""

echo "Current pam_faillock configuration in system-auth:"
grep -i "pam_faillock" /etc/pam.d/system-auth 2>/dev/null || echo "pam_faillock not configured"

echo ""
echo "Current pam_faillock configuration in password-auth:"
grep -i "pam_faillock" /etc/pam.d/password-auth 2>/dev/null || echo "pam_faillock not configured"

echo ""
echo "To configure pam_faillock, add these lines to /etc/pam.d/system-auth and /etc/pam.d/password-auth:"
echo ""
echo "In auth section (after pam_env.so, before password validation):"
echo "  auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900 even_deny_root"
echo "  auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900 even_deny_root"
echo ""
echo "In account section:"
echo "  account required pam_faillock.so"
echo ""
echo "WARNING: Test in a non-production environment first!"

echo "CIS 4.4.2.1.x check complete - manual configuration required."