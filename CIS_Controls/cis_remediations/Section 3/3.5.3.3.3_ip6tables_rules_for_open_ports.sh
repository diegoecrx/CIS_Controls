#!/usr/bin/env bash
# 3.5.3.3.3 Ensure ip6tables firewall rules exist for all open ports (CIS Oracle Linux 7)
#
# Behavior:
#   - Detects IPv6 listening TCP/UDP sockets (excluding ::1-only).
#   - Ensures INPUT rules exist to ACCEPT NEW traffic to each open port.
#   - Inserts rules at the top of INPUT (to precede default/drop rules).
#   - Persists rules to /etc/sysconfig/ip6tables.
#
# Notes:
#   - Requires 'ss' (iproute) and ip6tables/ip6tables-save.
#   - Only IPv6 is handled here; IPv4 is covered by CIS 3.5.3.2.3.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.5.3.3.3"
PERSIST_FILE="/etc/sysconfig/ip6tables"

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

# Parse unique IPv6 listening TCP ports, skipping ::1-only binds
list_listen_tcp6_ports() {
  # columns: State Recv-Q Send-Q Local Address:Port Peer Address:Port ...
  ss -H -l -n -t -6 2>/dev/null | awk '
    {
      # Find field with ":<port>" at end; handle [IPv6]:port forms
      for (i=1;i<=NF;i++) if ($i ~ /:[0-9]+$/) { addr=$i; break; }
      # Strip brackets if present
      gsub(/^\[/, "", addr); gsub(/\]$/, "", addr);
      split(addr, a, ":"); port=a[length(a)];
      # Reconstruct IP part (could contain colons); assume all but last
      ip=a[1]; for (j=2; j<length(a); j++) ip=ip ":" a[j];
      if (ip != "::1") {
        if (port ~ /^[0-9]+$/) seen[port]=1
      }
    }
    END { for (p in seen) print p }' | sort -n
}

# Parse unique IPv6 listening UDP ports, skipping ::1-only binds
list_listen_udp6_ports() {
  ss -H -l -n -u -6 2>/dev/null | awk '
    {
      for (i=1;i<=NF;i++) if ($i ~ /:[0-9]+$/) { addr=$i; break; }
      gsub(/^\[/, "", addr); gsub(/\]$/, "", addr);
      split(addr, a, ":"); port=a[length(a)];
      ip=a[1]; for (j=2; j<length(a); j++) ip=ip ":" a[j];
      if (ip != "::1") {
        if (port ~ /^[0-9]+$/) seen[port]=1
      }
    }
    END { for (p in seen) print p }' | sort -n
}

rule_present_exact() {
  # Try exact presence with -C (returns 0 if present)
  ip6tables -C "$@" >/dev/null 2>&1
}

rule_present_loose() {
  # Fallback: look for any ACCEPT to same proto/--dport on INPUT in saved rules
  local proto="$1" port="$2"
  ip6tables-save 2>/dev/null | grep -Eq -- "^-A INPUT\b.*-p ${proto}\b.*--dport ${port}\b.*-j ACCEPT\b"
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
  ip6tables -I INPUT 1 -p "$proto" --dport "$port" -m state --state NEW -j ACCEPT >/dev/null
}

apply_runtime() {
  local p
  # TCP6
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    ensure_rule_for_port tcp "$p"
  done < <(list_listen_tcp6_ports || true)

  # UDP6
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    ensure_rule_for_port udp "$p"
  done < <(list_listen_udp6_ports || true)
}

persist_runtime_rules() {
  ensure_dir "$(dirname "$PERSIST_FILE")"
  backup_file "$PERSIST_FILE"
  if have_bin ip6tables-save; then
    ip6tables-save > "$PERSIST_FILE"
    chmod 0600 "$PERSIST_FILE"
  else
    echo "FAIL: ip6tables-save not found; cannot persist rules (${CONTROL_ID})"
    exit 1
  fi
}

verify_runtime() {
  local ok=1 p
  # Verify TCP6
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    rule_present_exact INPUT -p tcp --dport "$p" -m state --state NEW -j ACCEPT \
      || rule_present_loose tcp "$p" || ok=0
  done < <(list_listen_tcp6_ports || true)
  # Verify UDP6
  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    rule_present_exact INPUT -p udp --dport "$p" -m state --state NEW -j ACCEPT \
      || rule_present_loose udp "$p" || ok=0
  done < <(list_listen_udp6_ports || true)
  return $ok
}

verify_persistence() {
  local ok=1 p
  [[ -f "$PERSIST_FILE" ]] || return 1

  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    grep -Eq -- "^-A INPUT\b.*-p tcp\b.*--dport ${p}\b.*-j ACCEPT\b" "$PERSIST_FILE" || ok=0
  done < <(list_listen_tcp6_ports || true)

  while read -r p; do
    [[ -z "${p:-}" ]] && continue
    grep -Eq -- "^-A INPUT\b.*-p udp\b.*--dport ${p}\b.*-j ACCEPT\b" "$PERSIST_FILE" || ok=0
  done < <(list_listen_udp6_ports || true)

  return $ok
}

audit_report() {
  echo "AUDIT: Open IPv6 listening sockets without matching ACCEPT rules (${CONTROL_ID})"
  local missing=0 p
  for proto in tcp udp; do
    if [[ "$proto" == "tcp" ]]; then
      mapfile -t ports < <(list_listen_tcp6_ports || true)
    else
      mapfile -t ports < <(list_listen_udp6_ports || true)
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

  if ! have_bin ip6tables || ! have_bin ss; then
    echo "FAIL: Required tools missing (ip6tables and ss needed) (${CONTROL_ID})"
    exit 1
  fi

  apply_runtime
  persist_runtime_rules

  FAIL=0
  verify_runtime     || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo "OK: ip6tables rules exist for all open IPv6 ports (runtime + persistence) (${CONTROL_ID})"
    exit 0
  else
    audit_report
    echo "FAIL: Missing ip6tables rules for one or more open IPv6 ports (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"
