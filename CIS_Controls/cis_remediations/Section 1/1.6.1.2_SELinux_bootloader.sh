"#!/usr/bin/env bash
# 1.6.1.2 - Ensure SELinux is not disabled in bootloader configuration (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

GRUB_DEFAULT=""/etc/default/grub""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Determine target grub.cfg (BIOS vs UEFI)
if [[ -d /sys/firmware/efi && -d /boot/efi/EFI ]]; then
  if [[ -d /boot/efi/EFI/redhat ]]; then
    GRUB_CFG=""/boot/efi/EFI/redhat/grub.cfg""
  else
    VENDOR_DIR=""$(find /boot/efi/EFI -mindepth 1 -maxdepth 1 -type d | head -n1 || true)""
    GRUB_CFG=""${VENDOR_DIR:-/boot/efi/EFI/redhat}/grub.cfg""
  fi
else
  GRUB_CFG=""/boot/grub2/grub.cfg""
fi

# 3) Backup once
[[ -f ""$GRUB_DEFAULT"" ]] && cp -p ""$GRUB_DEFAULT"" ""${GRUB_DEFAULT}.bak-${STAMP}"" || true
[[ -f ""$GRUB_CFG""     ]] && cp -p ""$GRUB_CFG""     ""${GRUB_CFG}.bak-${STAMP}""     || true

# 4) Clean /etc/default/grub: remove selinux=0 and enforcing=0 from GRUB_CMDLINE_LINUX* variables
#    - preserve existing options and quoting
#    - remove duplicate spaces
awk '
function strip_flags(s) {
  gsub(/\<selinux=0\>/, """", s)
  gsub(/\<enforcing=0\>/, """", s)
  gsub(/[[:space:]]+/, "" "", s)
  sub(/^[[:space:]]+/, """", s)
  sub(/[[:space:]]+$/, """", s)
  return s
}
BEGIN { OFS=""""; }
/^[[:space:]]*GRUB_CMDLINE_LINUX(_DEFAULT)?=/ {
  # Keep the key and the ""=""
  split($0, kv, ""="")
  key=kv[1]
  val=substr($0, index($0, ""="")+1)
  # Normalize quotes; if not quoted, wrap in quotes
  gsub(/^[[:space:]]+/, """", val)
  gsub(/[[:space:]]+$/, """", val)
  if (val ~ /^""/) {
    inner=val
    sub(/^""/, """", inner); sub(/""$/, """", inner)
  } else if (val ~ /^'\''/) {
    inner=val
    sub(/^'\''/, """", inner); sub(/'\''$/, """", inner)
  } else {
    inner=val
  }
  inner=strip_flags(inner)
  print key, ""=\"""", inner, ""\""""
  next
}
{ print $0 }
' ""$GRUB_DEFAULT"" > ""${GRUB_DEFAULT}.new""
mv ""${GRUB_DEFAULT}.new"" ""$GRUB_DEFAULT""

# 5) Regenerate grub.cfg
if command -v grub2-mkconfig >/dev/null 2>&1; then
  grub2-mkconfig -o ""$GRUB_CFG"" >/dev/null
else
  echo ""ERROR: grub2-mkconfig not found."" >&2
  exit 1
fi

# 6) Verify
FAIL=0

# No disabling flags in /etc/default/grub (anywhere)
if grep -Eq '(^|[[:space:]])(selinux=0|enforcing=0)([[:space:]]|$)' ""$GRUB_DEFAULT""; then
  echo ""FAIL: /etc/default/grub still contains selinux=0 or enforcing=0""
  FAIL=1
fi

# No disabling flags in generated grub.cfg (kernel cmdlines)
if [[ -f ""$GRUB_CFG"" ]]; then
  if grep -Eq '(^|[[:space:]])(selinux=0|enforcing=0)([[:space:]]|$)' ""$GRUB_CFG""; then
    echo ""FAIL: $GRUB_CFG still contains selinux=0 or enforcing=0""
    FAIL=1
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Bootloader no longer disables SELinux (CIS 1.6.1.2).""
  echo ""NOTE: Changes take effect next boot.""
  exit 0
else
  exit 1
fi"
