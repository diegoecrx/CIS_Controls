"#!/usr/bin/env bash
# 3.4.1 Ensure DCCP is disabled (CIS Oracle Linux 7)
# Persists: /etc/modprobe.d/dccp.conf with ""install dccp /bin/true"" (and blacklist)
# Runtime: unload if currently loaded
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=0
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.4.1""
DROPIN=""/etc/modprobe.d/dccp.conf""

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

persist_disable_dccp() {
  ensure_dir ""/etc/modprobe.d""
  backup_file ""$DROPIN""
  cat > ""$DROPIN"" <<'EOF'
# Managed by CIS control 3.4.1 - Disable DCCP
# Prevent autoload of dccp
install dccp /bin/true
# Defensive: also blacklist
blacklist dccp
blacklist dccp_diag
EOF
  chmod 0644 ""$DROPIN""
}

runtime_unload_dccp() {
  # Attempt to unload if present
  if lsmod | grep -qw '^dccp'; then
    # Try via modprobe -r to handle dependencies
    modprobe -r dccp dccp_diag 2>/dev/null || rmmod dccp 2>/dev/null || true
  fi
}

verify_runtime() {
  # DCCP module must not be loaded
  if lsmod | grep -qw '^dccp'; then
    return 1
  fi
  return 0
}

verify_persistence() {
  local ok=1
  [[ -f ""$DROPIN"" ]] || ok=0
  grep -qx 'install dccp /bin/true' ""$DROPIN"" || ok=0
  # modprobe simulation should show /bin/true (or not find the module)
  if ! modprobe -n -v dccp 2>/dev/null | grep -qE '^(install|override).*/bin/true|^insmod .*dccp.*not found'; then
    # Accept either an explicit install override to /bin/true OR an absence of module on system
    ok=0
  fi
  return $ok
}

main() {
  require_root
  persist_disable_dccp
  runtime_unload_dccp

  FAIL=0
  verify_runtime || FAIL=1
  verify_persistence || FAIL=1

  if [[ $FAIL -eq 0 ]]; then
    echo ""OK: DCCP disabled (runtime unloaded, persistence ensured) (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: DCCP not fully disabled (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
