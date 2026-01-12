#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 4.5.2.2
# Ensure root default group is GID 0
# This script configures root GID

set -e

echo "CIS 4.5.2.2 - Configuring root default group..."

# Set root primary group to GID 0
usermod -g 0 root

echo "Verifying root group:"
grep "^root:" /etc/passwd | cut -d: -f4

echo "CIS 4.5.2.2 remediation complete."