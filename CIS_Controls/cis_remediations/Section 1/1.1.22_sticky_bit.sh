"#!/usr/bin/env bash
# 1.1.22 - Ensure sticky bit is set on all world-writable directories
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Discover world-writable dirs lacking sticky bit (local filesystems only)
echo ""Auditing world-writable directories without sticky bit...""
mapfile -t WW_NOSTICKY < <(
  df --local -P | awk 'NR>1 {print $6}' \
  | xargs -I'{}' find '{}' -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null
)

if [[ ${#WW_NOSTICKY[@]} -eq 0 ]]; then
  echo ""OK: No world-writable directories without sticky bit.""
  exit 0
fi

printf '%s\n' ""${WW_NOSTICKY[@]}""

# 3) Remediate (optional)
if [[ ""${APPLY:-0}"" -eq 1 ]]; then
  printf '%s\n' ""${WW_NOSTICKY[@]}"" | xargs -r chmod +t
  echo ""OK: Applied sticky bit to the directories above.""
  exit 0
else
  echo ""INFO: Set APPLY=1 to fix the listed directories.""
  exit 1
fi"
