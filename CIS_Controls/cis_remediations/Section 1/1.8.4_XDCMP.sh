"#!/usr/bin/env bash
# 1.8.4 - Ensure XDMCP is not enabled (GDM) - Oracle Linux 7
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

CONF=""/etc/gdm/custom.conf""
STAMP=""$(date +%Y%m%d%H%M%S)""
mkdir -p ""$(dirname ""$CONF"")""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure file exists and back it up once
[[ -f ""$CONF"" ]] || install -m 0644 -o root -g root /dev/null ""$CONF""
cp -p ""$CONF"" ""${CONF}.bak-${STAMP}""

# 3) Enforce: no ""Enable=true"" under [xdmcp]; ensure ""Enable=false"" (explicitly disabled)
awk '
  BEGIN { OFS=""""; in=0; seen_enable=0; seen_section=0 }
  # Section headers
  /^\s*\[/ {
    if (in && !seen_enable) { print ""Enable=false"" }   # close existing [xdmcp] with explicit disable if missing
    in=0
    if ($0 ~ /^\s*\[xdmcp\]\s*$/) { in=1; seen_section=1; seen_enable=0 }
    print; next
  }
  {
    if (in) {
      if ($0 ~ /^\s*Enable\s*=\s*true\s*$/) { print ""Enable=false""; seen_enable=1; next }
      if ($0 ~ /^\s*Enable\s*=\s*false\s*$/) { seen_enable=1 }  # keep as-is
    }
    print
  }
  END {
    if (in && !seen_enable) { print ""Enable=false"" }
    if (!seen_section) {
      print ""[xdmcp]""
      print ""Enable=false""
    }
  }
' ""$CONF"" > ""${CONF}.new""

mv ""${CONF}.new"" ""$CONF""
chown root:root ""$CONF""
chmod 0644 ""$CONF""

# 4) Verify (no Enable=true under [xdmcp])
FAIL=0
# extract [xdmcp] block and check it
if awk '
  BEGIN{in=0; bad=0}
  /^\s*\[/ { in = ($0 ~ /^\s*\[xdmcp\]\s*$/); next }
  in && /^\s*Enable\s*=\s*true\s*$/ { bad=1 }
  END{ exit bad?0:1 }
' ""$CONF""; then
  echo ""FAIL: Found 'Enable=true' under [xdmcp] in $CONF""
  FAIL=1
fi

# If section exists, require Enable=false present
if awk 'BEGIN{in=0; has=0} /^\s*\[/ { in = ($0 ~ /^\s*\[xdmcp\]\s*$/); next } in && /^\s*Enable\s*=\s*false\s*$/ { has=1 } END{exit has?0:1}' ""$CONF""; then
  : # ok
else
  # If section is entirely absent, that is also compliant (disabled)
  if grep -qi '^\s*\[xdmcp\]\s*$' ""$CONF""; then
    echo ""FAIL: [xdmcp] section found but Enable=false not present.""
    FAIL=1
  fi
fi

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: XDMCP is not enabled in GDM (no 'Enable=true' under [xdmcp]) per CIS 1.8.4.""
  exit 0
else
  exit 1
fi"
