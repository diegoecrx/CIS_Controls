"#!/usr/bin/env bash
# 1.4.3 - Ensure authentication required for single user mode (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Locate sulogin
SULOGIN=""""
for c in /sbin/sulogin /usr/sbin/sulogin; do
  [[ -x ""$c"" ]] && { SULOGIN=""$c""; break; }
done
if [[ -z ""$SULOGIN"" ]]; then
  echo ""ERROR: sulogin not found at /sbin/sulogin or /usr/sbin/sulogin."" >&2
  exit 1
fi

# 3) Create systemd drop-ins for rescue and emergency targets
mkdir -p /etc/systemd/system/rescue.service.d /etc/systemd/system/emergency.service.d

RESCUE_DROPIN=""/etc/systemd/system/rescue.service.d/override.conf""
EMERG_DROPIN=""/etc/systemd/system/emergency.service.d/override.conf""

backup_once() { [[ -f ""$1"" && ! -f ""$1.bak-$STAMP"" ]] && cp -p ""$1"" ""$1.bak-$STAMP""; }

backup_once ""$RESCUE_DROPIN""
backup_once ""$EMERG_DROPIN""

# Use a single ExecStart with /bin/sh -c to chain sulogin then return to default target (per CIS text)
cat > ""$RESCUE_DROPIN"" <<EOF
[Service]
ExecStart=
ExecStart=-/bin/sh -c ""$SULOGIN; /usr/bin/systemctl --fail --no-block default""
EOF

cat > ""$EMERG_DROPIN"" <<EOF
[Service]
ExecStart=
ExecStart=-/bin/sh -c ""$SULOGIN; /usr/bin/systemctl --fail --no-block default""
EOF

chmod 0644 ""$RESCUE_DROPIN"" ""$EMERG_DROPIN""
chown root:root ""$RESCUE_DROPIN"" ""$EMERG_DROPIN""

# 4) Reload systemd to pick up drop-ins
systemctl daemon-reload

# 5) Verify: both services must include sulogin in their effective ExecStart
FAIL=0
systemctl cat rescue.service    2>/dev/null | grep -q -- ""$SULOGIN"" || { echo ""FAIL: rescue.service not invoking sulogin.""; FAIL=1; }
systemctl cat emergency.service 2>/dev/null | grep -q -- ""$SULOGIN"" || { echo ""FAIL: emergency.service not invoking sulogin.""; FAIL=1; }

# Additional sanity: drop-ins exist and are readable
[[ -r ""$RESCUE_DROPIN"" ]] || { echo ""FAIL: Missing $RESCUE_DROPIN""; FAIL=1; }
[[ -r ""$EMERG_DROPIN""  ]] || { echo ""FAIL: Missing $EMERG_DROPIN"";  FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: Authentication required for single-user (rescue/emergency) modes via sulogin (CIS 1.4.3).""
  exit 0
else
  exit 1
fi"
