"#!/usr/bin/env bash
# CIS 2.2.14 - Ensure NIS server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Scope: remove NIS server components and ensure related services are disabled/stopped.
# Target packages/units are conservative to avoid client-side removals.
PKGS=(ypserv ypxfrd yppasswd)
UNITS=(ypserv.service ypxfrd.service yppasswdd.service)
CONF_DIRS=(/etc/yp /var/yp)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-nis""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prep backup dir
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Stop/disable/mask NIS-related services if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 4) Backup configuration/state (before removal)
for d in ""${CONF_DIRS[@]}""; do
  [[ -e ""$d"" ]] && cp -a ""$d"" ""${BACKUP_DIR}/""
done

# 5) Remove NIS server packages (idempotent)
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

# 6) Terminate any lingering NIS processes
pkill -TERM -x ypserv 2>/dev/null || true
pkill -TERM -x rpc.yppasswdd 2>/dev/null || true
pkill -TERM -x rpc.ypxfrd 2>/dev/null || true
sleep 1
pkill -KILL -x ypserv 2>/dev/null || true
pkill -KILL -x rpc.yppasswdd 2>/dev/null || true
pkill -KILL -x rpc.ypxfrd 2>/dev/null || true

# 7) Verification (runtime + persistence)
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

# c) No NIS server processes
if pgrep -x ypserv >/dev/null 2>&1 || pgrep -x rpc.yppasswdd >/dev/null 2>&1 || pgrep -x rpc.ypxfrd >/dev/null 2>&1; then
  echo ""FAIL: NIS server processes still running""
  FAIL=1
fi

# d) Optional: warn if ports typically used by NIS are in use (not a hard fail)
#    ypserv uses RPC dynamically; common map transfers via high UDP/TCP ports.
#    We provide a heads-up if rpcbind has active NIS services (heuristic).
if command -v rpcinfo >/dev/null 2>&1; then
  if rpcinfo -p 2>/dev/null | awk '{print $4}' | grep -qE 'ypserv|yppasswdd|ypxfrd'; then
    echo ""NOTE: RPC programs for NIS still registered; ensure no NIS components remain.""
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: NIS server not installed/running (CIS 2.2.14)""
  exit 0
else
  exit 1
fi"
