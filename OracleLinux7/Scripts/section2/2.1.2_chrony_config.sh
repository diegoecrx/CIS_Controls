#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 2.1.2
# Ensure chrony is configured
# This script configures chrony with appropriate NTP servers

set -e

echo "CIS 2.1.2 - Configuring chrony..."

CHRONY_CONF="/etc/chrony.conf"

# Backup existing configuration
if [ -f "$CHRONY_CONF" ]; then
    cp "$CHRONY_CONF" "${CHRONY_CONF}.bak.$(date +%Y%m%d%H%M%S)"
fi

# Create proper chrony configuration
cat > "$CHRONY_CONF" << 'EOF'
# OCI NTP server (primary)
server 169.254.169.254 iburst prefer

# Oracle public NTP servers
pool 0.oracle.pool.ntp.org iburst
pool 1.oracle.pool.ntp.org iburst

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Specify directory for log files.
logdir /var/log/chrony
EOF

echo "Chrony configuration updated with OCI and Oracle pool NTP servers."

# Restart chronyd to apply changes
systemctl restart chronyd

echo "CIS 2.1.2 remediation complete."
