"#!/usr/bin/env bash
# 3.5.2.8 Ensure nftables outbound and established connections are configured (CIS Oracle Linux 7)
#
# Manual control with Audit + Optional Remediation.
#
# Defaults:
#   - Audit only. Set NFT_APPLY=1 to add rules (runtime + persistence).
#   - Table: inet ""filter"" (override via NFT_TABLE=<name>)
#   - Include IPv6 equivalents if IPv6 enabled (override via NFT_INCLUDE_IPV6=0 to skip)
#
# Rules to ensure (IPv4; IPv6 analogs if enabled):
#   Inbound (input):      established only (tcp/udp/icmp)
#   Outbound (output):    new,related,established (tcp/udp/icmp)
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.8""
APPLY=""${NFT_APPLY:-0}""                  # 0=audit only, 1=apply changes
TABLE=""${NFT_TABLE:-filter}""
CONF=""/etc/sysconfig/nftables.conf""
CHAIN_IN=""input""
CHAIN_OUT=""output""
INCLUDE_IPV6=""${NFT_INCLUDE_IPV6:-1}""

timestamp() { date +""%Y%m%d-%H%M%S""; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

have_bin() { command -v ""$1"" >/dev/null 2>&1; }

ipv6_is_disabled() {
  [[ ""$INCLUDE_IPV6"" == ""0"" ]] && return 0
  if [[ ! -d /proc/sys/net/ipv6 ]]; then return 0; fi
  local v; v=""$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo 0)""
  [[ ""$v"" == ""1"" ]] && return 0
  grep -qw 'ipv6.disable=1' /proc/cmdline 2>/dev/null && return 0
  return 1
}

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

runtime_ensure_table_chains() {
  nft list table inet ""$TABLE"" >/dev/null 2>&1 || nft create table inet ""$TABLE"" >/dev/null
  # input chain
  if nft list chain inet ""$TABLE"" ""$CHAIN_IN"" >/dev/null 2>&1; then
    nft list chain inet ""$TABLE"" ""$CHAIN_IN"" | grep -qE ""hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0"" || {
      nft delete chain inet ""$TABLE"" ""$CHAIN_IN"" >/dev/null 2>&1 || true
      nft create chain inet ""$TABLE"" ""$CHAIN_IN"" ""{ type filter hook input priority 0 ; }"" >/dev/null
    }
  else
    nft create chain inet ""$TABLE"" ""$CHAIN_IN"" ""{ type filter hook input priority 0 ; }"" >/dev/null
  fi
  # output chain
  if nft list chain inet ""$TABLE"" ""$CHAIN_OUT"" >/devnull 2>&1; then
    nft list chain inet ""$TABLE"" ""$CHAIN_OUT"" | grep -qE ""hook[[:space:]]+output[[:space:]]+priority[[:space:]]+0"" || {
      nft delete chain inet ""$TABLE"" ""$CHAIN_OUT"" >/dev/null 2>&1 || true
      nft create chain inet ""$TABLE"" ""$CHAIN_OUT"" ""{ type filter hook output priority 0 ; }"" >/dev/null
    }
  else
    nft create chain inet ""$TABLE"" ""$CHAIN_OUT"" ""{ type filter hook output priority 0 ; }"" >/dev/null
  fi
}

rule_present() {
  # $1 = chain, $2 = grep ERE pattern
  nft list chain inet ""$TABLE"" ""$1"" 2>/dev/null | grep -qE ""$2""
}

runtime_apply_rules() {
  # Inbound established/related for tcp/udp/icmp (IPv4)
  rule_present ""$CHAIN_IN"" 'ip[[:space:]]+protocol[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+established.*accept' \
    || nft add rule inet ""$TABLE"" ""$CHAIN_IN"" ip protocol tcp ct state established accept >/dev/null
  rule_present ""$CHAIN_IN"" 'ip[[:space:]]+protocol[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+established.*accept' \
    || nft add rule inet ""$TABLE"" ""$CHAIN_IN"" ip protocol udp ct state established accept >/dev/null
  rule_present ""$CHAIN_IN"" 'ip[[:space:]]+protocol[[:space:]]+icmp.*ct[[:space:]]+state[[:space:]]+established.*accept' \
    || nft add rule inet ""$TABLE"" ""$CHAIN_IN"" ip protocol icmp ct state established accept >/dev/null

  # Outbound allow new,related,established for tcp/udp/icmp (IPv4)
  rule_present ""$CHAIN_OUT"" 'ip[[:space:]]+protocol[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' \
    || nft add rule inet ""$TABLE"" ""$CHAIN_OUT"" ip protocol tcp ct state new,related,established accept >/dev/null
  rule_present ""$CHAIN_OUT"" 'ip[[:space:]]+protocol[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' \
    || nft add rule inet ""$TABLE"" ""$CHAIN_OUT"" ip protocol udp ct state new,related,established accept >/dev/null
  rule_present ""$CHAIN_OUT"" 'ip[[:space:]]+protocol[[:space:]]+icmp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' \
    || nft add rule inet ""$TABLE"" ""$CHAIN_OUT"" ip protocol icmp ct state new,related,established accept >/dev/null

  # IPv6 analogs (only if IPv6 enabled and INCLUDE not disabled)
  if ! ipv6_is_disabled; then
    rule_present ""$CHAIN_IN"" 'ip6[[:space:]]+nexthdr[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+established.*accept' \
      || nft add rule inet ""$TABLE"" ""$CHAIN_IN"" ip6 nexthdr tcp ct state established accept >/dev/null
    rule_present ""$CHAIN_IN"" 'ip6[[:space:]]+nexthdr[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+established.*accept' \
      || nft add rule inet ""$TABLE"" ""$CHAIN_IN"" ip6 nexthdr udp ct state established accept >/dev/null
    rule_present ""$CHAIN_IN"" 'ip6[[:space:]]+nexthdr[[:space:]]+icmpv6.*ct[[:space:]]+state[[:space:]]+established.*accept' \
      || nft add rule inet ""$TABLE"" ""$CHAIN_IN"" ip6 nexthdr icmpv6 ct state established accept >/dev/null

    rule_present ""$CHAIN_OUT"" 'ip6[[:space:]]+nexthdr[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' \
      || nft add rule inet ""$TABLE"" ""$CHAIN_OUT"" ip6 nexthdr tcp ct state new,related,established accept >/dev/null
    rule_present ""$CHAIN_OUT"" 'ip6[[:space:]]+nexthdr[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' \
      || nft add rule inet ""$TABLE"" ""$CHAIN_OUT"" ip6 nexthdr udp ct state new,related,established accept >/dev/null
    rule_present ""$CHAIN_OUT"" 'ip6[[:space:]]+nexthdr[[:space:]]+icmpv6.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' \
      || nft add rule inet ""$TABLE"" ""$CHAIN_OUT"" ip6 nexthdr icmpv6 ct state new,related,established accept >/dev/null
  fi
}

persist_rules() {
  ensure_dir ""$(dirname ""$CONF"")""
  touch ""$CONF""; chmod 0644 ""$CONF""
  backup_file ""$CONF""

  # Build a fragment with the needed chains/rules; append if any are missing
  need_append=0
  grep -Eq ""table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || need_append=1
  grep -Eq ""chain[[:space:]]+${CHAIN_IN}.*hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || need_append=1
  grep -Eq ""chain[[:space:]]+${CHAIN_OUT}.*hook[[:space:]]+output[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || need_append=1

  # Look for representative rule lines; if absent, we'll append fragment
  for pat in \
    ""ip[[:space:]]+protocol[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+established.*accept"" \
    ""ip[[:space:]]+protocol[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+established.*accept"" \
    ""ip[[:space:]]+protocol[[:space:]]+icmp.*ct[[:space:]]+state[[:space:]]+established.*accept"" \
    ""ip[[:space:]]+protocol[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept"" \
    ""ip[[:space:]]+protocol[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept"" \
    ""ip[[:space:]]+protocol[[:space:]]+icmp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept""; do
    grep -Eq ""$pat"" ""$CONF"" || need_append=1
  done

  if ! ipv6_is_disabled; then
    for pat in \
      ""ip6[[:space:]]+nexthdr[[:space:]]+tcp.*established.*accept"" \
      ""ip6[[:space:]]+nexthdr[[:space:]]+udp.*established.*accept"" \
      ""ip6[[:space:]]+nexthdr[[:space:]]+icmpv6.*established.*accept"" \
      ""ip6[[:space:]]+nexthdr[[:space:]]+tcp.*new,related,established.*accept"" \
      ""ip6[[:space:]]+nexthdr[[:space:]]+udp.*new,related,established.*accept"" \
      ""ip6[[:space:]]+nexthdr[[:space:]]+icmpv6.*new,related,established.*accept""; do
      grep -Eq ""$pat"" ""$CONF"" || need_append=1
    done
  fi

  if [[ $need_append -eq 1 ]]; then
    {
      echo """"
      echo ""# ${CONTROL_ID} - outbound + established rules, added on $(date -u +'%Y-%m-%dT%H:%M:%SZ')""
      echo ""table inet ${TABLE} {""
      echo ""  chain ${CHAIN_IN} { type filter hook input priority 0 ;""
      echo ""    ip  protocol tcp  ct state established accept""
      echo ""    ip  protocol udp  ct state established accept""
      echo ""    ip  protocol icmp ct state established accept""
      if ! ipv6_is_disabled; then
        echo ""    ip6 nexthdr tcp    ct state established accept""
        echo ""    ip6 nexthdr udp    ct state established accept""
        echo ""    ip6 nexthdr icmpv6 ct state established accept""
      fi
      echo ""  }""
      echo ""  chain ${CHAIN_OUT} { type filter hook output priority 0 ;""
      echo ""    ip  protocol tcp  ct state new,related,established accept""
      echo ""    ip  protocol udp  ct state new,related,established accept""
      echo ""    ip  protocol icmp ct state new,related,established accept""
      if ! ipv6_is_disabled; then
        echo ""    ip6 nexthdr tcp    ct state new,related,established accept""
        echo ""    ip6 nexthdr udp    ct state new,related,established accept""
        echo ""    ip6 nexthdr icmpv6 ct state new,related,established accept""
      fi""
      echo ""  }""
      echo ""}""
    } >> ""$CONF""
  fi
}

audit_report() {
  echo ""AUDIT: nftables outbound/established rules (${CONTROL_ID})""
  echo ""- Runtime rules in inet ${TABLE} / chains: ${CHAIN_IN}, ${CHAIN_OUT}""
  nft list chain inet ""$TABLE"" ""$CHAIN_IN"" 2>/dev/null || echo ""(no input chain)""
  nft list chain inet ""$TABLE"" ""$CHAIN_OUT"" 2>/dev/null || echo ""(no output chain)""
  echo ""- Persistence snippet check in ${CONF}:""
  grep -nE ""table[[:space:]]+inet[[:space:]]+${TABLE}\b|chain[[:space:]]+(${CHAIN_IN}|${CHAIN_OUT})\b"" ""$CONF"" 2>/dev/null || echo ""(no matching lines)""
}

verify_runtime() {
  local ok=1
  # Input
  rule_present ""$CHAIN_IN"" 'ip[[:space:]]+protocol[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+established.*accept' || ok=0
  rule_present ""$CHAIN_IN"" 'ip[[:space:]]+protocol[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+established.*accept' || ok=0
  rule_present ""$CHAIN_IN"" 'ip[[:space:]]+protocol[[:space:]]+icmp.*ct[[:space:]]+state[[:space:]]+established.*accept' || ok=0
  # Output
  rule_present ""$CHAIN_OUT"" 'ip[[:space:]]+protocol[[:space:]]+tcp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' || ok=0
  rule_present ""$CHAIN_OUT"" 'ip[[:space:]]+protocol[[:space:]]+udp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' || ok=0
  rule_present ""$CHAIN_OUT"" 'ip[[:space:]]+protocol[[:space:]]+icmp.*ct[[:space:]]+state[[:space:]]+new,related,established.*accept' || ok=0

  if ! ipv6_is_disabled; then
    rule_present ""$CHAIN_IN""  'ip6[[:space:]]+nexthdr[[:space:]]+tcp.*established.*accept' || ok=0
    rule_present ""$CHAIN_IN""  'ip6[[:space:]]+nexthdr[[:space:]]+udp.*established.*accept' || ok=0
    rule_present ""$CHAIN_IN""  'ip6[[:space:]]+nexthdr[[:space:]]+icmpv6.*established.*accept' || ok=0
    rule_present ""$CHAIN_OUT"" 'ip6[[:space:]]+nexthdr[[:space:]]+tcp.*new,related,established.*accept' || ok=0
    rule_present ""$CHAIN_OUT"" 'ip6[[:space:]]+nexthdr[[:space:]]+udp.*new,related,established.*accept' || ok=0
    rule_present ""$CHAIN_OUT"" 'ip6[[:space:]]+nexthdr[[:space:]]+icmpv6.*new,related,established.*accept' || ok=0
  fi
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$CONF"" ]] || ok=0
  grep -Eq ""table[[:space:]]+inet[[:space:]]+${TABLE}\b"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+${CHAIN_IN}.*hook[[:space:]]+input[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || ok=0
  grep -Eq ""chain[[:space:]]+${CHAIN_OUT}.*hook[[:space:]]+output[[:space:]]+priority[[:space:]]+0"" ""$CONF"" || ok=0
  # representative rules:
  grep -Eq ""ip[[:space:]]+protocol[[:space:]]+tcp.*established.*accept"" ""$CONF"" || ok=0
  grep -Eq ""ip[[:space:]]+protocol[[:space:]]+udp.*established.*accept"" ""$CONF"" || ok=0
  grep -Eq ""ip[[:space:]]+protocol[[:space:]]+icmp.*established.*accept"" ""$CONF"" || ok=0
  grep -Eq ""ip[[:space:]]+protocol[[:space:]]+(tcp|udp|icmp).*new,related,established.*accept"" ""$CONF"" || ok=0

  if ! ipv6_is_disabled; then
    grep -Eq ""ip6[[:space:]]+nexthdr[[:space:]]+(tcp|udp|icmpv6).*established.*accept"" ""$CONF"" || ok=0
    grep -Eq ""ip6[[:space:]]+nexthdr[[:space:]]+(tcp|udp|icmpv6).*new,related,established.*accept"" ""$CONF"" || ok=0
  fi
  return $ok
}

main() {
  require_root
  ensure_nft_installed

  if [[ ""$APPLY"" != ""1"" ]]; then
    echo ""NOTE: Audit mode (set NFT_APPLY=1 to configure rules) (${CONTROL_ID})""
    audit_report
    exit 1
  fi

  runtime_ensure_table_chains
  runtime_apply_rules
  persist_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: nftables outbound + established rules configured (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: nftables outbound/established rules not fully ensured (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
