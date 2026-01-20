#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.2.1.3
# Ensure systemd-journal-remote is enabled

set -e

echo "CIS 5.1.2.1.3 - Enabling systemd-journal-upload..."

systemctl --now enable systemd-journal-upload.service

echo "Verifying service status:"
systemctl is-enabled systemd-journal-upload.service

echo "CIS 5.1.2.1.3 remediation complete."