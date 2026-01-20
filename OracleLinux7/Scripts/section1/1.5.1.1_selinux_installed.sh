#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 - 1.5.1.1 Ensure SELinux is installed
# Compatible with OCI (Oracle Cloud Infrastructure)

set -e

echo "=== CIS 1.5.1.1 - Ensure SELinux is installed ==="

if rpm -q libselinux > /dev/null 2>&1; then
    echo " - SELinux (libselinux) is already installed"
else
    echo " - Installing libselinux..."
    yum install -y libselinux
    echo " - libselinux installed"
fi

echo " - SELinux installation check complete"
