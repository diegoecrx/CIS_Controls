"#!/usr/bin/env bash
# CIS 2.2.16 - Ensure mail transfer agent is configured for local-only mode (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1
#
# Behavior (env vars):
#  - CIS_MTA_IFACES: desired Postfix inet_interfaces value. Default ""loopback-only""
#       Valid examples: ""loopback-only"" | ""localhost"" | ""127.0.0.1""
#       CIS benchmark example uses ""loopback-only"".

set -euo pipefail

CIS_MTA_IFACES=""${CIS_MTA_IFACES:-loopback-only}""

POSTFIX_PKG=""postfix""
POSTFIX_SVC=""postfix.service""
POSTFIX_MAIN=""/etc/postfix/main.cf""
TS=""$(date +%Y%m%d%H%M%S)""

# ---------- 1) Root check ----------
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# ---------- 2) If Postfix is installed, enforce local-only config ----------
if rpm -q ""$POSTFIX_PKG"" >/dev/null 2>&1; then
  # Ensure config exists, perms, and backup
  if [[ ! -f ""$POSTFIX_MAIN"" ]]; then
    install -m 0644 -o root -g root /dev/null ""$POSTFIX_MAIN""
  fi
  cp -p ""$POSTFIX_MAIN"" ""${POSTFIX_MAIN}.bak.${TS}""

  # Normalize any existing inet_interfaces line; then enforce desired value
  if grep -qE '^[[:space:]]*inet_interfaces[[:space:]]*=' ""$POSTFIX_MAIN""; then
    sed -ri ""s|^[[:space:]]*inet_interfaces[[:space:]]*=.*$|inet_interfaces = ${CIS_MTA_IFACES}|"" ""$POSTFIX_MAIN""
  else
    {
      echo """"
      echo ""# CIS 2.2.16 - Limit Postfix to loopback""
      echo ""inet_interfaces = ${CIS_MTA_IFACES}""
    } >> ""$POSTFIX_MAIN""
  fi

  chown root:root ""$POSTFIX_MAIN""
  chmod 0644 ""$POSTFIX_MAIN""

  # Restart Postfix to apply change (as per control)
  systemctl daemon-reload >/dev/null || true
  if systemctl list-unit-files | grep -qE ""^${POSTFIX_SVC}""; then
    systemctl restart ""$POSTFIX_SVC"" >/dev/null || true
  fi
fi

# ---------- 3) Verification (runtime + persistence) ----------
FAIL=0

# Helper: confirm all SMTP listeners (if any) are bound only to loopback
only_loopback_smtp() {
  # Collect all local addresses bound to TCP 25
  mapfile -t listeners < <(ss -ltn 2>/dev/null | awk '$1==""LISTEN"" && $4 ~ /(:|\.)(25)$/ {print $4}')
  # If none listening, it's acceptable for ""local-only"" intent
  ((${#listeners[@]}==0)) && return 0

  # Validate each is loopback only (127.0.0.1 or ::1)
  local ok=1
  for addr in ""${listeners[@]}""; do
    # Extract IP portion (handles [::1]:25, ::1:25, 127.0.0.1:25, 0.0.0.0:25, *:25)
    ip=""${addr%:*}""
    # Normalize brackets
    ip=""${ip#[}""
    ip=""${ip%]}""
    case ""$ip"" in
      127.0.0.1|::1|localhost) : ;;
      # Some ss formats show *:25 or 0.0.0.0:25 => not loopback
      *|0.0.0.0|::) ok=0 ;;
    esac
  done
  [[ $ok -eq 1 ]]
}

# a) If Postfix installed, verify postconf reports the desired setting
if rpm -q ""$POSTFIX_PKG"" >/dev/null 2>&1; then
  if command -v postconf >/dev/null 2>&1; then
    if ! postconf -n inet_interfaces 2>/dev/null | awk -F'= ' '{print $2}' | grep -qx ""${CIS_MTA_IFACES}""; then
      echo ""FAIL: Postfix inet_interfaces is not '${CIS_MTA_IFACES}'""
      FAIL=1
    fi
  else
    # Fallback: parse file if postconf not available
    grep -Eq ""^[[:space:]]*inet_interfaces[[:space:]]*=[[:space:]]*${CIS_MTA_IFACES}[[:space:]]*$"" ""$POSTFIX_MAIN"" \
      || { echo ""FAIL: $POSTFIX_MAIN does not set inet_interfaces=${CIS_MTA_IFACES}""; FAIL=1; }
  fi
fi

# b) Verify runtime listeners (if any) are loopback-only
only_loopback_smtp || { echo ""FAIL: SMTP is listening on a non-loopback address""; FAIL=1; }

# c) If no MTA installed, that's acceptable as long as nothing listens externally on 25
if ! rpm -q ""$POSTFIX_PKG"" >/dev/null 2>&1; then
  # Additionally warn if another MTA seems active externally
  if ss -ltn 2>/dev/null | awk '$1==""LISTEN"" && $4 ~ /(:|\.)(25)$/' | grep -vqE '(\[::1\]:25|127\.0\.0\.1:25)'; then
    echo ""FAIL: Another service is listening on SMTP port 25 on non-loopback""
    FAIL=1
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: MTA configured for local-only (CIS 2.2.16)""
  exit 0
else
  exit 1
fi"
