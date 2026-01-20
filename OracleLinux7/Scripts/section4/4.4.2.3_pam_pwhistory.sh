#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.4.2.3.1 through 4.4.2.3.4
# Ensure pam_pwhistory module is enabled with proper settings
# This script configures pam_pwhistory

set -e

echo "CIS 4.4.2.3.x - Configuring pam_pwhistory..."

# Backup PAM files
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.backup.$(date +%Y%m%d%H%M%S)
cp /etc/pam.d/password-auth /etc/pam.d/password-auth.backup.$(date +%Y%m%d%H%M%S)

# Function to configure pwhistory in a PAM file
configure_pwhistory() {
    local pam_file="$1"
    
    # Check if pwhistory is already properly configured
    if grep -q "pam_pwhistory.so.*remember=24.*enforce_for_root.*use_authtok" "$pam_file"; then
        echo " - $pam_file already has pam_pwhistory properly configured"
        return
    fi
    
    # Update existing pwhistory line or add new one
    if grep -q "pam_pwhistory.so" "$pam_file"; then
        # Update existing line
        sed -i 's/^password.*pam_pwhistory.so.*/password    requisite                                    pam_pwhistory.so remember=24 enforce_for_root try_first_pass use_authtok/' "$pam_file"
        echo " - Updated pam_pwhistory in $pam_file"
    else
        # Add after pam_pwquality.so
        sed -i '/pam_pwquality.so/a password    requisite                                    pam_pwhistory.so remember=24 enforce_for_root try_first_pass use_authtok' "$pam_file"
        echo " - Added pam_pwhistory to $pam_file"
    fi
}

configure_pwhistory /etc/pam.d/system-auth
configure_pwhistory /etc/pam.d/password-auth

echo ""
echo "Verification - system-auth:"
grep "pam_pwhistory" /etc/pam.d/system-auth || echo "Not found"

echo ""
echo "Verification - password-auth:"
grep "pam_pwhistory" /etc/pam.d/password-auth || echo "Not found"

echo ""
echo "CIS 4.4.2.3.x remediation complete."
