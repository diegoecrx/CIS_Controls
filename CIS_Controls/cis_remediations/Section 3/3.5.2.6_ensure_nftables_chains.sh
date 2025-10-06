"#!/usr/bin/env bash
# 3.5.2.6 Ensure nftables base chains exist (CIS Oracle Linux 7)
# Creates base chains in inet table with: type filter hook <input|forward|output> priority 0 ;
# Runtime: create table/chains if missing.
# Persistence: ensure /etc/sysconfig/nftables.conf declares the same table and chains.
#
# Customize table name via env: NFT_TABLE=<name>   (default: filter)
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.6""
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
  if ! nft list table inet ""$TABLE"" >/dev/null 2>&1; then
    nft create table inet ""$TABLE"" >/dev/null
  fi
}

runtime_ensure_chain() {
  # $1 = chain name, $2 = hook (input|forward|output)
  local CH=""$1"" HK=""$2""
  if nft list chain inet ""$TABLE"" ""$CH"" >/dev/null 2>&1; then
    # Chain exists. If it already has the desired hook/type/priority, nothing to do.
    if nft list chain inet ""$TABLE"" ""$CH"" 2>/dev/null | grep -qE ""hook[[:space:]]+${HK}[[:space:]]+priority[[:space:]]+0""; then
      return 0
    fi
    # If properties differ, attempt a safe replace (works if kernel supports it); otherwise leave and verify will fail.
    nft delete chain inet ""$TABLE"" ""$CH"" >/dev/null 2>&1 || true
  fi
  # (Re)create with required properties
  nft create chain inet ""$TABLE"" ""$CH"" ""{ type filter hook ${HK} priority 0 ; }"" >/dev/null
}

persist_ensure_table_block() {
  ensure_dir ""$(dirname ""$CONF"")""
  touch ""$CONF""
  chmod 0644 ""$CONF""
  backup_file ""$CONF""

  # Ensure table declaration exists (minimal block). If already present, keep.
  if ! grep -Eq ""^[[:space:]]*table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF""; then
    {
      echo """"
      echo ""# Added by ${CONTROL_ID} on $(date -u +'%Y-%m-%dT%H:%M:%SZ')""
      echo ""table inet ${TABLE} { }""
    } >> ""$CONF""
  fi
}

persist_ensure_chain() {
  # Add (or ensure) a base chain declaration inside table block.
  # $1 = chain name, $2 = hook
  local CH=""$1"" HK=""$2""

  # If chain declaration with the correct hook already exists, nothing to do.
  if grep -Eq ""^[[:space:]]*chain[[:space:]]+${CH}[[:space:]]*\{[[:space:]]*type[[:space:]]+filter[[:space:]]+hook[[:space:]]+${HK}[[:space:]]+priority[[:space:]]+0[[:space:]]*;[[:space:]]*\}"" ""$CONF""; then
    return 0
  fi

  # Ensure we add the chain inside the table block. Simplest: append a full table override fragment.
  # This is safe because nft will merge/override by last declaration when loading the file.
  {
    echo """"
    echo ""# ${CONTROL_ID}: ensure base chain ${CH} (hook ${HK})""
    echo ""table inet ${TABLE} {""
    echo ""  chain ${CH} { type filter hook ${HK} priority 0 ; }""
    echo ""}""
  } >> ""$CONF""
}

verify_runtime() {
  local ok=1
  nft list table inet ""$TABLE"" >/dev/null 2>&1 || ok=0
  for pair in ""input input"" ""forward forward"" ""output output""; do
    set -- $pair
    local CH=""$1"" HK=""$2""
    if ! nft list chain inet ""$TABLE"" ""$CH"" >/dev/null 2>&1; then ok=0; continue; fi
    nft list chain inet ""$TABLE"" ""$CH"" 2>/dev/null | grep -qE ""hook[[:space:]]+${HK}[[:space:]]+priority[[:space:]]+0"" || ok=0
  done
  return $ok
}

verify_persistence() {
  local ok=1
  grep -Eq ""^[[:space:]]*table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+input[[:space:]]*\{[^{]*hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+forward[[:space:]]*\{[^{]*hook[[:space:]]+forward[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+output[[:space:]]*\{[^{]*hook[[:space:]]+output[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || ok=0
  return $ok
}

main() {
  require_root
  ensure_nft_installed

  # Runtime ensure
  runtime_ensure_table
  runtime_ensure_chain input   input
  runtime_ensure_chain forward forward
  runtime_ensure_chain output  output

  # Persistence ensure
  persist_ensure_table_block
  persist_ensure_chain input   input
  persist_ensure_chain forward forward
  persist_ensure_chain output  output

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: nftables base chains exist in 'inet ${TABLE}' (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables base chains not fully ensured for 'inet ${TABLE}' (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
