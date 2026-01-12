#!/bin/bash
# CIS Oracle Linux 7 Benchmark - 5.3.2
# Ensure filesystem integrity is regularly checked

set -e

echo "CIS 5.3.2 - Configuring AIDE scheduled check..."

# Create systemd service for AIDE check
cat > /etc/systemd/system/aidecheck.service << 'EOF'
[Unit]
Description=Aide Check

[Service]
Type=simple
ExecStart=/usr/sbin/aide --check

[Install]
WantedBy=multi-user.target
EOF

# Create systemd timer for daily AIDE check
cat > /etc/systemd/system/aidecheck.timer << 'EOF'
[Unit]
Description=Aide check every day at 5AM

[Timer]
OnCalendar=*-*-* 05:00:00
Unit=aidecheck.service

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown root:root /etc/systemd/system/aidecheck.*
chmod 0644 /etc/systemd/system/aidecheck.*

# Reload and enable
systemctl daemon-reload
systemctl enable aidecheck.service
systemctl --now enable aidecheck.timer

echo "Verifying timer status:"
systemctl status aidecheck.timer --no-pager | head -5

echo ""
echo "AIDE check scheduled daily at 5AM."

echo "CIS 5.3.2 remediation complete."