#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.2.1.2
# Ensure systemd-journal-remote is configured
# This script provides PRINT ONLY (environment specific)

echo "CIS 5.1.2.1.2 - Journal remote configuration..."
echo "==========================================="
echo ""
echo "[INFO] This control requires site-specific configuration."
echo ""
echo "Edit /etc/systemd/journal-upload.conf and configure:"
echo ""
echo "  URL=<your-remote-log-server>"
echo "  ServerKeyFile=/etc/ssl/private/journal-upload.pem"
echo "  ServerCertificateFile=/etc/ssl/certs/journal-upload.pem"
echo "  TrustedCertificateFile=/etc/ssl/ca/trusted.pem"
echo ""
echo "After changes, run: systemctl restart systemd-journal-upload"
echo ""
echo "CIS 5.1.2.1.2 - Manual configuration required."