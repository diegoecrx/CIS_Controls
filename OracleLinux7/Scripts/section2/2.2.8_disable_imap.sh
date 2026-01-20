#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.2.8
# Ensure message access server services are not in use
# This script stops and masks dovecot and cyrus-imapd services

set -e

echo "CIS 2.2.8 - Disabling message access server services..."

# Stop dovecot services if running
if systemctl is-active dovecot.socket &>/dev/null; then
    echo "Stopping dovecot.socket..."
    systemctl stop dovecot.socket
fi

if systemctl is-active dovecot.service &>/dev/null; then
    echo "Stopping dovecot.service..."
    systemctl stop dovecot.service
fi

if systemctl is-active cyrus-imapd.service &>/dev/null; then
    echo "Stopping cyrus-imapd.service..."
    systemctl stop cyrus-imapd.service
fi

# Mask services to prevent them from being started
systemctl mask dovecot.socket 2>/dev/null || true
systemctl mask dovecot.service 2>/dev/null || true
systemctl mask cyrus-imapd.service 2>/dev/null || true

echo "CIS 2.2.8 remediation complete - message access server services are stopped and masked."