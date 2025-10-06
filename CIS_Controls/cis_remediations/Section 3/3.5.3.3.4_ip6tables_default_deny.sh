#!/usr/bin/env bash
# 3.5.3.3.4 Ensure ip6tables default deny firewall policy (CIS Oracle Linux 7)
# Enforces:
#   ip6tables -P INPUT DROP
#   ip6tables -P OUTPUT DROP
#   ip6tables -P FORWARD DROP
# Persistence:
#   Saves rules to /etc/sysconfig/ip6tables (iptables-services format).
# NOTE: Ensure allow rules (e.g., loopback, established/outbound) are present to avoid lockout.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.5.3.3.4"
PERSIST_FILE="/etc/sysconfig/ip6tables"

timestamp() { date +"%Y%m%d-%H%M%S"; }

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "FAIL: Must run as root (${CONTROL_ID})"
    exit 1
  fi
}

have_bin() { command -v "$1" >/dev/null 2>&1; }

backup_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  cp -a --preserve=all "$f" "${f}.bak.$(timestamp)"
}

ensure_dir() {
  local d="$1" m="${2:-0755}"
  install -d -m "$m" "$d"
}

set_default_drop() {
  ip6tables -P INPUT DROP    >/dev/null
  ip6tables -P OUTPUT DROP   >/dev/null
  ip6tables -P FORWARD DROP  >/dev/null
}

persist_rules() {
  ensure_dir "$(dirname "$PERSIST_FILE")"
  backup_file "$PERSIST_FILE"
  if have_bin ip6tables-save; then
    ip6tables-save > "$PERSIST_FILE"
    chmod 0600 "$PERSIST_FILE"
  else
    echo "FAIL: ip6tables-save not found; cannot persist IPv6 rules (${CONTROL_ID})"
    exit 1
  fi
}

verify_runtime() {
  local ok=1
  # Expect: -P CHAIN DROP
  ip6tables -S 2>/dev/null | grep -qE '^-P INPUT DROP\b'   || ok=0
  ip6tables -S 2>/dev/null | grep -qE '^-P OUTPUT DROP\b'  || ok=0
  ip6tables -S 2>/dev/null | grep -qE '^-P FORWARD DROP\b' || ok=0
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f "$PERSIST_FILE" ]] || ok=0
  # Expect policy lines like: ":INPUT DROP [0:0]"
  grep -qE '^:INPUT[[:space:]]+DROP\b'   "$PERSIST_FILE" || ok=0
  grep -qE '^:OUTPUT[[:space:]]+DROP\b'  "$PERSIST_FILE" || ok=0
  grep -qE '^:FORWARD[[:space:]]+DROP\b' "$PERSIST_FILE" || ok=0
  return $ok
}

main() {
  require_root

  if ! have_bin ip6tables; then
    echo "FAIL: ip6tables not found. Install iptables/iptables-services first (see CIS 3.5.3.1.1) (${CONTROL_ID})"
    exit 1
  fi

  set_default_drop
  persist_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: ip6tables default deny (DROP) policy set and persisted (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: ip6tables default deny policy not fully enforced (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"
