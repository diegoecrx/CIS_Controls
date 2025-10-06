"#!/usr/bin/env bash
# 1.9 - Ensure updates, patches, and additional security software are installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Behavior:
#   - Updates all packages via yum.
#   - Optionally installs 'yum-utils' to use 'needs-restarting -r' for reboot check.
#   - Prints a concise post-update report.
#   - To skip reboot check: export SKIP_REBOOT_CHECK=1

SKIP_REBOOT_CHECK=""${SKIP_REBOOT_CHECK:-0}""

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Network sanity (best effort)
if ! ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 && ! curl -s --max-time 3 https://oracle.com >/dev/null 2>&1; then
  echo ""WARN: Network connectivity check failed; yum update may fail.""
fi

# 3) Update repository metadata (quiet) and apply all updates
yum -y makecache fast >/dev/null 2>&1 || true
yum -y update

# 4) Optional: install yum-utils to detect reboot requirement and list restarted services
if [[ ""$SKIP_REBOOT_CHECK"" != ""1"" ]]; then
  if ! command -v needs-restarting >/dev/null 2>&1; then
    yum -y install yum-utils >/dev/null 2>&1 || true
  fi
fi

# 5) Summarize status
echo ""== Post-update summary ==""
yum -q repolist enabled 2>/dev/null || true
echo
echo ""Kernel: $(uname -r)""
if command -v rpm >/dev/null 2>&1; then
  echo ""Security/SELinux components (installed status):""
  rpm -q libselinux || true
  rpm -q selinux-policy || true
fi

# 6) Reboot required?
REBOOT=0
if [[ ""$SKIP_REBOOT_CHECK"" != ""1"" && -x ""$(command -v needs-restarting || true)"" ]]; then
  if needs-restarting -r >/dev/null 2>&1; then
    REBOOT=0
  else
    REBOOT=1
  fi
fi

# 7) Final result
if [[ $REBOOT -eq 1 ]]; then
  echo ""OK: System packages updated (CIS 1.9). A REBOOT is recommended to complete kernel/critical updates.""
  exit 0
else
  echo ""OK: System packages updated (CIS 1.9).""
  exit 0
fi"
