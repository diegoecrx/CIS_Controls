"#!/usr/bin/env bash
# CIS 2.2.3 - Ensure Avahi Server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKGS=(avahi avahi-autoipd)
UNITS=(avahi-daemon.service avahi-daemon.socket avahi-autoipd.service)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-avahi""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask related systemd units if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -q ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup configuration if present (before removal)
[[ -d /etc/avahi ]] && cp -a /etc/avahi ""${BACKUP_DIR}/""

# 4) Remove packages (idempotent)
to_remove=()
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    to_remove+=(""$p"")
  fi
done
if (( ${#to_remove[@]} > 0 )); then
  yum -y remove ""${to_remove[@]}"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Kill any lingering processes
pkill -TERM -x avahi-daemon 2>/dev/null || true
pkill -TERM -x avahi-autoipd 2>/dev/null || true
sleep 1
pkill -KILL -x avahi-daemon 2>/dev/null || true
pkill -KILL -x avahi-autoipd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Units absent or not active/enabled
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -q ""^${u}""; then
    if systemctl is-enabled ""$u"" &>/dev/null && [[ ""$(systemctl is-enabled ""$u"" 2>/dev/null)"" != ""masked"" && ""$(systemctl is-enabled ""$u"" 2>/dev/null)"" != ""disabled"" ]]; then
      echo ""FAIL: $u is enabled""
      FAIL=1
    fi
    if systemctl is-active ""$u"" &>/dev/null; then
      echo ""FAIL: $u is active""
      FAIL=1
    fi
  fi
done

# c) No running processes
if pgrep -x avahi-daemon >/dev/null 2>&1 || pgrep -x avahi-autoipd >/dev/null 2>&1; then
  echo ""FAIL: Avahi processes still running""
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Avahi not installed/running (CIS 2.2.3)""
  exit 0
else
  exit 1
fi"
