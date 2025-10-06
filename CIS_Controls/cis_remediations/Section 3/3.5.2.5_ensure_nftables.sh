"#!/usr/bin/env bash
# 3.5.2.5 Ensure an nftables table exists (CIS Oracle Linux 7)
# Behavior:
#   - Creates a runtime table in the inet family if missing.
#   - Ensures persistence by declaring the table in /etc/sysconfig/nftables.conf.
#   - Does NOT enable/start the nftables service (service state handled in later controls).
#
# Customize table name via env var: NFT_TABLE=<name> (default: filter)
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.5""
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

runtime_create_table() {
  # Create inet table if not present
  if nft list table inet ""$TABLE"" >/dev/null 2>&1; then
    return 0
  fi
  nft create table inet ""$TABLE"" >/dev/null
}

persist_table_declaration() {
  # Ensure configuration file declares the table (minimal, non-intrusive)
  ensure_dir ""$(dirname ""$CONF"")""
  touch ""$CONF""
  chmod 0644 ""$CONF""
  backup_file ""$CONF""

  # If declaration already present (any content inside braces accepted), keep as-is
  if grep -Eq ""^[[:space:]]*table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF""; then
    return 0
  fi

  # Append minimal empty table declaration
  {
    echo """"
    echo ""# Added by ${CONTROL_ID} on $(date -u +'%Y-%m-%dT%H:%M:%SZ')""
    echo ""table inet ${TABLE} { }""
  } >> ""$CONF""
}

verify_runtime() {
  nft list table inet ""$TABLE"" >/dev/null 2>&1
}

verify_persistence() {
  grep -Eq ""^[[:space:]]*table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF""
}

main() {
  require_root
  ensure_nft_installed

  runtime_create_table
  persist_table_declaration

  FAIL=0
  verify_runtime || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: nftables table 'inet ${TABLE}' exists (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables table 'inet ${TABLE}' not fully ensured (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
