#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.1.2.1.4
# Ensure journald is not configured to receive logs from a remote client

set -e

echo "CIS 5.1.2.1.4 - Disabling journald remote reception..."

systemctl --now mask systemd-journal-remote.socket

echo "Verifying service status:"
systemctl is-enabled systemd-journal-remote.socket 2>/dev/null || echo "masked"

echo "CIS 5.1.2.1.4 remediation complete."