#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.1.2
# Ensure a single firewall configuration utility is in use
# This script detects enabled firewalls and prompts to disable extras

set -e

echo "CIS 3.4.1.2 - Single Firewall Configuration Utility Check"
echo "=========================================================="
echo ""

# Detect enabled firewalls
FIREWALLD_ENABLED=false
NFTABLES_ENABLED=false
IPTABLES_ENABLED=false

if systemctl is-enabled firewalld 2>/dev/null | grep -q "enabled"; then
    FIREWALLD_ENABLED=true
    echo "[ENABLED] firewalld"
fi

if systemctl is-enabled nftables 2>/dev/null | grep -q "enabled"; then
    NFTABLES_ENABLED=true
    echo "[ENABLED] nftables"
fi

if systemctl is-enabled iptables 2>/dev/null | grep -q "enabled"; then
    IPTABLES_ENABLED=true
    echo "[ENABLED] iptables"
fi

if systemctl is-enabled ip6tables 2>/dev/null | grep -q "enabled"; then
    echo "[ENABLED] ip6tables (paired with iptables)"
fi

echo ""

# Count enabled firewalls
COUNT=0
$FIREWALLD_ENABLED && ((COUNT++)) || true
$NFTABLES_ENABLED && ((COUNT++)) || true
$IPTABLES_ENABLED && ((COUNT++)) || true

if [ $COUNT -eq 0 ]; then
    echo "WARNING: No firewall is currently enabled!"
    echo "Recommendation: Enable one of: firewalld, nftables, or iptables"
    exit 1
elif [ $COUNT -eq 1 ]; then
    echo "COMPLIANT: Only one firewall is enabled."
    exit 0
else
    echo "NON-COMPLIANT: Multiple firewalls are enabled ($COUNT found)"
    echo ""
fi

# Prompt to disable firewalld
if $FIREWALLD_ENABLED; then
    read -p "Disable firewalld? (yes/no): " RESPONSE
    if [[ "$RESPONSE" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Stopping and disabling firewalld..."
        systemctl stop firewalld
        systemctl disable firewalld
        systemctl mask firewalld
        echo "firewalld disabled."
    else
        echo "Keeping firewalld enabled."
    fi
    echo ""
fi

# Prompt to disable nftables
if $NFTABLES_ENABLED; then
    read -p "Disable nftables? (yes/no): " RESPONSE
    if [[ "$RESPONSE" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Stopping and disabling nftables..."
        systemctl stop nftables
        systemctl disable nftables
        systemctl mask nftables
        echo "nftables disabled."
    else
        echo "Keeping nftables enabled."
    fi
    echo ""
fi

# Prompt to disable iptables
if $IPTABLES_ENABLED; then
    read -p "Disable iptables? (yes/no): " RESPONSE
    if [[ "$RESPONSE" =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Stopping and disabling iptables..."
        systemctl stop iptables
        systemctl disable iptables
        systemctl stop ip6tables 2>/dev/null || true
        systemctl disable ip6tables 2>/dev/null || true
        echo "iptables disabled."
    else
        echo "Keeping iptables enabled."
    fi
    echo ""
fi

echo "CIS 3.4.1.2 remediation complete."