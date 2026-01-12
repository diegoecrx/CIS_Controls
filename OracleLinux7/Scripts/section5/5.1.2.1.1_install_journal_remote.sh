#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.2.1.1
# Ensure systemd-journal-remote is installed

set -e

echo "CIS 5.1.2.1.1 - Installing systemd-journal-remote..."

yum install -y systemd-journal-gateway

echo "Verifying installation:"
rpm -q systemd-journal-gateway

echo "CIS 5.1.2.1.1 remediation complete."