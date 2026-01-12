#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.1.1
# Ensure audit is installed

set -e

echo "CIS 5.2.1.1 - Installing audit..."

yum install -y audit audit-libs

echo "Verifying installation:"
rpm -q audit audit-libs

echo "CIS 5.2.1.1 remediation complete."