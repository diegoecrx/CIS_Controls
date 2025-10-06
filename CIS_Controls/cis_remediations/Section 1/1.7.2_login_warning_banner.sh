"#!/usr/bin/env bash
# 1.7.2 - Ensure local login warning banner is configured properly (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

ISSUE=""/etc/issue""
STAMP=""$(date +%Y%m%d%H%M%S)""

# Optional: override the banner text (single line recommended)
BANNER_TEXT=""${BANNER_TEXT:-WARNING: Authorized use only. This system may be monitored. By continuing, you consent to monitoring and applicable policies.}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Create baseline if missing; back up if present
if [[ -f ""$ISSUE"" ]]; then
  cp -p ""$ISSUE"" ""${ISSUE}.bak-${STAMP}""
else
  install -m 0644 -o root -g root /dev/null ""$ISSUE""
  printf '%s\n' ""$BANNER_TEXT"" > ""$ISSUE""
fi

# 3) Sanitize /etc/issue:
#    - Remove dynamic escapes: \m \r \s \v
#    - Remove common OS/platform references (Oracle Linux, Oracle, Red Hat, CentOS, Linux, RHEL, OLx, kernel, release, version)
#    - Normalize whitespace; squeeze blank lines
tmp=""$(mktemp)""
sed -r \
  -e 's@\\[mrs v]@@g' \
  -e 's@(^|[^A-Za-z])(Oracle Linux|Oracle|Red[[:space:]]*Hat|CentOS|Linux|RHEL|OL[[:digit:]]+|kernel|release|version)([^A-Za-z]|$)@\1\3@gI' \
  -e 's/[[:space:]]{2,}/ /g' \
  -e 's/^[[:space:]]+//; s/[[:space:]]+$//' \
  ""$ISSUE"" > ""$tmp""
awk 'NF{blank=0} !NF{if(blank) next; blank=1} {print}' ""$tmp"" > ""${tmp}.2""
mv ""${tmp}.2"" ""$ISSUE""
rm -f ""$tmp""

# 4) Secure permissions
chown root:root ""$ISSUE""
chmod 0644 ""$ISSUE""

# 5) Verify
FAIL=0
# Must exist
[[ -f ""$ISSUE"" ]] || { echo ""FAIL: $ISSUE not present.""; FAIL=1; }
# No dynamic escapes
grep -Eq '\\[mrs v]' ""$ISSUE"" && { echo ""FAIL: $ISSUE contains forbidden escape sequences (\\m, \\r, \\s, \\v).""; FAIL=1; }
# No OS/platform references (case-insensitive)
grep -Ei '(oracle linux|oracle|red[[:space:]]*hat|centos|linux|rhel|ol[0-9]+|kernel|release|version)' ""$ISSUE"" >/dev/null && {
  echo ""FAIL: $ISSUE contains OS/platform references.""; FAIL=1; }
# Ownership/permissions
[[ ""$(stat -c '%u:%g' ""$ISSUE"")"" == ""0:0"" ]] || { echo ""FAIL: $ISSUE not owned by root:root.""; FAIL=1; }
[[ ""$(stat -c '%a' ""$ISSUE"")"" == ""644"" ]] || { echo ""FAIL: $ISSUE mode not 0644.""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /etc/issue present and sanitized (no escapes or OS references) per CIS 1.7.2.""
  exit 0
else
  exit 1
fi"
