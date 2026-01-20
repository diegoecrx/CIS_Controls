#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 4.4.1.2
# Ensure libpwquality is installed
# This script installs libpwquality

set -e

echo "CIS 4.4.1.2 - Installing libpwquality..."

yum install -y libpwquality

echo "Verifying installation:"
rpm -q libpwquality

echo "CIS 4.4.1.2 remediation complete."