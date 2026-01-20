#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.4.2.2.1
# Ensure pam_pwquality module is enabled
# WARNING: PAM configuration - PRINT ONLY

set -e

echo "CIS 4.4.2.2.1 - Checking pam_pwquality configuration..."
echo "=============================================="
echo "WARNING: THIS SCRIPT DOES NOT APPLY CHANGES"
echo "=============================================="
echo ""

echo "Current pam_pwquality configuration in system-auth:"
grep -i "pam_pwquality" /etc/pam.d/system-auth 2>/dev/null || echo "pam_pwquality not configured"

echo ""
echo "Current pam_pwquality configuration in password-auth:"
grep -i "pam_pwquality" /etc/pam.d/password-auth 2>/dev/null || echo "pam_pwquality not configured"

echo ""
echo "To configure pam_pwquality, add this line to password section:"
echo "  password requisite pam_pwquality.so try_first_pass local_users_only retry=3"

echo "CIS 4.4.2.2.1 check complete - manual configuration required."