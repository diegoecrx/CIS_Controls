#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.2.1.4
# Ensure auditd service is enabled

set -e

echo "CIS 5.2.1.4 - Enabling auditd service..."

systemctl --now enable auditd

echo "Verifying service status:"
systemctl is-enabled auditd

echo "CIS 5.2.1.4 remediation complete."