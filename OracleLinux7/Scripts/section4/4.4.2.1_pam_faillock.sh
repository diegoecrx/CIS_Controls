#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.4.2.1.1 through 4.4.2.1.4
# Ensure pam_faillock module is enabled with proper settings
# This script configures pam_faillock with even_deny_root

set -e

echo "CIS 4.4.2.1.x - Configuring pam_faillock..."

# Backup PAM files
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.backup.$(date +%Y%m%d%H%M%S)
cp /etc/pam.d/password-auth /etc/pam.d/password-auth.backup.$(date +%Y%m%d%H%M%S)

# Function to configure faillock in a PAM file
configure_faillock() {
    local pam_file="$1"
    local temp_file=$(mktemp)
    
    # Check if faillock is already configured with even_deny_root
    if grep -q "pam_faillock.so.*even_deny_root" "$pam_file"; then
        echo " - $pam_file already has pam_faillock with even_deny_root"
        return
    fi
    
    # Remove existing faillock lines to avoid duplicates
    grep -v "pam_faillock.so" "$pam_file" > "$temp_file" || true
    
    # Process and add faillock lines in correct positions
    awk '
    /^auth.*pam_env\.so/ {
        print
        print "auth        required                                     pam_faillock.so preauth silent audit deny=5 unlock_time=900 even_deny_root"
        next
    }
    /^auth.*pam_deny\.so/ {
        print "auth        [default=die]                                pam_faillock.so authfail audit deny=5 unlock_time=900 even_deny_root"
        print
        next
    }
    /^account.*pam_unix\.so/ {
        print "account     required                                     pam_faillock.so"
        print
        next
    }
    { print }
    ' "$temp_file" > "${pam_file}.new"
    
    mv "${pam_file}.new" "$pam_file"
    rm -f "$temp_file"
    
    echo " - Configured pam_faillock in $pam_file"
}

configure_faillock /etc/pam.d/system-auth
configure_faillock /etc/pam.d/password-auth

echo ""
echo "Verification - system-auth:"
grep -E "(pam_faillock|pam_env)" /etc/pam.d/system-auth | head -5

echo ""
echo "Verification - password-auth:"
grep -E "(pam_faillock|pam_env)" /etc/pam.d/password-auth | head -5

echo ""
echo "CIS 4.4.2.1.x remediation complete."
echo "WARNING: Test login in a separate terminal before closing this session!"
