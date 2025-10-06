"#!/usr/bin/env bash
# 1.7.1 - Ensure message of the day is configured properly (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

MOTD=""/etc/motd""
STAMP=""$(date +%Y%m%d%H%M%S)""

# Behavior:
#   - MOTD_MODE=present (default): sanitize existing /etc/motd or create a minimal compliant banner.
#   - MOTD_MODE=absent : remove /etc/motd as allowed by CIS text.
MOTD_MODE=""${MOTD_MODE:-present}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

case ""$MOTD_MODE"" in
  present)
    # 2) Create baseline if missing; back up if present
    if [[ -f ""$MOTD"" ]]; then
      cp -p ""$MOTD"" ""${MOTD}.bak-${STAMP}""
    else
      install -m 0644 -o root -g root /dev/null ""$MOTD""
      cat > ""$MOTD"" <<'EOF'
WARNING: Authorized use only. This system may be monitored. By continuing, you consent to monitoring and to applicable policies.
EOF
    fi

    # 3) Sanitize content:
    #    - Remove dynamic escapes: \m \r \s \v
    #    - Remove common OS/platform references (Linux, Oracle, Red Hat, CentOS, kernel, release, version, RHEL/OL short forms)
    #    - Collapse duplicate spaces
    tmp=""$(mktemp)""
    sed -r \
      -e 's@\\[mrs v]@@g' \
      -e 's@(^|[^A-Za-z])(Oracle Linux|Oracle|Red[[:space:]]*Hat|CentOS|Linux|RHEL|OL[[:digit:]]+|kernel|release|version)([^A-Za-z]|$)@\1\3@gI' \
      -e 's/[[:space:]]{2,}/ /g' \
      -e 's/^[[:space:]]+//; s/[[:space:]]+$//' \
      ""$MOTD"" > ""$tmp""
    # Trim empty lines at start/end and squeeze consecutive blank lines
    awk 'NF{blank=0} !NF{if(blank) next; blank=1} {print}' ""$tmp"" > ""${tmp}.2""
    mv ""${tmp}.2"" ""$MOTD""
    rm -f ""$tmp""

    # 4) Secure permissions
    chown root:root ""$MOTD""
    chmod 0644 ""$MOTD""

    # 5) Verify
    FAIL=0
    # Must exist
    [[ -f ""$MOTD"" ]] || { echo ""FAIL: $MOTD not present.""; FAIL=1; }
    # No dynamic escapes
    if grep -Eq '\\[mrs v]' ""$MOTD""; then
      echo ""FAIL: $MOTD contains forbidden escape sequences (\\m, \\r, \\s, \\v).""
      FAIL=1
    fi
    # No OS/platform words (case-insensitive)
    if grep -Ei '(oracle linux|oracle|red[[:space:]]*hat|centos|linux|rhel|ol[0-9]+|kernel|release|version)' ""$MOTD"" >/dev/null; then
      echo ""FAIL: $MOTD contains OS/platform references.""
      FAIL=1
    fi
    # Ownership/permissions
    [[ ""$(stat -c '%u:%g' ""$MOTD"")"" == ""0:0"" ]] || { echo ""FAIL: $MOTD not owned by root:root.""; FAIL=1; }
    [[ ""$(stat -c '%a' ""$MOTD"")"" == ""644"" ]] || { echo ""FAIL: $MOTD mode not 0644.""; FAIL=1; }

    if [[ $FAIL -eq 0 ]]; then
      echo ""OK: /etc/motd present and sanitized (no escapes or OS references) per CIS 1.7.1.""
      exit 0
    else
      exit 1
    fi
    ;;

  absent)
    # 2) Remove the motd file
    if [[ -e ""$MOTD"" ]]; then
      rm -f ""$MOTD""
    fi
    # 3) Verify
    if [[ ! -e ""$MOTD"" ]]; then
      echo ""OK: /etc/motd removed as permitted by CIS 1.7.1.""
      exit 0
    else
      echo ""FAIL: Could not remove $MOTD.""
      exit 1
    fi
    ;;

  *)
    echo ""ERROR: MOTD_MODE must be 'present' or 'absent'."" >&2
    exit 2
    ;;
esac"
