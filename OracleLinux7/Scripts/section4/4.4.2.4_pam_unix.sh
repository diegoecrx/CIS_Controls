#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.4.2.4.1 through 4.4.2.4.4
# Ensure pam_unix is properly configured
# Removes nullok, removes remember, adds sha512 and use_authtok

set -e

echo "CIS 4.4.2.4.x - Configuring pam_unix..."

# Backup PAM files
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.backup.$(date +%Y%m%d%H%M%S)
cp /etc/pam.d/password-auth /etc/pam.d/password-auth.backup.$(date +%Y%m%d%H%M%S)

# Function to configure pam_unix in a PAM file
configure_pam_unix() {
    local pam_file="$1"
    
    # Remove nullok from pam_unix lines (4.4.2.4.1)
    if grep -q "pam_unix.so.*nullok" "$pam_file"; then
        sed -i 's/\s*nullok\s*/ /g' "$pam_file"
        echo " - Removed nullok from $pam_file"
    fi
    
    # Remove remember= from pam_unix password lines (4.4.2.4.2)
    if grep -q "^password.*pam_unix.so.*remember=" "$pam_file"; then
        sed -i 's/\s*remember=[0-9]*\s*/ /g' "$pam_file"
        echo " - Removed remember= from pam_unix in $pam_file"
    fi
    
    # Ensure sha512 is present on password pam_unix line (4.4.2.4.3)
    if grep -q "^password.*pam_unix.so" "$pam_file"; then
        if ! grep -q "^password.*pam_unix.so.*sha512" "$pam_file"; then
            sed -i '/^password.*pam_unix.so/s/pam_unix.so/pam_unix.so sha512/' "$pam_file"
            echo " - Added sha512 to pam_unix in $pam_file"
        fi
    fi
    
    # Ensure use_authtok is present on password pam_unix line (4.4.2.4.4)
    if grep -q "^password.*pam_unix.so" "$pam_file"; then
        if ! grep -q "^password.*pam_unix.so.*use_authtok" "$pam_file"; then
            sed -i '/^password.*pam_unix.so/s/$/ use_authtok/' "$pam_file"
            echo " - Added use_authtok to pam_unix in $pam_file"
        fi
    fi
    
    # Clean up multiple spaces
    sed -i 's/  */ /g' "$pam_file"
}

configure_pam_unix /etc/pam.d/system-auth
configure_pam_unix /etc/pam.d/password-auth

echo ""
echo "Verification - system-auth:"
grep "pam_unix" /etc/pam.d/system-auth

echo ""
echo "Verification - password-auth:"
grep "pam_unix" /etc/pam.d/password-auth

echo ""
echo "CIS 4.4.2.4.x remediation complete."
