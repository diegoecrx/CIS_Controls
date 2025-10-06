"#!/usr/bin/env bash
# CIS 2.2.13 - Ensure net-snmp is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Scope: remove SNMP server packages; stop and disable related services.
# Note: We avoid force-removing libraries that other pkgs might depend on.
PKGS=(net-snmp net-snmp-utils)
UNITS=(snmpd.service snmptrapd.service)
CONF_DIR=""/etc/snmp""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-net-snmp""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask SNMP units if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup configuration (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""

# 4) Remove SNMP packages (idempotent)
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

# 5) Terminate any lingering processes
pkill -TERM -x snmpd 2>/dev/null || true
pkill -TERM -x snmptrapd 2>/dev/null || true
sleep 1
pkill -KILL -x snmpd 2>/dev/null || true
pkill -KILL -x snmptrapd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Units not enabled/active if still present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    state=""$(systemctl is-enabled ""$u"" 2>/dev/null || true)""
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

# c) No SNMP-related processes
if pgrep -x snmpd >/dev/null 2>&1 || pgrep -x snmptrapd >/dev/null 2>&1; then
  echo ""FAIL: SNMP processes still running""
  FAIL=1
fi

# d) Optional: warn if UDP 161/162 is in use (not a hard fail)
if ss -lun 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(161|162)$'; then
  echo ""NOTE: UDP port 161/162 is in use by another process; ensure no SNMP server is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: net-snmp (snmpd) not installed/running (CIS 2.2.13)""
  exit 0
else
  exit 1
fi"
