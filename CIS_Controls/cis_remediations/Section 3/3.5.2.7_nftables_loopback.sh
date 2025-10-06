"#!/usr/bin/env bash
# 3.5.2.7 Ensure nftables loopback traffic is configured (CIS Oracle Linux 7)
# Runtime rules to ensure:
#   nft add rule inet filter input iif lo accept
#   nft add rule inet filter input ip saddr 127.0.0.0/8 counter drop
#   (if IPv6 enabled)
#   nft add rule inet filter input ip6 saddr ::1 counter drop
#
# Persistence:
#   - Ensures /etc/sysconfig/nftables.conf contains equivalent rules.
#   - Does not start/enable the nftables service (handled by other controls).
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.7""
TABLE=""${NFT_TABLE:-filter}""               # inet table name
CHAIN=""input""                              # base chain name (hook input)
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

ipv6_is_disabled() {
  # Consider IPv6 disabled if proc path missing, sysctl set, or kernel arg present
  if [[ ! -d /proc/sys/net/ipv6 ]]; then return 0; fi
  local v
  v=""$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo 0)""
  if [[ ""$v"" == ""1"" ]]; then return 0; fi
  grep -qw 'ipv6.disable=1' /proc/cmdline 2>/dev/null && return 0
  return 1
}

ensure_nft_installed() {
  if ! have_bin nft; then
    echo ""FAIL: nft command not found. Install 'nftables' first (see CIS 3.5.2.1) (${CONTROL_ID})""
    exit 1
  fi
}

runtime_ensure_table_chain() {
  # Ensure inet table exists
  nft list table inet ""$TABLE"" >/dev/null 2>&1 || nft create table inet ""$TABLE"" >/dev/null
  # Ensure input base chain with correct hook exists
  if nft list chain inet ""$TABLE"" ""$CHAIN"" >/dev/null 2>&1; then
    if ! nft list chain inet ""$TABLE"" ""$CHAIN"" 2>/dev/null | grep -qE ""hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0""; then
      nft delete chain inet ""$TABLE"" ""$CHAIN"" >/dev/null 2>&1 || true
      nft create chain inet ""$TABLE"" ""$CHAIN"" ""{ type filter hook input priority 0 ; }"" >/dev/null
    fi
  else
    nft create chain inet ""$TABLE"" ""$CHAIN"" ""{ type filter hook input priority 0 ; }"" >/dev/null
  fi
}

rule_present() {
  # $1 is a grep pattern to find within the chain listing
  nft list chain inet ""$TABLE"" ""$CHAIN"" 2>/dev/null | grep -qE ""$1""
}

runtime_ensure_rules() {
  # Accept loopback
  rule_present 'iif[[:space:]]+lo[[:space:]]+accept' || nft add rule inet ""$TABLE"" ""$CHAIN"" iif lo accept >/dev/null
  # Drop IPv4 with 127/8 as source on non-lo
  rule_present 'ip[[:space:]]+saddr[[:space:]]+127\.0\.0\.0/8.*drop' || nft add rule inet ""$TABLE"" ""$CHAIN"" ip saddr 127.0.0.0/8 counter drop >/dev/null
  # Drop IPv6 ::1 source on non-lo (only if IPv6 enabled)
  if ! ipv6_is_disabled; then
    rule_present 'ip6[[:space:]]+saddr[[:space:]]+::1.*drop' || nft add rule inet ""$TABLE"" ""$CHAIN"" ip6 saddr ::1 counter drop >/dev/null
  fi
}

persist_rules() {
  ensure_dir ""$(dirname ""$CONF"")""
  touch ""$CONF""; chmod 0644 ""$CONF""
  backup_file ""$CONF""

  # Append only if corresponding lines are not already present
  need_append=0
  grep -Eq ""table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || need_append=1
  grep -Eq ""chain[[:space:]]+${CHAIN}.*hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || need_append=1
  grep -Eq ""iif[[:space:]]+lo[[:space:]]+accept"" ""$CONF"" || need_append=1
  grep -Eq ""ip[[:space:]]+saddr[[:space:]]+127\.0\.0\.0/8.*drop"" ""$CONF"" || need_append=1
  if ! ipv6_is_disabled; then
    grep -Eq ""ip6[[:space:]]+saddr[[:space:]]+::1.*drop"" ""$CONF"" || need_append=1
  fi

  if [[ $need_append -eq 1 ]]; then
    {
      echo """"
      echo ""# ${CONTROL_ID} - loopback rules, added on $(date -u +'%Y-%m-%dT%H:%M:%SZ')""
      echo ""table inet ${TABLE} {""
      echo ""  chain ${CHAIN} { type filter hook input priority 0 ;""
      echo ""    iif lo accept""
      echo ""    ip saddr 127.0.0.0/8 counter drop""
      if ! ipv6_is_disabled; then
        echo ""    ip6 saddr ::1 counter drop""
      fi
      echo ""  }""
      echo ""}""
    } >> ""$CONF""
  fi
}

verify_runtime() {
  local ok=1
  nft list chain inet ""$TABLE"" ""$CHAIN"" >/dev/null 2>&1 || ok=0
  rule_present 'iif[[:space:]]+lo[[:space:]]+accept' || ok=0
  rule_present 'ip[[:space:]]+saddr[[:space:]]+127\.0\.0\.0/8.*drop' || ok=0
  if ! ipv6_is_disabled; then
    rule_present 'ip6[[:space:]]+saddr[[:space:]]+::1.*drop' || ok=0
  fi
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$CONF"" ]] || ok=0
  grep -Eq ""table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+${CHAIN}.*hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || ok=0
  grep -Eq ""iif[[:space:]]+lo[[:space:]]+accept"" ""$CONF"" || ok=0
  grep -Eq ""ip[[:space:]]+saddr[[:space:]]+127\.0\.0\.0/8.*drop"" ""$CONF"" || ok=0
  if ! ipv6_is_disabled; then
    grep -Eq ""ip6[[:space:]]+saddr[[:space:]]+::1.*drop"" ""$CONF"" || ok=0
  fi
  return $ok
}

main() {
  require_root
  ensure_nft_installed

  runtime_ensure_table_chain
  runtime_ensure_rules
  persist_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: nftables loopback traffic configured (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables loopback rules not fully ensured (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
