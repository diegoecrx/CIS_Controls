#!/usr/bin/env bash
# 3.2.2 Ensure packet redirect sending is disabled (CIS Oracle Linux 7)
# Sets and enforces:
#   net.ipv4.conf.all.send_redirects = 0
#   net.ipv4.conf.default.send_redirects = 0
# Runtime + persistence; removes conflicting enables from loaded sysctl files.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID="CIS 3.2.2"
SYSCTL_DROPIN="/etc/sysctl.d/99-cis-ipv4-redirects.conf"

timestamp() { date +"%Y%m%d-%H%M%S"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "FAIL: Must run as root (${CONTROL_ID})"
    exit 1
  fi
}

backup_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a --preserve=all "$f" "${f}.bak.$(timestamp)"
  fi
}

ensure_dir() {
  local d="$1" m="${2:-0755}"
  install -d -m "$m" "$d"
}

sanitize_conflicting_sysctl() {
  local paths=(
    "/etc/sysctl.conf"
    "/etc/sysctl.d/*.conf"
    "/usr/lib/sysctl.d/*.conf"
    "/run/sysctl.d/*.conf"
  )
  local file
  shopt -s nullglob
  for pattern in "${paths[@]}"; do
    for file in $pattern; do
      [[ "$file" == "$SYSCTL_DROPIN" ]] && continue
      if grep -Eq '^\s*net\.ipv4\.conf\.(all|default)\.send_redirects\s*=\s*1\b' "$file" 2>/dev/null; then
        backup_file "$file"
        sed -ri \
          -e 's/^\s*(net\.ipv4\.conf\.all\.send_redirects\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          -e 's/^\s*(net\.ipv4\.conf\.default\.send_redirects\s*)=\s*\S+\b/# *REMOVED* \1= 0/' \
          "$file"
      fi
    done
  done
  shopt -u nullglob
}

write_persistent_dropin() {
  ensure_dir "/etc/sysctl.d"
  backup_file "$SYSCTL_DROPIN"
  cat > "$SYSCTL_DROPIN" <<'EOF'
# Managed by CIS control 3.2.2 - Disable IPv4 packet redirect sending
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
EOF
  chmod 0644 "$SYSCTL_DROPIN"
}

apply_runtime() {
  sysctl -w net.ipv4.conf.all.send_redirects=0 >/dev/null
  sysctl -w net.ipv4.conf.default.send_redirects=0 >/dev/null
  sysctl -w net.ipv4.route.flush=1 >/dev/null
  sysctl --system >/dev/null
}

verify_runtime() {
  local all def ok=1
  all="$(sysctl -n net.ipv4.conf.all.send_redirects 2>/dev/null || echo 1)"
  def="$(sysctl -n net.ipv4.conf.default.send_redirects 2>/dev/null || echo 1)"
  [[ "$all" == "0" ]] || ok=0
  [[ "$def" == "0" ]] || ok=0
  return $ok
}

verify_persistence() {
  local ok=1
  [[ -f "$SYSCTL_DROPIN" ]] || ok=0
  grep -Eq '^\s*net\.ipv4\.conf\.all\.send_redirects\s*=\s*0\b' "$SYSCTL_DROPIN" || ok=0
  grep -Eq '^\s*net\.ipv4\.conf\.default\.send_redirects\s*=\s*0\b' "$SYSCTL_DROPIN" || ok=0

  # Ensure no offenders still set =1
  local offenders
  offenders="$(grep -Els '^\s*net\.ipv4\.conf\.(all|default)\.send_redirects\s*=\s*1\b' \
    /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null || true)"
  [[ -z "$offenders" ]] || ok=0
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
    echo "OK: IPv4 packet redirect sending disabled (runtime + persistence) (${CONTROL_ID})"
    exit 0
  else
    echo "FAIL: IPv4 packet redirect sending not fully disabled (${CONTROL_ID})"
    exit 1
  fi
}

main "$@"