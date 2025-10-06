"#!/usr/bin/env bash
# 1.7.3 - Ensure remote login warning banner is configured properly (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

ISSUE_NET=""/etc/issue.net""
STAMP=""$(date +%Y%m%d%H%M%S)""

# Optional: override the banner text (single line recommended)
BANNER_TEXT=""${BANNER_TEXT:-WARNING: Authorized use only. This system may be monitored. By continuing, you consent to monitoring and applicable policies.}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Create baseline if missing; back up if present
if [[ -f ""$ISSUE_NET"" ]]; then
  cp -p ""$ISSUE_NET"" ""${ISSUE_NET}.bak-${STAMP}""
else
  install -m 0644 -o root -g root /dev/null ""$ISSUE_NET""
  printf '%s\n' ""$BANNER_TEXT"" > ""$ISSUE_NET""
fi

# 3) Sanitize /etc/issue.net:
#    - Remove dynamic escapes: \m \r \s \v
#    - Remove OS/platform references (Oracle Linux, Oracle, Red Hat, CentOS, Linux, RHEL, OLx, kernel, release, version)
#    - Normalize whitespace; squeeze blank lines
tmp=""$(mktemp)""
sed -r \
  -e 's@\\[mrs v]@@g' \
  -e 's@(^|[^A-Za-z])(Oracle Linux|Oracle|Red[[:space:]]*Hat|CentOS|Linux|RHEL|OL[[:digit:]]+|kernel|release|version)([^A-Za-z]|$)@\1\3@gI' \
  -e 's/[[:space:]]{2,}/ /g' \
  -e 's/^[[:space:]]+//; s/[[:space:]]+$//' \
  ""$ISSUE_NET"" > ""$tmp""
awk 'NF{blank=0} !NF{if(blank) next; blank=1} {print}' ""$tmp"" > ""${tmp}.2""
mv ""${tmp}.2"" ""$ISSUE_NET""
rm -f ""$tmp""

# 4) Secure permissions
chown root:root ""$ISSUE_NET""
chmod 0644 ""$ISSUE_NET""

# 5) Verify
FAIL=0
[[ -f ""$ISSUE_NET"" ]] || { echo ""FAIL: $ISSUE_NET not present.""; FAIL=1; }
grep -Eq '\\[mrs v]' ""$ISSUE_NET"" && { echo ""FAIL: $ISSUE_NET contains forbidden escape sequences (\\m, \\r, \\s, \\v).""; FAIL=1; }
grep -Ei '(oracle linux|oracle|red[[:space:]]*hat|centos|linux|rhel|ol[0-9]+|kernel|release|version)' ""$ISSUE_NET"" >/dev/null && {
  echo ""FAIL: $ISSUE_NET contains OS/platform references.""; FAIL=1; }
[[ ""$(stat -c '%u:%g' ""$ISSUE_NET"")"" == ""0:0"" ]] || { echo ""FAIL: $ISSUE_NET not owned by root:root.""; FAIL=1; }
[[ ""$(stat -c '%a' ""$ISSUE_NET"")"" == ""644"" ]] || { echo ""FAIL: $ISSUE_NET mode not 0644.""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: /etc/issue.net present and sanitized (no escapes or OS references) per CIS 1.7.3.""
  exit 0
else
  exit 1
fi"
