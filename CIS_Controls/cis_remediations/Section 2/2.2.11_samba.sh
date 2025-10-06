"#!/usr/bin/env bash
# CIS 2.2.11 - Ensure Samba is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Scope: remove Samba server components and ensure services are not running.
# We target 'samba' (server) and common subpackages that pull in smbd/nmbd/winbindd.
PKGS_CANDIDATES=(samba samba-common samba-common-tools samba-client samba-winbind samba-winbind-clients)
UNITS=(smb.service nmb.service winbind.service)
CONF_DIR=""/etc/samba""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-samba""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Prep backup dir
mkdir -p -m 0700 ""$BACKUP_DIR""

# 3) Stop/disable/mask Samba-related services if present
for u in ""${UNITS[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${u}""; then
    systemctl stop ""$u"" 2>/dev/null || true
    systemctl disable ""$u"" 2>/dev/null || true
    systemctl mask ""$u"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 4) Backup configuration/state (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""

# 5) Remove Samba packages (idempotent)
to_remove=()
for p in ""${PKGS_CANDIDATES[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    to_remove+=(""$p"")
  fi
done
if (( ${#to_remove[@]} > 0 )); then
  yum -y remove ""${to_remove[@]}"" >/dev/null || true
  systemctl daemon-reload || true
fi

# 6) Kill any lingering processes
pkill -TERM -x smbd 2>/dev/null || true
pkill -TERM -x nmbd 2>/dev/null || true
pkill -TERM -x winbindd 2>/dev/null || true
sleep 1
pkill -KILL -x smbd 2>/dev/null || true
pkill -KILL -x nmbd 2>/dev/null || true
pkill -KILL -x winbindd 2>/dev/null || true

# 7) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS_CANDIDATES[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Units not enabled/active if present
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

# c) No running processes
if pgrep -x smbd >/dev/null 2>&1 || pgrep -x nmbd >/dev/null 2>&1 || pgrep -x winbindd >/dev/null 2>&1; then
  echo ""FAIL: Samba processes still running""
  FAIL=1
fi

# d) Optional: warn if SMB/CIFS ports (137-139,445) are in use (not a hard fail)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(137|138|139|445)$'; then
  echo ""NOTE: One of the SMB ports (137/138/139/445) is in use by another process; ensure no Samba server is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Samba not installed/running (CIS 2.2.11)""
  exit 0
else
  exit 1
fi"
