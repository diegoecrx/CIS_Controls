"#!/usr/bin/env bash
# 3.3.1 Ensure source routed packets are not accepted (CIS Oracle Linux 7)
# Enforces:
#   IPv4: net.ipv4.conf.all.accept_source_route = 0
#         net.ipv4.conf.default.accept_source_route = 0
#   IPv6 (if IPv6 not disabled): net.ipv6.conf.all.accept_source_route = 0
#                                net.ipv6.conf.default.accept_source_route = 0
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.3.1""
SYSCTL_DROPIN=""/etc/sysctl.d/99-cis-src-route.conf""

timestamp() { date +""%Y%m%d-%H%M%S""; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
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

ipv6_is_disabled() {
  # Consider IPv6 disabled if kernel flag or sysctl says so, or proc path is missing
  if [[ ! -d /proc/sys/net/ipv6 ]]; then
    return 0
  fi
  local v
  v=""$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo 0)""
  [[ ""$v"" == ""1"" ]]
}

sanitize_conflicting_sysctl() {
  local paths=(
    ""/etc/sysctl.conf""
    ""/etc/sysctl.d/*.conf""
    ""/usr/lib/sysctl.d/*.conf""
    ""/run/sysctl.d/*.conf""
  )
  local file
  shopt -s nullglob
  for pattern in ""${paths[@]}""; do
    for file in $pattern; do
      [[ ""$file"" == ""$SYSCTL_DROPIN"" ]] && continue
      # If any conflicting enables (=1) exist, comment them out
      if grep -Eq '^\s*net\.ipv4\.conf\.(all|default)\.accept_source_route\s*=\s*1\b' ""$file"" 2>/dev/null || \
         grep -Eq '^\s*net\.ipv6\.conf\.(all|default)\.accept_source_route\s*=\s*1\b' ""$file"" 2>/dev/null; then
        backup_file ""$file""
        sed -ri \
          -e 's/^\s*(net\.ipv4\.conf\.all\.accept_source_route\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          -e 's/^\s*(net\.ipv4\.conf\.default\.accept_source_route\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          -e 's/^\s*(net\.ipv6\.conf\.all\.accept_source_route\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          -e 's/^\s*(net\.ipv6\.conf\.default\.accept_source_route\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          ""$file""
      fi
    done
  done
  shopt -u nullglob
}

write_persistent_dropin() {
  ensure_dir ""/etc/sysctl.d""
  backup_file ""$SYSCTL_DROPIN""
  {
    echo ""# Managed by ${CONTROL_ID} - Disallow source-routed packets""
    echo ""net.ipv4.conf.all.accept_source_route = 0""
    echo ""net.ipv4.conf.default.accept_source_route = 0""
    if ! ipv6_is_disabled; then
      echo ""net.ipv6.conf.all.accept_source_route = 0""
      echo ""net.ipv6.conf.default.accept_source_route = 0""
    fi
  } > ""$SYSCTL_DROPIN""
  chmod 0644 ""$SYSCTL_DROPIN""
}

apply_runtime() {
  # IPv4
  sysctl -w net.ipv4.conf.all.accept_source_route=0 >/dev/null
  sysctl -w net.ipv4.conf.default.accept_source_route=0 >/dev/null
  sysctl -w net.ipv4.route.flush=1 >/dev/null

  # IPv6 (only if not disabled)
  if ! ipv6_is_disabled; then
    sysctl -w net.ipv6.conf.all.accept_source_route=0 >/dev/null 2>&1 || true
    sysctl -w net.ipv6.conf.default.accept_source_route=0 >/dev/null 2>&1 || true
    sysctl -w net.ipv6.route.flush=1 >/dev/null 2>&1 || true
  fi

  # Reload all sysctls to ensure persistence picked up
  sysctl --system >/dev/null
}

verify_runtime() {
  local ok=1
  local v4_all v4_def v6_all v6_def

  v4_all=""$(sysctl -n net.ipv4.conf.all.accept_source_route 2>/dev/null || echo 1)""
  v4_def=""$(sysctl -n net.ipv4.conf.default.accept_source_route 2>/dev/null || echo 1)""
  [[ ""$v4_all"" == ""0"" ]] || ok=0
  [[ ""$v4_def"" == ""0"" ]] || ok=0

  if ! ipv6_is_disabled; then
    v6_all=""$(sysctl -n net.ipv6.conf.all.accept_source_route 2>/dev/null || echo 1)""
    v6_def=""$(sysctl -n net.ipv6.conf.default.accept_source_route 2>/dev/null || echo 1)""
    [[ ""$v6_all"" == ""0"" ]] || ok=0
    [[ ""$v6_def"" == ""0"" ]] || ok=0
  fi

  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$SYSCTL_DROPIN"" ]] || ok=0
  grep -Eq '^\s*net\.ipv4\.conf\.all\.accept_source_route\s*=\s*0\b' ""$SYSCTL_DROPIN"" || ok=0
  grep -Eq '^\s*net\.ipv4\.conf\.default\.accept_source_route\s*=\s*0\b' ""$SYSCTL_DROPIN"" || ok=0

  if ! ipv6_is_disabled; then
    grep -Eq '^\s*net\.ipv6\.conf\.all\.accept_source_route\s*=\s*0\b' ""$SYSCTL_DROPIN"" || ok=0
    grep -Eq '^\s*net\.ipv6\.conf\.default\.accept_source_route\s*=\s*0\b' ""$SYSCTL_DROPIN"" || ok=0
  fi

  # Ensure no offenders elsewhere set =1
  local offenders
  offenders=""$(grep -Els '^\s*net\.(ipv4|ipv6)\.conf\.(all|default)\.accept_source_route\s*=\s*1\b' \
    /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null || true)""
  [[ -z ""$offenders"" ]] || ok=0
  return $ok
}

main() {
  require_root
  sanitize_conflicting_sysctl
  write_persistent_dropin
  apply_runtime

  FAIL=0
  verify_runtime || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: Source-routed packets are not accepted (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: Source-routed packet acceptance not fully disabled (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
