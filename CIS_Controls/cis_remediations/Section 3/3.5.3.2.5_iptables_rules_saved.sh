#!/usr/bin/env bash
# 3.5.3.2.5 Ensure iptables rules are saved (CIS Oracle Linux 7)
# Saves current IPv4 rules to /etc/sysconfig/iptables using iptables-save (preferred).
# If available, also attempts 'service iptables save'. Verifies persistence file integrity.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.5.3.2.5"
PERSIST_FILE="/etc/sysconfig/iptables"

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

save_rules_with_iptables_save() {
  ensure_dir "$(dirname "$PERSIST_FILE")"
  backup_file "$PERSIST_FILE"
  iptables-save > "$PERSIST_FILE"
  chmod 0600 "$PERSIST_FILE"
}

try_service_save() {
  # Best-effort: some environments prefer 'service iptables save'
  if have service; then
    service iptables save >/dev/null 2>&1 || true
  fi
}

verify_persistence_basic() {
  # Basic integrity: file exists, non-empty, contains base chain policies
  [[ -s "$PERSIST_FILE" ]] || return 1
  grep -qE '^:INPUT[[:space:]]+(ACCEPT|DROP|REJECT)\b'   "$PERSIST_FILE" || return 1
  grep -qE '^:OUTPUT[[:space:]]+(ACCEPT|DROP|REJECT)\b'  "$PERSIST_FILE" || return 1
  grep -qE '^:FORWARD[[:space:]]+(ACCEPT|DROP|REJECT)\b' "$PERSIST_FILE" || return 1
  return 0
}

verify_runtime_matches_file() {
  # Compare current rules vs saved, ignoring byte/packet counters
  local tmp; tmp="$(mktemp)"
  iptables-save | sed -E 's/\[[0-9]+:[0-9]+\]//g' > "$tmp"
  sed -E 's/\[[0-9]+:[0-9]+\]//g' "$PERSIST_FILE" | diff -q - "$tmp" >/dev/null 2>&1 || {
    rm -f "$tmp"
    return 1
  }
  rm -f "$tmp"
  return 0
}

main() {
  require_root

  # Preconditions
  if ! have iptables || ! have iptables-save; then
    echo "FAIL: iptables/iptables-save not found (install iptables & iptables-services) (${CONTROL_ID})"
    exit 1
  fi

  # Save rules (iptables-save is authoritative); also try service save for compatibility
  save_rules_with_iptables_save
  try_service_save

  FAIL=0
  verify_persistence_basic || FAIL=1
  verify_runtime_matches_file || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: iptables rules saved to ${PERSIST_FILE} (runtime snapshot persisted) (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: iptables rules not correctly saved to ${PERSIST_FILE} (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"
