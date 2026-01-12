#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 2.3.2
# Ensure ldap client is not installed
# This script removes openldap-clients package

set -e

echo "CIS 2.3.2 - Removing LDAP client..."

# Check if openldap-clients is installed
if rpm -q openldap-clients &>/dev/null; then
    echo "Removing openldap-clients package..."
    yum remove -y openldap-clients
    echo "openldap-clients package removed successfully."
else
    echo "openldap-clients package is not installed."
fi

echo "CIS 2.3.2 remediation complete - LDAP client removed."