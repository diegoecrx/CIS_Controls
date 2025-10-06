"#!/usr/bin/env bash
# CIS 2.2.1.3 - Ensure ntp is configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION_BALANCED=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Behavior (set via env vars before running):
#  - CIS_NTP_SOURCES: comma-separated NTP 'server' or 'pool' lines to ensure present.
#       Example: 'server time.google.com iburst,server time.cloudflare.com iburst'
#       Default: 'pool 2.pool.ntp.org iburst'
#  - CIS_NTP_CONF: path to ntp.conf (default /etc/ntp.conf)
#  - CIS_NTPD_SYSCONF: path to sysconfig file (default /etc/sysconfig/ntpd)

CIS_NTP_SOURCES=""${CIS_NTP_SOURCES:-pool 2.pool.ntp.org iburst}""
NTP_CONF=""${CIS_NTP_CONF:-/etc/ntp.conf}""
SYSCONF=""${CIS_NTPD_SYSCONF:-/etc/sysconfig/ntpd}""
SERVICE=""ntpd""
TS=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure ntp is installed
if ! rpm -q ntp >/dev/null 2>&1; then
  yum -y install ntp >/dev/null
fi

# 3) Ensure config files exist and are backed up (timestamped), with secure perms
if [[ ! -f ""$NTP_CONF"" ]]; then
  install -m 0644 -o root -g root /dev/null ""$NTP_CONF""
fi
cp -p ""$NTP_CONF"" ""${NTP_CONF}.bak.${TS}""

if [[ ! -f ""$SYSCONF"" ]]; then
  install -m 0644 -o root -g root /dev/null ""$SYSCONF""
fi
cp -p ""$SYSCONF"" ""${SYSCONF}.bak.${TS}""

# 4) Enforce secure restrict defaults in ntp.conf
#    - Replace any existing ""restrict -4 default ..."" and ""restrict -6 default ..."" lines.
ensure_restrict_line() {
  local ipver=""$1""   # -4 or -6
  local desired=""restrict ${ipver} default kod nomodify notrap nopeer noquery""
  if grep -qE ""^[[:space:]]*restrict[[:space:]]+\\${ipver}[[:space:]]+default\\b"" ""$NTP_CONF""; then
    sed -ri ""s|^[[:space:]]*restrict[[:space:]]+\\${ipver}[[:space:]]+default\\b.*$|${desired}|"" ""$NTP_CONF""
  else
    printf ""%s\n"" ""${desired}"" >> ""$NTP_CONF""
  fi
}
ensure_restrict_line ""-4""
ensure_restrict_line ""-6""

# 5) Ensure at least the requested server/pool lines are present (append if missing; leave others intact)
IFS=',' read -r -a SOURCES <<< ""$CIS_NTP_SOURCES""
for src in ""${SOURCES[@]}""; do
  src=""$(echo ""$src"" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')""
  [[ -z ""$src"" ]] && continue
  # Escape for grep
  esc=""$(printf '%s' ""$src"" | sed 's/[^^$.*+?()[\]{}|/]/\\&/g')""
  if ! grep -Eq ""^[[:space:]]*${esc}[[:space:]]*$"" ""$NTP_CONF""; then
    echo ""$src"" >> ""$NTP_CONF""
  end_if=true
  fi
done

# 6) Ensure ntpd runs as ntp:ntp via '-u ntp:ntp' in /etc/sysconfig/ntpd OPTIONS
if grep -qE '^\s*OPTIONS=' ""$SYSCONF""; then
  if ! grep -qE '^\s*OPTIONS=.*\B-u[[:space:]]+ntp:ntp\b' ""$SYSCONF""; then
    # Insert -u ntp:ntp before closing quote if quoted; otherwise wrap and append
    sed -ri 's/^(\s*OPTIONS="")(.*)(""\s*)$/\1\2 -u ntp:ntp\3/; t; s/^(\s*OPTIONS=)(.*)$/\1""\2 -u ntp:ntp""/' ""$SYSCONF""
  fi
else
  echo 'OPTIONS=""-u ntp:ntp""' >> ""$SYSCONF""
fi

# 7) Harden perms
chown root:root ""$NTP_CONF"" ""$SYSCONF""
chmod 0644 ""$NTP_CONF"" ""$SYSCONF""

# 8) Enable and start ntpd
systemctl daemon-reload >/dev/null
systemctl enable ""$SERVICE"" >/dev/null
systemctl restart ""$SERVICE"" >/dev/null || true

# 9) Verification (runtime + persistence)
FAIL=0

# a) Restrict lines exact
grep -Eq '^[[:space:]]*restrict[[:space:]]+-4[[:space:]]+default[[:space:]]+kod[[:space:]]+nomodify[[:space:]]+notrap[[:space:]]+nopeer[[:space:]]+noquery[[:space:]]*$' ""$NTP_CONF"" \
  || { echo ""FAIL: Missing/incorrect IPv4 restrict line in $NTP_CONF""; FAIL=1; }
grep -Eq '^[[:space:]]*restrict[[:space:]]+-6[[:space:]]+default[[:space:]]+kod[[:space:]]+nomodify[[:space:]]+notrap[[:space:]]+nopeer[[:space:]]+noquery[[:space:]]*$' ""$NTP_CONF"" \
  || { echo ""FAIL: Missing/incorrect IPv6 restrict line in $NTP_CONF""; FAIL=1; }

# b) At least one server/pool line exists
if ! grep -Eq '^[[:space:]]*(server|pool)[[:space:]]+' ""$NTP_CONF""; then
  echo ""FAIL: No NTP server/pool lines found in $NTP_CONF""
  FAIL=1
fi

# c) OPTIONS contains -u ntp:ntp
grep -Eq '^\s*OPTIONS=.*\B-u[[:space:]]+ntp:ntp\b' ""$SYSCONF"" \
  || { echo ""FAIL: /etc/sysconfig/ntpd missing '-u ntp:ntp' in OPTIONS""; FAIL=1; }

# d) Service enabled and active
systemctl is-enabled ""$SERVICE"" >/dev/null 2>&1 \
  || { echo ""FAIL: ${SERVICE} not enabled""; FAIL=1; }
systemctl is-active ""$SERVICE"" >/dev/null 2>&1 \
  || { echo ""FAIL: ${SERVICE} not active""; FAIL=1; }

# e) Optional: confirm peers reachable (do not hard-fail if absent)
if command -v ntpq >/dev/null 2>&1; then
  ntpq -pn >/dev/null 2>&1 || echo ""NOTE: 'ntpq -pn' did not return peers (may be transient)""
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: ntp configured and running (CIS 2.2.1.3)""
  exit 0
else
  exit 1
fi"
