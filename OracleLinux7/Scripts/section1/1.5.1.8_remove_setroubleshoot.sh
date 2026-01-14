#!/bin/bash
# CIS Oracle Linux 7 - 1.5.1.8 Ensure SETroubleshoot is not installed
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.8 - Remove setroubleshoot ==="

if rpm -q setroubleshoot > /dev/null 2>&1; then
    yum remove -y setroubleshoot
    echo " - setroubleshoot removed"
else
    echo " - setroubleshoot is not installed"
fi

echo " - setroubleshoot check complete"
