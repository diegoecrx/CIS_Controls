#!/usr/bin/env bash
# 3.5.3.2.3 Ensure iptables rules exist for all open ports (CIS Oracle Linux 7)
#
# Behavior:
#   - Detects IPv4 listening TCP/UDP sockets (excluding 127.0.0.1-only).
#   - Ensures INPUT rules exist to ACCEPT NEW traffic to each open port.
#   - Inserts rules at the top of INPUT (to precede default/drop rules).
#   - Persists rules to /etc/sysconfig/iptables.
#
# Notes:
#   - Requires 'ss' (from iproute) and iptables/iptables-save.
#   - Only IPv4 is handled per iptables scope; IPv6 is out of scope (ip6tables).
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.5.3.2.3"
PERSIST_FILE="/etc/sysconfig/iptables"

timestamp() { date +"%Y%m%d-%H%M%S"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
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

# Parse unique IPv4 listening TCP ports, skipping 127.0.0.1-only binds
list_listen_tcp4_ports() {
  # columns: State Recv-Q Send-Q Local Address:Port Peer Address:Port ...
  ss -H -l -n -t -4 2>/dev/null | awk '
    {
      # local address is usually column 4; be robust by scanning for ":[0-9]+$"
      for (i=1;i<=NF;i++) {
        if ($i ~ /:[0-9]+$/) { addr=$i; break; }
      }
      split(addr,a,":"); port=a[length(a)];
      gsub(/^\[|\]$/,"",a[1])
      ip=a[1]
      if (ip != "127.0.0.1") {
        if (port ~ /^[0-9]+$/) seen[port]=1
      }
    }
    END { for (p in seen) print p }' | sort -n
}

# Parse unique IPv4 listening UDP ports, skipping 127.0.0.1-only binds
list_listen_udp4_ports() {
  ss -H -l -n -u -4 2>/dev/null | awk '
    {
      for (i=1;i<=NF;i++) {
        if ($i ~ /:[0-9]+$/) { addr=$i; break; }
      }
      split(addr,a,":"); port=a[length(a)];
      gsub(/^\[|\]$/,"",a[1])
      ip=a[1]
      if (ip != "127.0.0.1") {
        if (port ~ /^[0-9]+$/) seen[port]=1
      }
    }
    END { for (p in seen) print p }' | sort -n
}

rule_present_exact() {
  # Try exact presence with -C (may fail if existing rule has extra matches)
  iptables -C "$@" >/dev/null 2>&1
}

rule_present_loose() {
  # Fallback: look for any ACCEPT to the same proto/--dport on INPUT in saved rules
  local proto="$1" port="$2"
  iptables-save 2>/dev/null | grep -Eq -- "^-A INPUT\b.*-p ${proto}\b.*--dport ${port}\b.*-j ACCEPT\b"
}

ensure_rule_for_port() {
  local proto="$1" port="$2"
  # Desired canonical rule:
  #   INPUT -p <proto> --dport <port> -m state --state NEW -j ACCEPT
  if rule_present_exact INPUT -p "$proto" --dport "$port" -m state --state NEW -j ACCEPT; then
    return 0
  fi
  if rule_present_loose "$proto" "$port"; then
    return 0
  fi
  # Insert at top for precedence
  iptables -I INPUT 1 -p "$proto" --dport "$port" -m state --state NEW -j ACCEPT >/dev/null
}

apply_runtime() {
  local p
  # TCP
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    ensure_rule_for_port tcp "$p"
  done < <(list_listen_tcp4_ports || true)

  # UDP
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    ensure_rule_for_port udp "$p"
  done < <(list_listen_udp4_ports || true)
}

persist_runtime_rules() {
  ensure_dir "$(dirname "$PERSIST_FILE")"
  backup_file "$PERSIST_FILE"
  if have_bin iptables-save; then
    iptables-save > "$PERSIST_FILE"
    chmod 0600 "$PERSIST_FILE"
  else
    echo "FAIL: iptables-save not found; cannot persist rules (${CONTROL_ID})"
    exit 1
  fi
}

verify_runtime() {
  local ok=1 p
  # Verify all detected TCP ports have an ACCEPT rule
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    rule_present_exact INPUT -p tcp --dport "$p" -m state --state NEW -j ACCEPT \
      || rule_present_loose tcp "$p" || ok=0
  done < <(list_listen_tcp4_ports || true)

  # Verify all detected UDP ports have an ACCEPT rule
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    rule_present_exact INPUT -p udp --dport "$p" -m state --state NEW -j ACCEPT \
      || rule_present_loose udp "$p" || ok=0
  done < <(list_listen_udp4_ports || true)
  return $ok
}

verify_persistence() {
  local ok=1 p
  [[ -f "$PERSIST_FILE" ]] || return 1

  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    grep -Eq -- "^-A INPUT\b.*-p tcp\b.*--dport ${p}\b.*-j ACCEPT\b" "$PERSIST_FILE" || ok=0
  done < <(list_listen_tcp4_ports || true)

  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    grep -Eq -- "^-A INPUT\b.*-p udp\b.*--dport ${p}\b.*-j ACCEPT\b" "$PERSIST_FILE" || ok=0
  done < <(list_listen_udp4_ports || true)

  return $ok
}

audit_report() {
  echo "AUDIT: Open IPv4 listening sockets without matching ACCEPT rules (${CONTROL_ID})"
  local missing=0 p
  for proto in tcp udp; do
    if [[ "$proto" == "tcp" ]]; then
      mapfile -t ports < <(list_listen_tcp4_ports || true)
    else
      mapfile -t ports < <(list_listen_udp4_ports || true)
    fi
    for p in "${ports[@]:-}"; do
      if ! rule_present_exact INPUT -p "$proto" --dport "$p" -m state --state NEW -j ACCEPT \
         && ! rule_present_loose "$proto" "$p"; then
        printf "  - %s/%s has no ACCEPT rule\n" "$p" "$proto"
        missing=1
      fi
    done
  done
  [[ $missing -eq 0 ]] && echo "  (none)"
}

main() {
  require_root

  if ! have_bin iptables || ! have_bin ss; then
    echo "FAIL: Required tools missing (iptables and ss needed) (${CONTROL_ID})"
    exit 1
  fi

  # Apply
  apply_runtime
  persist_runtime_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: iptables rules exist for all open IPv4 ports (runtime + persistence) (${CONTROL_ID})"
    exit 0
  else
    audit_report
    echo "FAIL: Missing iptables rules for one or more open ports (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"
