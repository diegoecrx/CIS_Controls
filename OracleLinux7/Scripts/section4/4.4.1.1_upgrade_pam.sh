#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.4.1.1
# Ensure latest version of pam is installed
# This script upgrades pam

set -e

echo "CIS 4.4.1.1 - Upgrading PAM to latest version..."

yum upgrade -y pam

echo "Verifying installation:"
rpm -q pam

echo "CIS 4.4.1.1 remediation complete."