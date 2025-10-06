"#!/usr/bin/env bash
# CIS 2.2.18 - Ensure rpcbind is not installed OR rpcbind services are masked (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Behavior (set via env vars before running):
#   - CIS_RPCBIND_REMOVE=""1"" -> attempt removal of rpcbind if installed (default ""0"")
#     If removal isn't desired/possible (dependencies), the script masks/stops services.

set -euo pipefail

CIS_RPCBIND_REMOVE=""${CIS_RPCBIND_REMOVE:-0}""

PKG=""rpcbind""
UNITS=(rpcbind.service rpcbind.socket)
SYSCONF=""/etc/sysconfig/rpcbind""     # rarely used; back up if present
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-rpcbind""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) If package present, optional backup of config then optional removal
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  [[ -f ""$SYSCONF"" ]] && cp -a ""$SYSCONF"" ""${BACKUP_DIR}/""
  if [[ ""$CIS_RPCBIND_REMOVE"" == ""1"" ]]; then
    yum -y remove ""$PKG"" >/dev/null || true
    systemctl daemon-reload || true
  fi
fi

# 3) Regardless of package state, ensure services are stopped/disabled/masked
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 4) Kill any lingering rpcbind process
pkill -TERM -x rpcbind 2>/dev/null || true
sleep 1
pkill -KILL -x rpcbind 2>/dev/null || true

# 5) Verification (runtime + persistence)
FAIL=0

# a) If package still installed, both units must be masked/disabled and inactive
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  for u in ""${UNITS[@]}""; do
    if systemctl list-unit-files | grep -qE ""^${u}""; then
      state=""$(systemctl is-enabled ""$u"" 2>/dev/null || true)""
      if [[ ""$state"" != ""masked"" && ""$state"" != ""disabled"" ]]; then
        echo ""FAIL: $u is enabled ($state); must be masked/disabled when rpcbind is installed""
        FAIL=1
      fi
      if systemctl is-active ""$u"" >/dev/null 2>&1; then
        echo ""FAIL: $u is active; must be stopped""
        FAIL=1
      fi
    fi
  done
fi

# b) If CIS_RPCBIND_REMOVE=1, verify removal
if [[ ""$CIS_RPCBIND_REMOVE"" == ""1"" ]]; then
  if rpm -q ""$PKG"" >/dev/null 2>&1; then
    echo ""FAIL: Package '$PKG' still installed (removal requested)""
    FAIL=1
  fi
fi

# c) No rpcbind process
if pgrep -x rpcbind >/dev/null 2>&1; then
  echo ""FAIL: rpcbind process still running""
  FAIL=1
fi

# d) Optional: warn if portmapper ports are in use (TCP/UDP 111)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(111)$'; then
  echo ""NOTE: Port 111 is in use; ensure no rpcbind-compatible service is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  if rpm -q ""$PKG"" >/dev/null 2>&1; then
    echo ""OK: rpcbind installed but services are masked/disabled and stopped (CIS 2.2.18)""
  else
    echo ""OK: rpcbind not installed (CIS 2.2.18)""
  fi
  exit 0
else
  exit 1
fi"
