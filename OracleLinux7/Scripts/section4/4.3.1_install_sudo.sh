#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.3.1
# Ensure sudo is installed
# This script installs sudo

set -e

echo "CIS 4.3.1 - Installing sudo..."

yum install -y sudo

echo "Verifying installation:"
rpm -q sudo

echo "CIS 4.3.1 remediation complete."