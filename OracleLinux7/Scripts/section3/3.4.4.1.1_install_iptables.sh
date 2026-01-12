#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.4.1.1
# Ensure iptables packages are installed
# This script installs iptables packages

set -e

echo "CIS 3.4.4.1.1 - Installing iptables packages..."

if rpm -q iptables &>/dev/null; then
    echo "iptables is already installed."
else
    echo "Installing iptables..."
    yum install -y iptables
fi

if rpm -q iptables-services &>/dev/null; then
    echo "iptables-services is already installed."
else
    echo "Installing iptables-services..."
    yum install -y iptables-services
fi

echo "CIS 3.4.4.1.1 remediation complete - iptables packages installed."