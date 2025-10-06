"#!/usr/bin/env bash
# 3.3.8 Ensure TCP SYN Cookies is enabled (CIS Oracle Linux 7)
# Enforces:
#   net.ipv4.tcp_syncookies = 1
# Runtime + persistence; removes conflicting disables from loaded sysctl files.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.3.8""
SYSCTL_DROPIN=""/etc/sysctl.d/99-cis-tcp-syncookies.conf""

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
      if grep -Eq '^\s*net\.ipv4\.tcp_syncookies\s*=\s*0\b' ""$file"" 2>/dev/null; then
        backup_file ""$file""
        sed -ri \
          -e 's/^\s*(net\.ipv4\.tcp_syncookies\s*)=\s*\S+\b/# *REMOVED* \1= 1/' \
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
# Managed by CIS control 3.3.8 - Enable TCP SYN Cookies
net.ipv4.tcp_syncookies = 1
EOF
  chmod 0644 ""$SYSCTL_DROPIN""
}

apply_runtime() {
  sysctl -w net.ipv4.tcp_syncookies=1 >/dev/null
  sysctl -w net.ipv4.route.flush=1 >/dev/null
  sysctl --system >/dev/null
}

verify_runtime() {
  local v4 ok=1
  v4=""$(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null || echo 0)""
  [[ ""$v4"" == ""1"" ]] || ok=0
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f ""$SYSCTL_DROPIN"" ]] || ok=0
  grep -Eq '^\s*net\.ipv4\.tcp_syncookies\s*=\s*1\b' ""$SYSCTL_DROPIN"" || ok=0

  # Ensure no offenders still set =0 elsewhere
  local offenders
  offenders=""$(grep -Els '^\s*net\.ipv4\.tcp_syncookies\s*=\s*0\b' \
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
    echo ""OK: TCP SYN Cookies enabled (runtime + persistence) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: TCP SYN Cookies not fully enforced (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
