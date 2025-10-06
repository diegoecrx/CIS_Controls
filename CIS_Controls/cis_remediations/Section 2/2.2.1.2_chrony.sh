"#!/usr/bin/env bash
# CIS 2.2.1.2 - Ensure chrony is configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Behavior (set via env vars before running):
#  - CIS_CHRONY_SOURCES: comma-separated chrony directives to ensure present.
#       Example: 'server time.google.com iburst,server time.cloudflare.com iburst'
#       Default: 'pool 2.pool.ntp.org iburst'
#  - CIS_CHRONY_CONF: path to chrony.conf (default /etc/chrony.conf)

set -euo pipefail

CIS_CHRONY_SOURCES=""${CIS_CHRONY_SOURCES:-pool 2.pool.ntp.org iburst}""
CHRONY_CONF=""${CIS_CHRONY_CONF:-/etc/chrony.conf}""
SYSCONF=""/etc/sysconfig/chronyd""
SERVICE=""chronyd""

TS=""$(date +%Y%m%d%H%M%S)""

# 1) Root check
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure chrony installed
if ! rpm -q chrony >/dev/null 2>&1; then
  yum -y install chrony >/dev/null
fi

# 3) Ensure config files exist and secure; create timestamped backups
if [[ ! -f ""$CHRONY_CONF"" ]]; then
  install -m 0644 -o root -g root /dev/null ""$CHRONY_CONF""
fi
cp -p ""$CHRONY_CONF"" ""${CHRONY_CONF}.bak.${TS}""

if [[ ! -f ""$SYSCONF"" ]]; then
  install -m 0644 -o root -g root /dev/null ""$SYSCONF""
fi
cp -p ""$SYSCONF"" ""${SYSCONF}.bak.${TS}""

# 4) Ensure desired server/pool lines are present (append if missing; do not remove others)
#    Split CIS_CHRONY_SOURCES by comma boundaries.
IFS=',' read -r -a SOURCES <<< ""$CIS_CHRONY_SOURCES""
for src in ""${SOURCES[@]}""; do
  # trim leading/trailing spaces
  src=""$(echo ""$src"" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')""
  [[ -z ""$src"" ]] && continue
  # Check if an identical line already exists (ignoring leading spaces)
  if ! grep -Eq ""^[[:space:]]*$(printf '%s' ""$src"" | sed 's/[^^$.*+?()[\]{}|/]/\\&/g')"" ""$CHRONY_CONF""; then
    echo ""$src"" >> ""$CHRONY_CONF""
  fi
done

# 5) Ensure chronyd runs as 'chrony' user via -u chrony in /etc/sysconfig/chronyd OPTIONS
#    Preserve any existing options and add -u chrony if missing.
if grep -qE '^\s*OPTIONS=' ""$SYSCONF""; then
  if ! grep -qE '^\s*OPTIONS=.*\B-u[[:space:]]+chrony\b' ""$SYSCONF""; then
    # Insert -u chrony just before closing quote or append if unquoted
    sed -ri 's/^(\s*OPTIONS="")(.*)(""\s*)$/\1\2 -u chrony\3/; t; s/^(\s*OPTIONS=)(.*)$/\1""\2 -u chrony""/' ""$SYSCONF""
  fi
else
  echo 'OPTIONS=""-u chrony""' >> ""$SYSCONF""
fi

# 6) Harden file permissions (chrony.conf should be 0644 root:root)
chown root:root ""$CHRONY_CONF"" ""$SYSCONF""
chmod 0644 ""$CHRONY_CONF"" ""$SYSCONF""

# 7) Enable and restart service
systemctl enable ""$SERVICE"" >/dev/null
systemctl daemon-reload >/dev/null
systemctl restart ""$SERVICE"" >/dev/null || true  # allow transient failures before sources reachable

# 8) Verification (runtime + persistence)
FAIL=0

# a) Verify each requested source line exists
for src in ""${SOURCES[@]}""; do
  src=""$(echo ""$src"" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')""
  [[ -z ""$src"" ]] && continue
  grep -Eq ""^[[:space:]]*$(printf '%s' ""$src"" | sed 's/[^^$.*+?()[\]{}|/]/\\&/g')"" ""$CHRONY_CONF"" \
    || { echo ""FAIL: Missing chrony source line: '$src' in $CHRONY_CONF""; FAIL=1; }
done

# b) Verify -u chrony present in OPTIONS
grep -Eq '^\s*OPTIONS=.*\B-u[[:space:]]+chrony\b' ""$SYSCONF"" \
  || { echo ""FAIL: /etc/sysconfig/chronyd missing '-u chrony' in OPTIONS""; FAIL=1; }

# c) Service enabled and active
systemctl is-enabled ""$SERVICE"" >/dev/null 2>&1 \
  || { echo ""FAIL: ${SERVICE} not enabled""; FAIL=1; }
systemctl is-active ""$SERVICE"" >/dev/null 2>&1 \
  || { echo ""FAIL: ${SERVICE} not active""; FAIL=1; }

# d) chronyc tracking works (indicates client is functional)
if command -v chronyc >/dev/null 2>&1; then
  chronyc tracking >/dev/null 2>&1 || { echo ""FAIL: 'chronyc tracking' failed""; FAIL=1; }
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: chrony configured and running (CIS 2.2.1.2)""
  exit 0
else
  exit 1
fi"
