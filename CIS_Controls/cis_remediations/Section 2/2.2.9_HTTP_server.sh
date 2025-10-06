"#!/usr/bin/env bash
# CIS 2.2.9 - Ensure HTTP server is not installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Scope: remove Apache HTTP server components; stop/disable service.
# Note: We target the server pkgs 'httpd' and 'mod_ssl' (common server module).
#       We do not aggressively remove all 'httpd-*' tools to avoid collateral impact.
PKGS=(httpd mod_ssl httpd24-httpd httpd24-mod_ssl)
UNIT=""httpd.service""
CONF_DIR=""/etc/httpd""
BACKUP_BASE=""/var/backups/cis""
TS=""$(date +%Y%m%d%H%M%S)""
BACKUP_DIR=""${BACKUP_BASE}/${TS}-httpd""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

mkdir -p -m 0700 ""$BACKUP_DIR""

# 2) Stop/disable/mask the service if present
if systemctl list-unit-files | grep -qE ""^${UNIT}""; then
  systemctl stop ""${UNIT}"" 2>/dev/null || true
  systemctl disable ""${UNIT}"" 2>/dev/null || true
  systemctl mask ""${UNIT}"" 2>/dev/null || true
fi
systemctl daemon-reload || true

# 3) Backup configuration (before removal)
[[ -d ""$CONF_DIR"" ]] && cp -a ""$CONF_DIR"" ""${BACKUP_DIR}/""

# 4) Remove server packages (idempotent)
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

# 5) Kill any lingering httpd processes
pkill -TERM -x httpd 2>/dev/null || true
sleep 1
pkill -KILL -x httpd 2>/dev/null || true

# 6) Verification (runtime + persistence)
FAIL=0

# a) Packages not installed
for p in ""${PKGS[@]}""; do
  if rpm -q ""$p"" &>/dev/null; then
    echo ""FAIL: Package '$p' still installed""
    FAIL=1
  fi
done

# b) Service not enabled/active if unit still present
if systemctl list-unit-files | grep -qE ""^${UNIT}""; then
  state=""$(systemctl is-enabled ""${UNIT}"" 2>/dev/null || true)""
  if [[ ""$state"" != ""disabled"" && ""$state"" != ""masked"" ]]; then
    echo ""FAIL: ${UNIT} is enabled ($state)""
    FAIL=1
  fi
  if systemctl is-active ""${UNIT}"" >/dev/null 2>&1; then
    echo ""FAIL: ${UNIT} is active""
    FAIL=1
  fi
fi

# c) No running process
if pgrep -x httpd >/dev/null 2>&1; then
  echo ""FAIL: httpd process still running""
  FAIL=1
fi

# d) Optional: warn if ports 80/443 are in use (not a hard fail)
if ss -ltnu 2>/dev/null | awk '{print $5}' | grep -qE '(:|\.)(80|443)$'; then
  echo ""NOTE: Port 80/443 is in use by another process; ensure no HTTP server is active.""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: HTTP server (Apache httpd) not installed/running (CIS 2.2.9)""
  exit 0
else
  exit 1
fi"
