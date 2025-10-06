"#!/usr/bin/env bash
# 3.3.9 Ensure IPv6 router advertisements are not accepted (CIS Oracle Linux 7)
# Enforces (IF IPv6 is enabled):
#   net.ipv6.conf.all.accept_ra = 0
#   net.ipv6.conf.default.accept_ra = 0
# Runtime + persistence; removes conflicting enables from loaded sysctl files.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.3.9""
SYSCTL_DROPIN=""/etc/sysctl.d/99-cis-ipv6-ra.conf""

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
  # Consider IPv6 disabled if proc path is missing, or sysctl disable flag set, or kernel arg present
  if [[ ! -d /proc/sys/net/ipv6 ]]; then
    return 0
  fi
  local v
  v=""$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo 0)""
  if [[ ""$v"" == ""1"" ]]; then
    return 0
  fi
  if grep -qw 'ipv6.disable=1' /proc/cmdline 2>/dev/null; then
    return 0
  fi
  return 1
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
      if grep -Eq '^\s*net\.ipv6\.conf\.(all|default)\.accept_ra\s*=\s*1\b' ""$file"" 2>/dev/null; then
        backup_file ""$file""
        sed -ri \
          -e 's/^\s*(net\.ipv6\.conf\.all\.accept_ra\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          -e 's/^\s*(net\.ipv6\.conf\.default\.accept_ra\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          ""$file""
      fi
    done
  done
  shopt -u nullglob
}

write_persistent_dropin() {
  ensure_dir ""/etc/sysctl.d""
  backup_file ""$SYSCTL_DROPIN""
  cat > ""$SYSCTL_DROPIN"" <<'EOF'
# Managed by CIS control 3.3.9 - Disallow IPv6 Router Advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
EOF
  chmod 0644 ""$SYSCTL_DROPIN""
}

apply_runtime() {
  sysctl -w net.ipv6.conf.all.accept_ra=0 >/dev/null 2>&1 || true
  sysctl -w net.ipv6.conf.default.accept_ra=0 >/dev/null 2>&1 || true
  sysctl -w net.ipv6.route.flush=1 >/dev/null 2>&1 || true
  sysctl --system >/dev/null
}

verify_runtime() {
  # If IPv6 is disabled, treat as pass for runtime
  if ipv6_is_disabled; then
    return 0
  fi
  local all def ok=1
  all=""$(sysctl -n net.ipv6.conf.all.accept_ra 2>/dev/null || echo 1)""
  def=""$(sysctl -n net.ipv6.conf.default.accept_ra 2>/dev/null || echo 1)""
  [[ ""$all"" == ""0"" ]] || ok=0
  [[ ""$def"" == ""0"" ]] || ok=0
  return $ok
}

verify_persistence() {
  # If IPv6 is disabled, persistence config is not required by CIS; treat as pass
  if ipv6_is_disabled; then
    return 0
  fi
  local ok=1
  [[ -f ""$SYSCTL_DROPIN"" ]] || ok=0
  grep -Eq '^\s*net\.ipv6\.conf\.all\.accept_ra\s*=\s*0\b' ""$SYSCTL_DROPIN"" || ok=0
  grep -Eq '^\s*net\.ipv6\.conf\.default\.accept_ra\s*=\s*0\b' ""$SYSCTL_DROPIN"" || ok=0

  # Ensure no offenders elsewhere set =1
  local offenders
  offenders=""$(grep -Els '^\s*net\.ipv6\.conf\.(all|default)\.accept_ra\s*=\s*1\b' \
    /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null || true)""
  [[ -z ""$offenders"" ]] || ok=0
  return $ok
}

main() {
  require_root

  if ipv6_is_disabled; then
    # Nothing to enforce; ensure conflicting enables are not present to avoid regressions if IPv6 is later enabled
    sanitize_conflicting_sysctl
    echo ""OK: IPv6 is disabled; RA acceptance not applicable (${CONTROL_ID})""
    exit 0
  fi

  sanitize_conflicting_sysctl
  write_persistent_dropin
  apply_runtime

  FAIL=0
  verify_runtime || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: IPv6 Router Advertisements are not accepted (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: IPv6 RA acceptance not fully disabled (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
