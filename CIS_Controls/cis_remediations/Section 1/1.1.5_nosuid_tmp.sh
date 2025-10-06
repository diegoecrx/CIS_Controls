"#!/usr/bin/env bash
# 1.1.5 - Ensure nosuid option set on /tmp partition (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

STAMP=""$(date +%Y%m%d%H%M%S)""
FSTAB=""/etc/fstab""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# Helper: ensure an option exists in the /etc/fstab 4th field for a mountpoint
ensure_opt_in_fstab() {
  local mp=""$1"" opt=""$2""
  cp -p ""$FSTAB"" ""${FSTAB}.bak-${STAMP}""
  awk -v mp=""$mp"" -v opt=""$opt"" '
    BEGIN{OFS=""\t"";}
    /^[[:space:]]*($|#)/{print; next}
    $2==mp {
      n=split($4,a,"",""); has=0
      for(i=1;i<=n;i++) if(a[i]==opt) has="
