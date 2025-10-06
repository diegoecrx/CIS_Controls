"#!/usr/bin/env bash
# 3.5.3.2.2 Ensure iptables outbound and established connections are configured (CIS Oracle Linux 7)
#
# Manual control with Audit + Optional Remediation.
#
# Defaults:
#   - Audit only. Set IPT_APPLY=1 to add rules (runtime + persistence).
#   - Saves IPv4 rules to /etc/sysconfig/iptables (iptables-services format).
#
# Rules to ensure (IPv4):
#   Outbound (OUTPUT):   -p tcp|udp|icmp  -m state --state NEW,ESTABLISHED   -j ACCEPT
#   Inbound  (INPUT):    -p tcp|udp|icmp  -m state --state ESTABLISHED       -j ACCEPT
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.3.2.2""
APPLY=""${IPT_APPLY:-0}""                 # 0=audit only, 1=apply
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

# Check if a rule exists using -C (returns 0 if present)
rule_present() {
  iptables -C ""$@"" >/dev/null 2>&1
}

# Insert near top to ensure precedence over any default/drop rules
insert_rule_top() {
  local chain=""$1""; shift
  iptables -I ""$chain"" 1 ""$@"" >/dev/null
}

append_rule() {
  local chain=""$1""; shift
  iptables -A ""$chain"" ""$@"" >/dev/null
}

apply_runtime_rules() {
  # Inbound: ESTABLISHED allowed
  rule_present INPUT -p tcp  -m state --state ESTABLISHED -j ACCEPT || insert_rule_top INPUT -p tcp  -m state --state ESTABLISHED -j ACCEPT
  rule_present INPUT -p udp  -m state --state ESTABLISHED -j ACCEPT || insert_rule_top INPUT -p udp  -m state --state ESTABLISHED -j ACCEPT
  rule_present INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT || insert_rule_top INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

  # Outbound: NEW,ESTABLISHED allowed (append is fine; insert if you prefer top)
  rule_present OUTPUT -p tcp  -m state --state NEW,ESTABLISHED -j ACCEPT || append_rule OUTPUT -p tcp  -m state --state NEW,ESTABLISHED -j ACCEPT
  rule_present OUTPUT -p udp  -m state --state NEW,ESTABLISHED -j ACCEPT || append_rule OUTPUT -p udp  -m state --state NEW,ESTABLISHED -j ACCEPT
  rule_present OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT || append_rule OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
}

persist_runtime_rules() {
  ensure_dir ""$(dirname ""$PERSIST_FILE"")""
  backup_file ""$PERSIST_FILE""
  if have_bin iptables-save; then
    iptables-save > ""$PERSIST_FILE""
    chmod 0600 ""$PERSIST_FILE""
  else
    echo ""FAIL: iptables-save not found; cannot persist rules (${CONTROL_ID})""
    exit 1
  fi
}

audit_report() {
  echo ""AUDIT: iptables outbound/established rules (${CONTROL_ID})""
  echo ""- INPUT chain (expect ESTABLISHED accepts for tcp/udp/icmp):""
  iptables -S INPUT 2>/dev/null | grep -E -- '(-p (tcp|udp|icmp) .*--state ESTABLISHED .* -j ACCEPT)' || echo ""(none)""
  echo ""- OUTPUT chain (expect NEW,ESTABLISHED accepts for tcp/udp/icmp):""
  iptables -S OUTPUT 2>/dev/null | grep -E -- '(-p (tcp|udp|icmp) .*--state NEW,ESTABLISHED .* -j ACCEPT)' || echo ""(none)""
  echo ""- Persistence file (${PERSIST_FILE}) presence:""
  [[ -f ""$PERSIST_FILE"" ]] && echo ""  present"" || echo ""  absent""
}

verify_runtime() {
  local ok=1
  rule_present INPUT  -p tcp  -m state --state ESTABLISHED -j ACCEPT || ok=0
  rule_present INPUT  -p udp  -m state --state ESTABLISHED -j ACCEPT || ok=0
  rule_present INPUT  -p icmp -m state --state ESTABLISHED -j ACCEPT || ok=0
  rule_present OUTPUT -p tcp  -m state --state NEW,ESTABLISHED -j ACCEPT || ok=0
  rule_present OUTPUT -p udp  -m state --state NEW,ESTABLISHED -j ACCEPT || ok=0
  rule_present OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT || ok=0
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$PERSIST_FILE"" ]] || ok=0
  grep -Eq '^-A INPUT -p tcp .*--state ESTABLISHED .* -j ACCEPT\b' ""$PERSIST_FILE"" || ok=0
  grep -Eq '^-A INPUT -p udp .*--state ESTABLISHED .* -j ACCEPT\b' ""$PERSIST_FILE"" || ok=0
  grep -Eq '^-A INPUT -p icmp .*--state ESTABLISHED .* -j ACCEPT\b' ""$PERSIST_FILE"" || ok=0
  grep -Eq '^-A OUTPUT -p tcp .*--state NEW,ESTABLISHED .* -j ACCEPT\b' ""$PERSIST_FILE"" || ok=0
  grep -Eq '^-A OUTPUT -p udp .*--state NEW,ESTABLISHED .* -j ACCEPT\b' ""$PERSIST_FILE"" || ok=0
  grep -Eq '^-A OUTPUT -p icmp .*--state NEW,ESTABLISHED .* -j ACCEPT\b' ""$PERSIST_FILE"" || ok=0
  return $ok
}

main() {
  require_root

  if ! have_bin iptables; then
    echo ""FAIL: iptables not found. Install iptables/iptables-services first (see CIS 3.5.3.1.1) (${CONTROL_ID})""
    exit 1
  fi

  if [[ ""$APPLY"" != ""1"" ]]; then
    audit_report
    echo ""NOTE: Set IPT_APPLY=1 to configure rules (runtime + persistence) (${CONTROL_ID})""
    exit 1
  fi

  apply_runtime_rules
  persist_runtime_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: iptables outbound + established rules configured (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: iptables outbound/established rules not fully ensured (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
