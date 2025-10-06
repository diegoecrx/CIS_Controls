"#!/usr/bin/env bash
# 3.5.2.4 Ensure iptables are flushed with nftables (CIS Oracle Linux 7)
#
# Default: Audit only. Set FW_FLUSH=1 to perform remediation (flush v4/v6).
# Backups: Saves current rules to /var/backups/{iptables,ip6tables}-<timestamp>.rules before flushing.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.4""
DO_FLUSH=""${FW_FLUSH:-0}""   # 0=audit, 1=flush

timestamp() { date +""%Y%m%d-%H%M%S""; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

ensure_dir() {
  local d=""$1"" m=""${2:-0750}""
  install -d -m ""$m"" ""$d""
}

have_bin() { command -v ""$1"" >/dev/null 2>&1; }

backup_iptables_rules() {
  local ts=""$1"" bdir=""/var/backups""
  ensure_dir ""$bdir""
  if have_bin iptables-save; then
    iptables-save > ""${bdir}/iptables-${ts}.rules"" || true
  fi
  if have_bin ip6tables-save; then
    ip6tables-save > ""${bdir}/ip6tables-${ts}.rules"" || true
  fi
}

audit_iptables() {
  echo ""AUDIT: Legacy iptables state (${CONTROL_ID})""
  if have_bin iptables; then
    echo ""- IPv4 non-policy rules:""
    (iptables -S 2>/dev/null | grep -E '^-A ' || echo ""(none)"") || true
  else
    echo ""- IPv4: iptables binary not present.""
  fi

  if have_bin ip6tables; then
    echo ""- IPv6 non-policy rules:""
    (ip6tables -S 2>/dev/null | grep -E '^-A ' || echo ""(none)"") || true
  else
    echo ""- IPv6: ip6tables binary not present.""
  fi
}

flush_iptables() {
  # Flush only if binaries exist
  if have_bin iptables; then
    iptables -F || true
    # Also flush nat/mangle/raw chains if present
    for t in nat mangle raw security; do iptables -t ""$t"" -F 2>/dev/null || true; done
  fi
  if have_bin ip6tables; then
    ip6tables -F || true
    for t in nat mangle raw security; do ip6tables -t ""$t"" -F 2>/dev/null || true; done
  fi
}

verify_flushed() {
  local ok=1
  if have_bin iptables; then
    if iptables -S 2>/dev/null | grep -qE '^-A '; then ok=0; fi
    # Also ensure no user-defined chains remain with rules
    for t in filter nat mangle raw security; do
      iptables -t ""$t"" -S 2>/dev/null | grep -qE '^-A ' && ok=0 || true
    done
  fi
  if have_bin ip6tables; then
    if ip6tables -S 2>/dev/null | grep -qE '^-A '; then ok=0; fi
    for t in filter nat mangle raw security; do
      ip6tables -t ""$t"" -S 2>/dev/null | grep -qE '^-A ' && ok=0 || true
    done
  fi
  return $ok
}

main() {
  require_root

  # If nothing to do (binaries absent), treat as compliant.
  if ! have_bin iptables && ! have_bin ip6tables; then
    echo ""OK: No legacy iptables binaries present (${CONTROL_ID})""
    exit 0
  fi

  if [[ ""$DO_FLUSH"" != ""1"" ]]; then
    audit_iptables
    echo ""NOTE: Set FW_FLUSH=1 to flush legacy iptables rules (${CONTROL_ID})""
    exit 1
  fi

  local ts; ts=""$(timestamp)""
  backup_iptables_rules ""$ts""
  flush_iptables

  if verify_flushed; then
    echo ""OK: Legacy iptables rules flushed (backups in /var/backups, ts=${ts}) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: Legacy iptables rules still present after flush (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
