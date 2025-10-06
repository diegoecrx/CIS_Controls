"#!/usr/bin/env bash
# 1.8.2 - Ensure GDM login banner is configured (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=0
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# You may override the banner text at runtime:
#   BANNER_TEXT='Authorized users only. All activity may be monitored and reported.' ./1.8.2_gdm_banner.sh
BANNER_TEXT=""${BANNER_TEXT:-Authorized users only. All activity may be monitored and reported.}""

PROFILE_DIR=""/etc/dconf/profile""
PROFILE_FILE=""${PROFILE_DIR}/gdm""
DB_DIR=""/etc/dconf/db/gdm.d""
DB_FILE=""${DB_DIR}/01-banner-message""
STAMP=""$(date +%Y%m%d%H%M%S)""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Ensure dconf profile for GDM exists
mkdir -p ""$PROFILE_DIR""
if [[ -f ""$PROFILE_FILE"" && ! -f ""${PROFILE_FILE}.bak-${STAMP}"" ]]; then
  cp -p ""$PROFILE_FILE"" ""${PROFILE_FILE}.bak-${STAMP}""
fi
cat > ""$PROFILE_FILE"" <<'EOF'
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF
chown root:root ""$PROFILE_FILE""
chmod 0644 ""$PROFILE_FILE""

# 3) Ensure system database snippet exists with required keys
mkdir -p ""$DB_DIR""
if [[ -f ""$DB_FILE"" && ! -f ""${DB_FILE}.bak-${STAMP}"" ]]; then
  cp -p ""$DB_FILE"" ""${DB_FILE}.bak-${STAMP}""
fi

# Escape single quotes for dconf string literal
banner_escaped=""${BANNER_TEXT//\'/\x27}""  # dconf accepts raw '

cat > ""$DB_FILE"" <<EOF
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='${banner_escaped}'
EOF

chown root:root ""$DB_FILE""
chmod 0644 ""$DB_FILE""

# 4) Update dconf system databases
if command -v dconf >/dev/null 2>&1; then
  dconf update
else
  echo ""WARN: 'dconf' command not found; install 'dconf' package to apply system database.""
fi

# 5) Verify (file-level + update exit code best-effort)
FAIL=0
# profile file content check
grep -qx 'user-db:user' ""$PROFILE_FILE"" || { echo ""FAIL: $PROFILE_FILE missing user-db:user""; FAIL=1; }
grep -qx 'system-db:gdm' ""$PROFILE_FILE"" || { echo ""FAIL: $PROFILE_FILE missing system-db:gdm""; FAIL=1; }
grep -qx 'file-db:/usr/share/gdm/greeter-dconf-defaults' ""$PROFILE_FILE"" || { echo ""FAIL: $PROFILE_FILE missing file-db line""; FAIL=1; }

# db file key checks
grep -Eq '^\s*\[org/gnome/login-screen\]\s*$' ""$DB_FILE"" || { echo ""FAIL: $DB_FILE missing [org/gnome/login-screen]""; FAIL=1; }
grep -Eq '^\s*banner-message-enable\s*=\s*true\s*$' ""$DB_FILE"" || { echo ""FAIL: banner-message-enable not true""; FAIL=1; }
# verify text presence (not exact escape-sensitive compare)
grep -Fq ""$BANNER_TEXT"" ""$DB_FILE"" || { echo ""FAIL: banner-message-text does not contain expected text""; FAIL=1; }

# permissions
[[ ""$(stat -c '%u:%g' ""$PROFILE_FILE"")"" == ""0:0"" ]] || { echo ""FAIL: $PROFILE_FILE not owned by root:root""; FAIL=1; }
[[ ""$(stat -c '%a' ""$PROFILE_FILE"")"" == ""644"" ]] || { echo ""FAIL: $PROFILE_FILE mode not 0644""; FAIL=1; }
[[ ""$(stat -c '%u:%g' ""$DB_FILE"")"" == ""0:0"" ]] || { echo ""FAIL: $DB_FILE not owned by root:root""; FAIL=1; }
[[ ""$(stat -c '%a' ""$DB_FILE"")"" == ""644"" ]] || { echo ""FAIL: $DB_FILE mode not 0644""; FAIL=1; }

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: GDM banner configured via dconf (CIS 1.8.2).""
  echo ""NOTE: Restart GDM (or reboot) for greeter to show updated banner: 'systemctl restart gdm' (if installed).""
  exit 0
else
  exit 1
fi"
