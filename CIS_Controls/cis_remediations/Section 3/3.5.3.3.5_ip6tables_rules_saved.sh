#!/usr/bin/env bash
# 3.5.3.3.5 Ensure ip6tables rules are saved (CIS Oracle Linux 7)
# Saves current IPv6 rules to /etc/sysconfig/ip6tables using ip6tables-save (authoritative).
# Also attempts 'service ip6tables save' for compatibility. Verifies persistence file integrity.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.5.3.3.5"
PERSIST_FILE="/etc/sysconfig/ip6tables"

timestamp() { date +"%Y%m%d-%H%M%S"; }

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "FAIL: Must run as root (${CONTROL_ID})"
    exit 1
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

backup_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  cp -a --preserve=all "$f" "${f}.bak.$(timestamp)"
}

ensure_dir() {
  local d="$1" m="${2:-0755}"
  install -d -m "$m" "$d"
}

save_rules_with_ip6tables_save() {
  ensure_dir "$(dirname "$PERSIST_FILE")"
  backup_file "$PERSIST_FILE"
  ip6tables-save > "$PERSIST_FILE"
  chmod 0600 "$PERSIST_FILE"
}

try_service_save() {
  # Best-effort: some environments use legacy service helper
  if have service; then
    service ip6tables save >/dev/null 2>&1 || true
  fi
}

verify_persistence_basic() {
  # File exists, non-empty, and declares base chain policies
  [[ -s "$PERSIST_FILE" ]] || return 1
  grep -qE '^:INPUT[[:space:]]+(ACCEPT|DROP|REJECT)\b'   "$PERSIST_FILE" || return 1
  grep -qE '^:OUTPUT[[:space:]]+(ACCEPT|DROP|REJECT)\b'  "$PERSIST_FILE" || return 1
  grep -qE '^:FORWARD[[:space:]]+(ACCEPT|DROP|REJECT)\b' "$PERSIST_FILE" || return 1
  return 0
}

verify_runtime_matches_file() {
  # Compare current rules vs saved, ignoring packet/byte counters
  local tmp; tmp="$(mktemp)"
  ip6tables-save | sed -E 's/\[[0-9]+:[0-9]+\]//g' > "$tmp"
  sed -E 's/\[[0-9]+:[0-9]+\]//g' "$PERSIST_FILE" | diff -q - "$tmp" >/dev/null 2>&1 || {
    rm -f "$tmp"
    return 1
  }
  rm -f "$tmp"
  return 0
}

main() {
  require_root

  if ! have ip6tables || ! have ip6tables-save; then
    echo "FAIL: ip6tables/ip6tables-save not found (install iptables & iptables-services) (${CONTROL_ID})"
    exit 1
  fi

  # Save rules (ip6tables-save is authoritative); also try service save for compatibility
  save_rules_with_ip6tables_save
  try_service_save

  FAIL=0
  verify_persistence_basic || FAIL=1
  verify_runtime_matches_file || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: ip6tables rules saved to ${PERSIST_FILE} (runtime snapshot persisted) (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: ip6tables rules not correctly saved to ${PERSIST_FILE} (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"
