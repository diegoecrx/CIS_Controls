"#!/usr/bin/env bash
# 3.5.2.9 Ensure nftables default deny firewall policy (CIS Oracle Linux 7)
# Enforces: policy drop on inet <TABLE> base chains: input, forward, output
#   Example runtime operations:
#     nft chain inet filter input   { policy drop ; }
#     nft chain inet filter forward { policy drop ; }
#     nft chain inet filter output  { policy drop ; }
# Persistence: ensure /etc/sysconfig/nftables.conf declares chains with policy drop.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.9""
TABLE=""${NFT_TABLE:-filter}""
CONF=""/etc/sysconfig/nftables.conf""

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
  if [[ -f ""$f"" ]]; then
    cp -a --preserve=all ""$f"" ""${f}.bak.$(timestamp)""
  fi
}

ensure_dir() {
  local d=""$1"" m=""${2:-0755}""
  install -d -m ""$m"" ""$d""
}

ensure_nft_installed() {
  if ! have_bin nft; then
    echo ""FAIL: nft command not found. Install 'nftables' first (see CIS 3.5.2.1) (${CONTROL_ID})""
    exit 1
  fi
}

runtime_ensure_table() {
  nft list table inet ""$TABLE"" >/dev/null 2>&1 || nft create table inet ""$TABLE"" >/dev/null
}

runtime_ensure_chain_with_hook() {
  # $1 = chain, $2 = hook (input|forward|output)
  local CH=""$1"" HK=""$2""
  if nft list chain inet ""$TABLE"" ""$CH"" >/dev/null 2>&1; then
    if ! nft list chain inet ""$TABLE"" ""$CH"" 2>/dev/null | grep -qE ""hook[[:space:]]+${HK}[[:space:]]+priority[[:space:]]+0""; then
      nft delete chain inet ""$TABLE"" ""$CH"" >/dev/null 2>&1 || true
      nft create chain inet ""$TABLE"" ""$CH"" ""{ type filter hook ${HK} priority 0 ; }"" >/dev/null
    fi
  else
    nft create chain inet ""$TABLE"" ""$CH"" ""{ type filter hook ${HK} priority 0 ; }"" >/dev/null
  fi
}

runtime_set_policy_drop() {
  local CH
  for CH in input forward output; do
    # Set policy drop (idempotent)
    nft chain inet ""$TABLE"" ""$CH"" ""{ policy drop ; }"" >/dev/null
  done
}

persist_ensure_policy_drop() {
  ensure_dir ""$(dirname ""$CONF"")""
  touch ""$CONF""; chmod 0644 ""$CONF""
  backup_file ""$CONF""

  # If table block or chains with policy drop not present, append a minimal, safe fragment.
  local need_append=0
  grep -Eq ""^[[:space:]]*table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || need_append=1
  for pair in ""input input"" ""forward forward"" ""output output""; do
    set -- $pair
    local CH=""$1"" HK=""$2""
    grep -Eq ""chain[[:space:]]+${CH}[[:space:]]*\{[^{]*hook[[:space:]]+${HK}[[:space:]]+priority[[:space:]]+0[[:space:]]*;[[:space:]]*policy[[:space:]]+drop"" ""$CONF"" || need_append=1
  done

  if [[ $need_append -eq 1 ]]; then
    {
      echo """"
      echo ""# ${CONTROL_ID} - default deny policies, added on $(date -u +'%Y-%m-%dT%H:%M:%SZ')""
      echo ""table inet ${TABLE} {""
      echo ""  chain input   { type filter hook input   priority 0 ; policy drop ; }""
      echo ""  chain forward { type filter hook forward priority 0 ; policy drop ; }""
      echo ""  chain output  { type filter hook output  priority 0 ; policy drop ; }""
      echo ""}""
    } >> ""$CONF""
  fi
}

verify_runtime() {
  local ok=1
  nft list table inet ""$TABLE"" >/dev/null 2>&1 || ok=0
  for pair in ""input input"" ""forward forward"" ""output output""; do
    set -- $pair
    local CH=""$1"" HK=""$2""
    nft list chain inet ""$TABLE"" ""$CH"" >/dev/null 2>&1 || ok=0
    nft list chain inet ""$TABLE"" ""$CH"" 2>/dev/null | grep -qE ""hook[[:space:]]+${HK}[[:space:]]+priority[[:space:]]+0"" || ok=0
    nft list chain inet ""$TABLE"" ""$CH"" 2>/dev/null | grep -qE ""policy[[:space:]]+drop"" || ok=0
  done
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$CONF"" ]] || ok=0
  grep -Eq ""^[[:space:]]*table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+input[[:space:]]*\{[^{]*hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0[[:space:]]*;[[:space:]]*policy[[:space:]]+drop"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+forward[[:space:]]*\{[^{]*hook[[:space:]]+forward[[:space:]]+priority[[:space:]]+0[[:space:]]*;[[:space:]]*policy[[:space:]]+drop"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+output[[:space:]]*\{[^{]*hook[[:space:]]+output[[:space:]]+priority[[:space:]]+0[[:space:]]*;[[:space:]]*policy[[:space:]]+drop"" ""$CONF"" || ok=0
  return $ok
}

main() {
  require_root
  ensure_nft_installed

  # Ensure table and base chains exist (input/forward/output with correct hooks)
  runtime_ensure_table
  runtime_ensure_chain_with_hook input   input
  runtime_ensure_chain_with_hook forward forward
  runtime_ensure_chain_with_hook output  output

  # Set default policies to DROP
  runtime_set_policy_drop

  # Persist configuration
  persist_ensure_policy_drop

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: nftables default deny (policy drop) set on input/forward/output (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables default deny policy not fully enforced (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
