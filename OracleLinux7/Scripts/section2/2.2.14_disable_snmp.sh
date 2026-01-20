#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.14
# Ensure snmp services are not in use
# This script stops and masks snmpd service

set -e

echo "CIS 2.2.14 - Disabling SNMP services..."

# Stop snmpd service if running
if systemctl is-active snmpd.service &>/dev/null; then
    echo "Stopping snmpd.service..."
    systemctl stop snmpd.service
fi

# Mask snmpd service to prevent it from being started
systemctl mask snmpd.service 2>/dev/null || true

echo "CIS 2.2.14 remediation complete - SNMP service is stopped and masked."