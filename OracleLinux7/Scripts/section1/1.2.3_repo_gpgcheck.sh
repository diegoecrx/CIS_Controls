#!/bin/bash
# CIS Oracle Linux 7 - 1.2.3 Ensure repo_gpgcheck is globally activated
# Compatible with OCI (Oracle Cloud Infrastructure)
# NOTE: Not all repositories support repo_gpgcheck

echo "=== CIS 1.2.3 - Enable repo_gpgcheck globally ==="
echo "WARNING: Not all repositories support repo_gpgcheck."
echo "Check repository documentation before enabling."
echo ""

# Check current status
echo "Current repo_gpgcheck settings:"
grep -r "repo_gpgcheck" /etc/yum.conf /etc/yum.repos.d/ 2>/dev/null || echo "No repo_gpgcheck settings found"

echo ""
echo "To enable repo_gpgcheck globally, add to /etc/yum.conf:"
echo "  [main]"
echo "  repo_gpgcheck=1"
echo ""
echo "For per-repository configuration, edit /etc/yum.repos.d/*.repo files"
echo "Only enable for repositories that support it."
