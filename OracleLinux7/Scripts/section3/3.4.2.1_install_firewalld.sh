#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.2.1
# Ensure firewalld is installed
# This script installs firewalld

set -e

echo "CIS 3.4.2.1 - Installing firewalld..."

# Check if firewalld is installed
if rpm -q firewalld &>/dev/null; then
    echo "firewalld is already installed."
else
    echo "Installing firewalld..."
    yum install -y firewalld
    echo "firewalld installed successfully."
fi

# Check if iptables is installed
if rpm -q iptables &>/dev/null; then
    echo "iptables is already installed."
else
    echo "Installing iptables..."
    yum install -y iptables
    echo "iptables installed successfully."
fi

echo "CIS 3.4.2.1 remediation complete - firewalld and iptables installed."