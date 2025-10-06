"#!/usr/bin/env bash
# 1.5.2 - Ensure XD/NX support is enabled (Oracle Linux 7)
# Flags (metadata only; not enforced here)
APPLIES_L1=1
APPLIES_L2=1
APPLIES_SERVER=1
APPLIES_WORKSTATION=1

set -euo pipefail

# 1) Require root (to read full kernel logs; audit still runs if not root but may miss lines)
if [[ $EUID -ne 0 ]]; then
  echo ""ERROR: Run as root for complete kernel log access."" >&2
  exit 1
fi

ARCH=""$(uname -m)""
HAS_NX=0
HAS_PAE=0
NX_DISABLED_MSG=0
NX_ENABLED_MSG=0

# 2) Detect CPU feature flags
grep -m1 -wo nx  /proc/cpuinfo >/dev/null 2>&1 && HAS_NX=1 || HAS_NX=0
grep -m1 -wo pae /proc/cpuinfo >/dev/null 2>&1 && HAS_PAE=1 || HAS_PAE=0

# 3) Inspect kernel messages for NX status (different kernels log slightly different strings)
#    Prefer journalctl -k when available, fallback to dmesg.
KLOG=""$( (command -v journalctl >/dev/null 2>&1 && journalctl -k --no-pager 2>/dev/null) || dmesg 2>/dev/null || true )""

# Common enable messages
grep -Ei 'NX .* (active|enabled)|Execute Disable.*(active|enabled)' <<<""$KLOG"" >/dev/null && NX_ENABLED_MSG=1 || true
# Common disable messages
grep -Ei 'NX .* disabled|Execute Disable.*disabled|NX.*:.*disabled by BIOS' <<<""$KLOG"" >/dev/null && NX_DISABLED_MSG=1 || true

# 4) Evaluate per-arch
FAIL=0
echo ""Architecture: $ARCH""
echo ""CPU flags: nx=$( [[ $HAS_NX -eq 1 ]] && echo yes || echo no ), pae=$( [[ $HAS_PAE -eq 1 ]] && echo yes || echo no )""
[[ $NX_ENABLED_MSG -eq 1 ]] && echo ""Kernel log: NX appears ENABLED""
[[ $NX_DISABLED_MSG -eq 1 ]] && echo ""Kernel log: NX appears DISABLED""

case ""$ARCH"" in
  x86_64|amd64)
    # 64-bit: NX should exist and be enabled by default if supported/allowed by firmware
    if [[ $HAS_NX -ne 1 ]]; then
      echo ""FAIL: CPU does not advertise NX (XD) support on a 64-bit kernel.""
      FAIL=1
    fi
    if [[ $NX_DISABLED_MSG -eq 1 ]]; then
      echo ""FAIL: Kernel reports NX/XD disabled (likely BIOS/UEFI setting).""
      FAIL=1
    fi
    ;;
  i386|i486|i586|i686)
    # 32-bit: require PAE kernel and NX-capable CPU/firmware
    if [[ $HAS_PAE -ne 1 ]]; then
      echo ""FAIL: CPU/kernel not reporting PAE on 32-bit system.""
      FAIL=1
    fi
    if [[ $HAS_NX -ne 1 ]]; then
      echo ""FAIL: CPU does not advertise NX (XD) support on 32-bit system.""
      FAIL=1
    fi
    if [[ $NX_DISABLED_MSG -eq 1 ]]; then
      echo ""FAIL: Kernel reports NX/XD disabled (likely BIOS/UEFI setting).""
      FAIL=1
    fi
    ;;
  *)
    echo ""INFO: Unrecognized arch '$ARCH'. Checking NX flag and kernel messages generically.""
    if [[ $HAS_NX -ne 1 || $NX_DISABLED_MSG -eq 1 ]]; then
      echo ""FAIL: NX not present or disabled.""
      FAIL=1
    fi
    ;;
esac

# 5) Result
if [[ $FAIL -eq 0 ]]; then
  echo ""OK: XD/NX is supported and not reported as disabled (CIS 1.5.2).""
  exit 0
else
  cat <<'HINTS'
Remediation hints:
  - Ensure NX/XD is ENABLED in BIOS/UEFI (sometimes called ""Execute Disable Bit"" or ""No eXecute Memory Protection"").
  - On 32-bit Oracle Linux 7, install a PAE-enabled kernel and boot it:
      yum install kernel-PAE
      # then update grub and reboot into the PAE kernel
  - After firmware/kernel changes, reboot and re-run this check.
HINTS
  exit 1
fi"
