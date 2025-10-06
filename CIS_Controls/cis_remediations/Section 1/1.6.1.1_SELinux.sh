"#!/usr/bin/env bash
# 1.6.1.1 - Ensure SELinux is installed (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# Primary package per CIS text
REQUIRED_PKGS=(libselinux)

# 1) Require root
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root."" >&2
  exit 1
fi

# 2) Install required package(s) if missing (idempotent)
MISSING=0
for p in ""${REQUIRED_PKGS[@]}""; do
  if ! rpm -q ""$p"" >/dev/null 2>&1; then
    MISSING=1
  fi
done

if [[ $MISSING -eq 1 ]]; then
  yum -y install ""${REQUIRED_PKGS[@]}""
fi

# 3) Verify
FAIL=0
for p in ""${REQUIRED_PKGS[@]}""; do
  rpm -q ""$p"" >/dev/null 2>&1 || { echo ""FAIL: package not installed: $p""; FAIL=1; }
done

if [[ $FAIL -eq 0 ]]; then
  echo ""OK: SELinux base package(s) installed (CIS 1.6.1.1).""
  exit 0
else
  exit 1
fi"
