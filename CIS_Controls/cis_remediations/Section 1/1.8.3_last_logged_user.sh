"#!/usr/bin/env bash
# 1.8.3 - Ensure last logged in user display is disabled (GDM) - Oracle Linux 7
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

PROFILE_DIR=""/etc/dconf/profile""
PROFILE_FILE=""${PROFILE_DIR}/gdm""
DB_DIR=""/etc/dconf/db/gdm.d""
DB_FILE=""${DB_DIR}/00-login-screen""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure dconf profile exists
mkdir -p ""$PROFILE_DIR""
[[ -f ""$PROFILE_FILE"" && ! -f ""${PROFILE_FILE}.bak-${STAMP}"" ]] && cp -p ""$PROFILE_FILE"" ""${PROFILE_FILE}.bak-${STAMP}""
cat > ""$PROFILE_FILE"" <<'EOF'
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF
chown root:root ""$PROFILE_FILE""
chmod 0644 ""$PROFILE_FILE""

# 3) Ensure GDM db snippet disables the user list
mkdir -p ""$DB_DIR""
[[ -f ""$DB_FILE"" && ! -f ""${DB_FILE}.bak-${STAMP}"" ]] && cp -p ""$DB_FILE"" ""${DB_FILE}.bak-${STAMP}""
cat > ""$DB_FILE"" <<'EOF'
[org/gnome/login-screen]
# Do not show the user list
disable-user-list=true
EOF
chown root:root ""$DB_FILE""
chmod 0644 ""$DB_FILE""

# 4) Update dconf system databases
if command -v dconf >/dev/null 2>&1; then
  dconf update
else
  echo ""WARN: 'dconf' command not found; install 'dconf' package so changes apply.""
fi

# 5) Verify
FAIL=0
# Profile file lines present
grep -qx 'user-db:user' ""$PROFILE_FILE"" || { echo ""FAIL: $PROFILE_FILE missing user-db:user""; FAIL=1; }
grep -qx 'system-db:gdm' ""$PROFILE_FILE"" || { echo ""FAIL: $PROFILE_FILE missing system-db:gdm""; FAIL=1; }
grep -qx 'file-db:/usr/share/gdm/greeter-dconf-defaults' ""$PROFILE_FILE"" || { echo ""FAIL: $PROFILE_FILE missing file-db line""; FAIL=1; }
# DB file keys present
grep -Eq '^\s*\[org/gnome/login-screen\]\s*$' ""$DB_FILE"" || { echo ""FAIL: $DB_FILE missing section header""; FAIL=1; }
grep -Eq '^\s*disable-user-list\s*=\s*true\s*$' ""$DB_FILE"" || { echo ""FAIL: disable-user-list=true not set""; FAIL=1; }
# Perms
[[ ""$(stat -c '%u:%g' ""$PROFILE_FILE"")"" == ""0:0"" ]] || { echo ""FAIL: $PROFILE_FILE not owned by root:root""; FAIL=1; }
[[ ""$(stat -c '%a' ""$PROFILE_FILE"")"" == ""644"" ]] || { echo ""FAIL: $PROFILE_FILE mode not 0644""; FAIL=1; }
[[ ""$(stat -c '%u:%g' ""$DB_FILE"")"" == ""0:0"" ]] || { echo ""FAIL: $DB_FILE not owned by root:root""; FAIL=1; }
[[ ""$(stat -c '%a' ""$DB_FILE"")"" == ""644"" ]] || { echo ""FAIL: $DB_FILE mode not 0644""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: GDM is configured to hide the last logged-in user list (CIS 1.8.3).""
  echo ""NOTE: Restart GDM (or reboot) for greeter changes to take effect: 'systemctl restart gdm' (if installed).""
  exit 0
else
  exit 1
fi"
