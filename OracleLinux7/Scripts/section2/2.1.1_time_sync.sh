#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.1.1
# Ensure time synchronization is in use
# This script installs chrony for time synchronization

set -e

echo "CIS 2.1.1 - Installing chrony for time synchronization..."

# Check if chrony is installed
if rpm -q chrony &>/dev/null; then
    echo "chrony is already installed."
else
    echo "Installing chrony..."
    yum install -y chrony
    echo "chrony installed successfully."
fi

# Enable and start chronyd
systemctl enable chronyd
systemctl start chronyd

echo "CIS 2.1.1 remediation complete - chrony is installed and running."