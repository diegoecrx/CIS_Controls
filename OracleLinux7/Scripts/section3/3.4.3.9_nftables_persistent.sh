#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 3.4.3.9
# Ensure nftables rules are permanent
# This script configures persistent nftables rules

set -e

echo "CIS 3.4.3.9 - Configuring persistent nftables rules..."

NFTABLES_CONF="/etc/sysconfig/nftables.conf"

# Check if nftables.conf exists
if [ -f "$NFTABLES_CONF" ]; then
    # Check if include directive exists
    if grep -q 'include "/etc/nftables' "$NFTABLES_CONF"; then
        echo "nftables include directive already configured."
    else
        echo "Adding include directive to $NFTABLES_CONF"
        echo 'include "/etc/nftables/nftables.rules"' >> "$NFTABLES_CONF"
    fi
else
    echo "Creating $NFTABLES_CONF with include directive"
    echo 'include "/etc/nftables/nftables.rules"' > "$NFTABLES_CONF"
fi

# Save current rules to file
mkdir -p /etc/nftables
nft list ruleset > /etc/nftables/nftables.rules 2>/dev/null || true

echo "CIS 3.4.3.9 remediation complete - nftables rules are persistent."