#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.21
# Ensure mail transfer agents are configured for local-only mode
# This script configures postfix for local-only mail

set -e

echo "CIS 2.2.21 - Configuring MTA for local-only mode..."

POSTFIX_CONF="/etc/postfix/main.cf"

# Check if postfix is installed
if rpm -q postfix &>/dev/null; then
    # Backup existing configuration
    if [ -f "$POSTFIX_CONF" ]; then
        cp "$POSTFIX_CONF" "${POSTFIX_CONF}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    
    # Check if inet_interfaces is already set to loopback-only
    if grep -qE '^\s*inet_interfaces\s*=\s*loopback-only' "$POSTFIX_CONF"; then
        echo "postfix is already configured for local-only mode."
    else
        # Update or add inet_interfaces setting
        if grep -qE '^\s*inet_interfaces\s*=' "$POSTFIX_CONF"; then
            sed -i 's/^\s*inet_interfaces\s*=.*/inet_interfaces = loopback-only/' "$POSTFIX_CONF"
        else
            echo "inet_interfaces = loopback-only" >> "$POSTFIX_CONF"
        fi
        echo "postfix configured for local-only mode."
        
        # Restart postfix
        systemctl restart postfix
    fi
else
    echo "postfix is not installed. No action needed."
fi

echo "CIS 2.2.21 remediation complete - MTA configured for local-only mode."