"#!/usr/bin/env bash
# CIS 2.2.15 - Ensure telnet-server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKGS=(telnet-server)
UNITS=(telnet.socket telnet@.service telnet.service xinetd.service)
XINETD_TELNET=""/etc/xinetd.d/telnet""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-telnet""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prep backup dir
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Stop/disable/mask telnet-related units if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done

# 4) Backup xinetd telnet config if present (before removal)
[[ -f ""$XINETD_TELNET"" ]] && cp -a ""$XINETD_TELNET"" ""${BACKUP_DIR}/""

systemctl daemon-reload || true

# 5) Remove telnet server package(s) (idempotent)
to_remove=()
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    to_remove+=(""$p"")
  fi
done
if (( ${#to_remove[@]} )); then
  yum -y remove ""${to_remove[@]}"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 6) Ensure no lingering telnetd processes (in.telnetd)
pkill -TERM -x in.telnetd 2>/dev/null || true
sleep 1
pkill -KILL -x in.telnetd 2>/dev/null || true

# 7) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Telnet-related systemd units not active/enabled (if present)
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    state=""$(systemctl is-enabled ""$u"" 2>/devnull || true)""
    if [[ ""$state"" != ""disabled"" && ""$state"" != ""masked"" ]]; then
      echo ""FAIL: $u is enabled ($state)""
      FAIL=1
    fi
    if systemctl is-active ""$u"" >/dev/null 2>&1; then
      echo ""FAIL: $u is active""
      FAIL=1
    fi
  fi
done

# c) No telnetd process
if pgrep -x in.telnetd >/dev/null 2>&1; then
  echo ""FAIL: in.telnetd process still running""
  FAIL=1
fi

# d) Optional: warn if TCP port 23 is in use (not a hard fail)
if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE '(:|\.)(23)$'; then
  echo ""NOTE: TCP port 23 is in use by another process; ensure no Telnet service is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Telnet server not installed/running (CIS 2.2.15)""
  exit 0
else
  exit 1
fi"
