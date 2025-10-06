"#!/usr/bin/env bash
# CIS 2.2.2 - Ensure X11 Server components are not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=0

set -euo pipefail

PATTERN='xorg-x11-server*'
SERVICE_CANDIDATES=(gdm lightdm sddm lxdm xdm)
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-x11""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable any display manager to ensure X server isn't active
for svc in ""${SERVICE_CANDIDATES[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${svc}\.service""; then
    systemctl stop ""${svc}.service"" 2>/dev/null || true
    systemctl disable ""${svc}.service"" 2>/dev/null || true
    systemctl mask ""${svc}.service"" 2>/dev/null || true
  fi
done
systemctl daemon-reload || true

# 3) Backup Xorg configuration if present
[[ -f /etc/X11/xorg.conf ]] && cp -a /etc/X11/xorg.conf ""${BACKUP_DIR}/""
[[ -d /etc/X11/xorg.conf.d ]] && cp -a /etc/X11/xorg.conf.d ""${BACKUP_DIR}/""

# 4) Remove X11 server packages if installed (idempotent)
mapfile -t pkgs < <(rpm -qa ""${PATTERN}"" 2>/dev/null || true)
if (( ${#pkgs[@]} > 0 )); then
  yum -y remove ""${pkgs[@]}"" >/dev/null || true
fi

# 5) Extra cleanup: ensure no Xorg process remains
#    (if still running due to old session, try to terminate gracefully)
if pgrep -x Xorg >/dev/null 2>&1 || pgrep -x X >/dev/null 2>&1; then
  pkill -TERM -x Xorg 2>/dev/null || true
  pkill -TERM -x X 2>/dev/null || true
  sleep 2
  pkill -KILL -x Xorg 2>/dev/null || true
  pkill -KILL -x X 2>/dev/null || true
fi

# 6) Verification (runtime + persistence)
FAIL=0

# a) No matching RPMs
if rpm -qa ""${PATTERN}"" >/dev/null 2>&1 && [[ -n ""$(rpm -qa ""${PATTERN}"")"" ]]; then
  echo ""FAIL: One or more X11 server packages still installed: $(rpm -qa ""${PATTERN}"" | tr '\n' ' ')""
  FAIL=1
fi

# b) No Xorg process
if pgrep -x Xorg >/dev/null 2>&1 || pgrep -x X >/dev/null 2>&1; then
  echo ""FAIL: X server process still running""
  FAIL=1
fi

# c) Display managers not active (informational, do not hard-fail if units absent)
for svc in ""${SERVICE_CANDIDATES[@]}""; do
  if systemctl list-unit-files | grep -qE ""^${svc}\.service""; then
    if systemctl is-active ""${svc}.service"" >/dev/null 2>&1; then
      echo ""FAIL: ${svc}.service is active""
      FAIL=1
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: X11 server components not installed/running (CIS 2.2.2)""
  exit 0
else
  exit 1
fi"
