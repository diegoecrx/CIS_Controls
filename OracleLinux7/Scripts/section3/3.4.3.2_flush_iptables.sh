#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 3.4.3.2
# Ensure iptables are flushed with nftables
# This script flushes iptables when using nftables

set -e

echo "CIS 3.4.3.2 - Flushing iptables..."

# Flush iptables
iptables -F 2>/dev/null || echo "iptables flush failed or not available"

# Flush ip6tables
ip6tables -F 2>/dev/null || echo "ip6tables flush failed or not available"

echo "CIS 3.4.3.2 remediation complete - iptables flushed."