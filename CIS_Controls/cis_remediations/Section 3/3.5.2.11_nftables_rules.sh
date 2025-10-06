"#!/usr/bin/env bash
# 3.5.2.11 Ensure nftables rules are permanent (CIS Oracle Linux 7)
# Purpose:
#   Ensure /etc/sysconfig/nftables.conf contains include lines for rule files,
#   so nftables loads them at boot. Creates missing rule files/directories.
#
# Usage:
#   - Default includes: /etc/nftables/nftables.rules
#   - Override with env var (comma-separated absolute paths):
#       NFT_INCLUDE_FILES=""/etc/nftables/base.rules,/opt/security/nft-extra.rules""
#
# Notes:
#   - No enable/start of nftables.service here (handled in 3.5.2.10).
#   - Idempotent; backs up edited files with timestamp.
#
# APPLICABILITY FLAGS (informational only)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONTROL_ID=""CIS 3.5.2.11""
CONF=""/etc/sysconfig/nftables.conf""
INCLUDES_RAW=""${NFT_INCLUDE_FILES:-/etc/nftables/nftables.rules}""

timestamp() { date +""%Y%m%d-%H%M%S""; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo ""FAIL: Must run as root (${CONTROL_ID})""
    exit 1
  fi
}

# Split comma-separated list, trim spaces, keep only absolute paths
normalize_includes() {
  echo ""$INCLUDES_RAW"" \
    | tr ',' '\n' \
    | sed -e 's/^[[:space:]]*//; s/[[:space:]]*$//' \
    | awk 'BEGIN{FS=""\n""} /^[\/].+/ {print}' \
    | awk '!seen[$0]++'
}

backup_file() {
  local f=""$1""
  [[ -f ""$f"" ]] || return 0
  cp -a --preserve=all ""$f"" ""${f}.bak.$(timestamp)""
}

ensure_dir() {
  local d=""$1"" m=""${2:-0755}""
  install -d -m ""$m"" ""$d""
}

ensure_file() {
  local f=""$1""
  ensure_dir ""$(dirname ""$f"")""
  if [[ ! -e ""$f"" ]]; then
    umask 022
    printf '# Created by %s on %s\n' ""$CONTROL_ID"" ""$(date -u +'%Y-%m-%dT%H:%M:%SZ')"" > ""$f""
    chmod 0644 ""$f""
  fi
}

prepare_conf() {
  ensure_dir ""$(dirname ""$CONF"")""
  if [[ ! -e ""$CONF"" ]]; then
    umask 022
    printf '# nftables boot configuration\n' > ""$CONF""
    chmod 0644 ""$CONF""
  fi
}

# Ensure a specific include line exists uncommented and normalized as: include ""<path>""
ensure_include_line() {
  local path=""$1"" tmp sed_escaped
  sed_escaped=""$(printf '%s\n' ""$path"" | sed -e 's/[.[\*^$()+?{}|\/]/\\&/g')""

  # If a commented include exists, uncomment/normalize it
  if grep -Eq ""^[[:space:]]*#?[[:space:]]*include[[:space:]]+\""${sed_escaped}\""[[:space:]]*$"" ""$CONF""; then
    # Normalize the line exactly once
    tmp=""$(mktemp)""
    awk -v P=""$path"" '
      BEGIN{fixed=0}
      {
        if ($0 ~ ""^[[:space:]]*#?[[:space:]]*include[[:space:]]+\""""P""\""[[:space:]]*$"" && fixed==0) {
          print ""include \"""" P ""\""""
          fixed=1
          next
        }
        print
      }' ""$CONF"" > ""$tmp""
    backup_file ""$CONF""
    cat ""$tmp"" > ""$CONF""
    rm -f ""$tmp""
  else
    # Append include (with header once)
    if ! grep -q ""# ${CONTROL_ID} includes"" ""$CONF""; then
      backup_file ""$CONF""
      {
        echo """"
        echo ""# ${CONTROL_ID} includes (added $(date -u +'%Y-%m-%dT%H:%M:%SZ'))""
      } >> ""$CONF""
    else
      backup_file ""$CONF""
    fi
    echo ""include \""${path}\"""" >> ""$CONF""
  fi
}

verify_includes_present() {
  local ok=1 path
  while read -r path; do
    [[ -z ""$path"" ]] && continue
    # must exist and be readable
    [[ -r ""$path"" ]] || ok=0
    # must have an uncommented include line
    grep -Eq ""^[[:space:]]*include[[:space:]]+\""$(printf '%s' ""$path"" | sed 's/[.[\*^$()+?{}|\/]/\\&/g')\""[[:space:]]*$"" ""$CONF"" || ok=0
  done < <(normalize_includes)
  return $ok
}

main() {
  require_root
  prepare_conf

  # Build list and ensure rule files exist
  mapfile -t files < <(normalize_includes)
  if [[ ""${#files[@]}"" -eq 0 ]]; then
    echo ""FAIL: No valid absolute paths provided for NFT_INCLUDE_FILES (${CONTROL_ID})""
    exit 1
  fi
  for f in ""${files[@]}""; do
    ensure_file ""$f""
    ensure_include_line ""$f""
  done

  # Verification
  if verify_includes_present; then
    echo ""OK: nftables rules are configured to load at boot via includes in ${CONF} (${CONTROL_ID})""
    exit 0
  else
    echo ""FAIL: One or more nftables include lines/files are missing or unreadable (${CONTROL_ID})""
    exit 1
  fi
}

main ""$@"""
