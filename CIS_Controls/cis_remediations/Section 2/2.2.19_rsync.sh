"#!/usr/bin/env bash
# CIS 2.2.19 - Ensure rsync is not installed OR rsyncd is masked (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Behavior (env vars):
#   CIS_RSYNC_REMOVE=""1""  -> attempt removal of 'rsync' package (default ""0"").
#   If 'rsync' must remain (dependency/client use), the script masks/stops rsyncd.service.

set -euo pipefail

CIS_RSYNC_REMOVE=""${CIS_RSYNC_REMOVE:-0}""

PKG=""rsync""
UNITS=(rsyncd.service)                 # EL7 rsync daemon unit
CONF_FILES=(/etc/rsyncd.conf /etc/xinetd.d/rsync)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-rsync""

# ---------- 1) Root check ----------
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# ---------- 2) If package present, backup config and optionally remove ----------
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  for f in ""${CONF_FILES[@]}""; do
    [[ -e ""$f"" ]] && cp -a ""$f"" ""${BACKUP_DIR}/""
  done
  if [[ ""$CIS_RSYNC_REMOVE"" == ""1"" ]]; then
    yum -y remove ""$PKG"" >/dev/null || true
    systemctl daemon-reload >/dev/null || true
  fi
fi

# ---------- 3) Stop/disable/mask rsync daemon service (meets CIS when pkg required) ----------
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload >/dev/null || true

# ---------- 4) Terminate any lingering rsync *daemon* (do not kill client copies) ----------
# Only target processes that look like a daemon (have --daemon in cmdline)
pkill -TERM -f '(^|/| )rsync(\s+).*--daemon' 2>/dev/null || true
sleep 1
pkill -KILL -f '(^|/| )rsync(\s+).*--daemon' 2>/dev/null || true

# ---------- 5) Verification ----------
FAIL=0

# a) If package remains installed, rsyncd must be masked/disabled and inactive
if rpm -q ""$PKG"" >/dev/null 2>&1; then
  for u in ""${UNITS[@]}""; do
    if systemctl list-unit-files | grep -qE ""^${u}""; then
      state=""$(systemctl is-enabled ""$u"" 2>/dev/null || true)""
      if [[ ""$state"" != ""masked"" && ""$state"" != ""disabled"" ]]; then
        echo ""FAIL: $u is enabled ($state); must be masked/disabled when rsync is installed""
        FAIL=1
      fi
      if systemctl is-active ""$u"" >/dev/null 2>&1; then
        echo ""FAIL: $u is active; must be stopped""
        FAIL=1
      fi
    fi
  done
fi

# b) If removal requested, verify package gone
if [[ ""$CIS_RSYNC_REMOVE"" == ""1"" ]]; then
  if rpm -q ""$PKG"" >/dev/null 2>&1; then
    echo ""FAIL: Package '$PKG' still installed (removal requested)""
    FAIL=1
  fi
fi

# c) No rsync daemon process listening
if pgrep -f '(^|/| )rsync(\s+).*--daemon' >/dev/null 2>&1; then
  echo ""FAIL: rsync daemon process still running""
  FAIL=1
fi

# d) Optional: warn if TCP 873 is in use (not a hard fail)
if ss -ltn 2>/dev/null | awk '$1==""LISTEN"" && $4 ~ /(:|\.)(873)$/ {found=1} END{exit !found}'; then
  echo ""NOTE: TCP port 873 is in use; ensure no rsync daemon is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  if rpm -q ""$PKG"" >/dev/null 2>&1; then
    echo ""OK: rsync installed but rsyncd is masked/disabled and stopped (CIS 2.2.19)""
  else
    echo ""OK: rsync not installed (CIS 2.2.19)""
  fi
  exit 0
else
  exit 1
fi"
