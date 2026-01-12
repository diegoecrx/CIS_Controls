#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.1.1
# Ensure rsyslog is installed

set -e

echo "CIS 5.1.1.1 - Installing rsyslog..."

yum install -y rsyslog

echo "Verifying installation:"
rpm -q rsyslog

echo "CIS 5.1.1.1 remediation complete."