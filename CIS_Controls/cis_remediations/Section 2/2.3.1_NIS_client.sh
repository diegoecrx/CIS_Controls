"#!/usr/bin/env bash
# CIS 2.3.1 - Ensure NIS Client is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PKG=""ypbind""
UNITS=(ypbind.service)
CONF_FILES=(/etc/yp.conf /etc/sysconfig/ypbind)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-nis-client""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask client service if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup client configuration (before removal)
for f in ""${CONF_FILES[@]}""; do
  [[ -e ""$f"" ]] && cp -a ""$f"" ""${BACKUP_DIR}/""
done

# 4) Remove ypbind package (idempotent)
if rpm -q ""$PKG"" &>/dev/null; then
  yum -y remove ""$PKG"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 5) Terminate any lingering ypbind process
pkill -TERM -x ypbind 2>/dev/null || true
sleep 1
pkill -KILL -x ypbind 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Package not installed
if rpm -q ""$PKG"" &>/dev/null; then
  echo ""FAIL: Package '$PKG' still installed""
  FAIL=1
fi

# b) Unit not enabled/active if still present
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

# c) No ypbind process
if pgrep -x ypbind >/dev/null 2>&1; then
  echo ""FAIL: ypbind process still running""
  FAIL=1
fi

# d) Optional: warn if NIS-related RPC programs registered (not a hard fail)
if command -v rpcinfo >/dev/null 2>&1; then
  if rpcinfo -p 2>/dev/null | awk '{print $4}' | grep -qE 'ypbind'; then
    echo ""NOTE: RPC shows ypbind registered; ensure no NIS client components remain.""
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: NIS client (ypbind) not installed/running (CIS 2.3.1)""
  exit 0
else
  exit 1
fi"
