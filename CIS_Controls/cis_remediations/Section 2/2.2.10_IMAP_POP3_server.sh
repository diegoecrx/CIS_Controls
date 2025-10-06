"#!/usr/bin/env bash
# CIS 2.2.10 - Ensure IMAP and POP3 server is not installed (Oracle Linux 7)
# Target: dovecot package and service
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""dovecot""
UNIT=""dovecot.service""
CONF_DIR=""/etc/dovecot""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-dovecot""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask service if present
if systemctl list-unit-files | grep -qE ""^${UNIT}""; then
  systemctl stop ""$UNIT"" 2>/dev/null || true
  systemctl disable ""$UNIT"" 2>/dev/null || true
  systemctl mask ""$UNIT"" 2>/dev/null || true
fi
systemctl daemon-reload || true

# 3) Backup configuration if present (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""

# 4) Remove package (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Terminate any lingering processes
pkill -TERM -x dovecot 2>/dev/null || true
pkill -TERM -x imap-login 2>/dev/null || true
pkill -TERM -x pop3-login 2>/dev/null || true
sleep 1
pkill -KILL -x dovecot 2>/dev/null || true
pkill -KILL -x imap-login 2>/dev/null || true
pkill -KILL -x pop3-login 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

# b) Service not enabled/active if unit exists
if systemctl list-unit-files | grep -qE ""^${UNIT}""; then
  state=""$(systemctl is-enabled ""$UNIT"" 2>/dev/null || true)""
  if [[ ""$state"" != ""disabled"" && ""$state"" != ""masked"" ]]; then
    echo ""FAIL: ${UNIT} is enabled ($state)""
    FAIL=1
  fi
  if systemctl is-active ""$UNIT"" >/dev/null 2>&1; then
    echo ""FAIL: ${UNIT} is active""
    FAIL=1
  fi
fi

# c) No IMAP/POP3 processes
if pgrep -x dovecot >/dev/null 2>&1 || pgrep -x imap-login >/dev/null 2>&1 || pgrep -x pop3-login >/dev/null 2>&1; then
  echo ""FAIL: Dovecot/IMAP/POP3 processes still running""
  FAIL=1
fi

# d) Optional: warn if typical ports are in use (143, 993, 110, 995)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(143|993|110|995)$'; then
  echo ""NOTE: One of the IMAP/POP3 ports (143/993/110/995) is in use by another process.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: IMAP/POP3 server (dovecot) not installed/running (CIS 2.2.10)""
  exit 0
else
  exit 1
fi"
