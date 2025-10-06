"#!/usr/bin/env bash
# CIS 2.2.17 - Ensure nfs-utils is not installed OR nfs-server is masked (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Behavior (set via env vars before running):
#   - CIS_NFS_REMOVE: ""1"" to attempt removal of nfs-utils if installed (default ""0"")
#       If removal isn't desired or nfs-utils is needed as a dependency, the script
#       will stop/disable/mask nfs-server.service to meet the control intent.

set -euo pipefail

CIS_NFS_REMOVE=""${CIS_NFS_REMOVE:-0}""

PKG=""nfs-utils""
UNITS=(nfs-server.service nfs.service)   # nfs.service may be an alias
CONF_FILES=(/etc/nfs.conf /etc/exports)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-nfs""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) If the package is present, decide: remove or mask service
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  # Backup configs if present
  for f in ""${CONF_FILES[@]}""; do
    [[ -e ""$f"" ]] && cp -a ""$f"" ""${BACKUP_DIR}/""
  done

  if [[ ""$CIS_NFS_REMOVE"" == ""1"" ]]; then
    # Try package removal (idempotent)
    yum -y remove ""$PKG"" >/dev/null || true
    systemctl daemon-reload || true
  fi
fi

# 3) Regardless of package state, ensure nfs-server is stopped/disabled/masked (meets CIS when pkg required)
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 4) Kill any lingering NFS-related daemons (best-effort)
pkill -TERM -x rpc.mountd 2>/dev/null || true
pkill -TERM -x nfsd 2>/dev/null || true
pkill -TERM -x rpc.statd 2>/dev/null || true
sleep 1
pkill -KILL -x rpc.mountd 2>/dev/null || true
pkill -KILL -x nfsd 2>/dev/null || true
pkill -KILL -x rpc.statd 2>/dev/null || true

# 5) Verification (runtime + persistence)
FAIL=0

# a) If package still installed, ensure nfs-server is masked and inactive
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  for u in ""${UNITS[@]}""; do
    if systemctl list-unit-files | grep -qE ""^${u}""; then
      state=""$(systemctl is-enabled ""$u"" 2>/dev/null || true)""
      if [[ ""$state"" != ""masked"" && ""$state"" != ""disabled"" ]]; then
        echo ""FAIL: $u is enabled ($state); must be masked/disabled when nfs-utils is present""
        FAIL=1
      fi
      if systemctl is-active ""$u"" >/dev/null 2>&1; then
        echo ""FAIL: $u is active; must be stopped""
        FAIL=1
      fi
    fi
  done
fi

# b) If CIS_NFS_REMOVE=1, confirm package removal succeeded (else masking suffices)
if [[ ""$CIS_NFS_REMOVE"" == ""1"" ]]; then
  if rpm -q ""$PKG"" >/dev/null 2>&1; then
    echo ""FAIL: Package '$PKG' still installed (removal requested)""
    FAIL=1
  fi
fi

# c) Optional: warn if port 2049 is in use (not a hard fail)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(2049)$'; then
  echo ""NOTE: Port 2049 appears in use; ensure no NFS server is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  if rpm -q ""$PKG"" >/dev/null 2>&1; then
    echo ""OK: nfs-utils installed but nfs-server is masked/disabled and stopped (CIS 2.2.17)""
  else
    echo ""OK: nfs-utils not installed (CIS 2.2.17)""
  fi
  exit 0
else
  exit 1
fi"
