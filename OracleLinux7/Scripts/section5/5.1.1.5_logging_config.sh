#!/bin/bash
export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"
# CIS Oracle Linux 7 Benchmark - 5.1.1.5
# Ensure logging is configured
# This script provides PRINT ONLY (environment specific)

echo "CIS 5.1.1.5 - Checking logging configuration..."
echo "==========================================="
echo ""
echo "[INFO] This control requires site-specific configuration."
echo ""
echo "Current rsyslog configuration:"
grep -E "^\*\.|^auth|^mail|^cron|^local" /etc/rsyslog.conf 2>/dev/null | head -20
echo ""
echo "Recommended configuration (add to /etc/rsyslog.conf):"
echo "  *.emerg                          :omusrmsg:*"
echo "  auth,authpriv.*                  /var/log/secure"
echo "  mail.*                           -/var/log/mail"
echo "  mail.info                        -/var/log/mail.info"
echo "  mail.warning                     -/var/log/mail.warn"
echo "  mail.err                         /var/log/mail.err"
echo "  cron.*                           /var/log/cron"
echo "  *.=warning;*.=err                -/var/log/warn"
echo "  *.crit                           /var/log/warn"
echo "  *.*;mail.none;news.none          -/var/log/messages"
echo "  local0,local1.*                  -/var/log/localmessages"
echo "  local2,local3.*                  -/var/log/localmessages"
echo "  local4,local5.*                  -/var/log/localmessages"
echo "  local6,local7.*                  -/var/log/localmessages"
echo ""
echo "After changes, run: systemctl restart rsyslog"
echo ""
echo "CIS 5.1.1.5 - Manual review required."