"#!/usr/bin/env bash
# 3.5.3.2.1 Ensure iptables loopback traffic is configured (CIS Oracle Linux 7)
# Runtime rules to ensure:
#   iptables -A INPUT  -i lo -j ACCEPT
#   iptables -A OUTPUT -o lo -j ACCEPT
#   iptables -A INPUT  -s 127.0.0.0/8 -j DROP
#
# Persistence:
#   - Saves current runtime rules to /etc/sysconfig/iptables (iptables-services format).
#   - Does not start/enable services here (covered by other controls).
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.3.2.1""
PERSIST_FILE=""/etc/sysconfig/iptables""

timestamp() { date +""%Y%m%d-%H%M%S""; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

have_bin() { command -v ""$1"" >/dev/null 2>&1; }

backup_file() {
  local f=""$1""
  [[ -f ""$f"" ]] || return 0
  cp -a --preserve=all ""$f"" ""${f}.bak.$(timestamp)""
}

ensure_dir() {
  local d=""$1"" m=""${2:-0755}""
  install -d -m ""$m"" ""$d""
}

rule_present() {
  # $@ = iptables rule spec after chain (e.g., ""INPUT -i lo -j ACCEPT"")
  iptables -C ""$@"" >/dev/null 2>&1
}

insert_rule_top() {
  # Insert at top to give loopback/safety rules precedence if missing
  # $1=CHAIN, remaining = rule spec (without -A/-I)
  local chain=""$1""; shift
  iptables -I ""$chain"" 1 ""$@"" >/dev/null
}

append_rule() {
  local chain=""$1""; shift
  iptables -A ""$chain"" ""$@"" >/dev/null
}

apply_runtime() {
  # Accept loopback (INPUT/OUTPUT) — ensure present; insert near top for INPUT, append for OUTPUT
  rule_present INPUT -i lo -j ACCEPT || insert_rule_top INPUT -i lo -j ACCEPT
  rule_present OUTPUT -o lo -j ACCEPT || append_rule OUTPUT -o lo -j ACCEPT

  # Drop spoofed 127/8 arriving on non-loopback — place near top of INPUT
  rule_present INPUT -s 127.0.0.0/8 -j DROP || insert_rule_top INPUT -s 127.0.0.0/8 -j DROP
}

persist_runtime_rules() {
  ensure_dir ""$(dirname ""$PERSIST_FILE"")""
  backup_file ""$PERSIST_FILE""
  # Save the entire current IPv4 ruleset (authoritative persistence snapshot)
  if have_bin iptables-save; then
    iptables-save > ""$PERSIST_FILE""
    chmod 0600 ""$PERSIST_FILE""
  else
    echo ""FAIL: iptables-save not found; cannot persist rules (${CONTROL_ID})""
    exit 1
  fi
}

verify_runtime() {
  local ok=1
  rule_present INPUT  -i lo -j ACCEPT || ok=0
  rule_present OUTPUT -o lo -j ACCEPT || ok=0
  rule_present INPUT  -s 127.0.0.0/8 -j DROP || ok=0
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$PERSIST_FILE"" ]] || ok=0
  grep -Eq '^-A INPUT -i lo -j ACCEPT\b' ""$PERSIST_FILE""   || ok=0
  grep -Eq '^-A OUTPUT -o lo -j ACCEPT\b' ""$PERSIST_FILE""  || ok=0
  grep -Eq '^-A INPUT -s 127\.0\.0\.0/8 -j DROP\b' ""$PERSIST_FILE"" || ok=0
  return $ok
}

main() {
  require_root

  if ! have_bin iptables; then
    echo ""FAIL: iptables not found. Install iptables/iptables-services first (see CIS 3.5.3.1.1) (${CONTROL_ID})""
    exit 1
  fi

  apply_runtime
  persist_runtime_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: iptables loopback rules configured (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: iptables loopback rules not fully ensured (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
