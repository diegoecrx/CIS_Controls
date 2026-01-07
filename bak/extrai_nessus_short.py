#!/usr/bin/env python3
"""
Extract specific fields from all .nessus files located in the SAME DIRECTORY as this script
and export everything to a single Excel workbook called 'consolidado_scan.xlsx'.

Columns exported (in this order):
  File, IP Address, FQDN, Netbios Name, OS, IP/Name,
  Severity,
  Plugin ID, Plugin Name,
  Plugin Output, Credentialed Check, Credentialed User

Usage:
  python nessus_extract_to_xlsx.py

Notes:
- Works with .nessus (XML v2) exports from Nessus/Tenable.
- Tries multiple host property keys to detect credentialed scan and user.
- Requires: pandas, openpyxl (install with: pip install pandas openpyxl)
"""
from __future__ import annotations

import logging
import sys
from pathlib import Path
from typing import Dict, Iterable, List
import xml.etree.ElementTree as ET

import pandas as pd

# ------------------------------ Logging ------------------------------------
LOG = logging.getLogger("nessus_extract")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


# ------------------------------ Helpers ------------------------------------

def _coalesce(d: Dict[str, str], *keys: str, default: str = "") -> str:
    """Return the first non-empty value from dict `d` among `keys` (case-insensitive)."""
    lower = {k.lower(): v for k, v in d.items() if v is not None}
    for k in keys:
        v = lower.get(k.lower())
        if v is not None and str(v).strip() != "":
            return str(v)
    return default


def _norm_ws(s: str | None) -> str:
    if not s:
        return ""
    return " ".join(str(s).split())


def _boolish(s: str | None) -> bool:
    if s is None:
        return False
    s = s.strip().lower()
    return s in {"true", "yes", "y", "1", "enabled"}


def find_nessus_in_script_dir() -> List[Path]:
    script_dir = Path(__file__).resolve().parent
    files = sorted(script_dir.glob("*.nessus"))
    if not files:
        LOG.warning("No .nessus files found in: %s", script_dir)
    else:
        LOG.info("Found %d .nessus file(s) in %s", len(files), script_dir)
        for f in files:
            LOG.info("- %s", f.name)
    return files


# ------------------------------ Parsing ------------------------------------

def parse_host_properties(host_elem: ET.Element) -> Dict[str, str]:
    props: Dict[str, str] = {}
    hp = host_elem.find("HostProperties")
    if hp is None:
        return props
    for tag in hp.findall("tag"):
        name = tag.get("name") or tag.get("Name") or ""
        value = tag.text or ""
        if name:
            props[name] = value
    return props


def parse_report_item_output(ri: ET.Element) -> str:
    po = ri.find("plugin_output")
    if po is None or po.text is None:
        return ""
    return _norm_ws(po.text)


def parse_text_child(ri: ET.Element, tag: str) -> str:
    elem = ri.find(tag)
    return _norm_ws(elem.text) if (elem is not None and elem.text) else ""


def parse_bool_child_or_attr(ri: ET.Element, tag: str) -> str:
    # Returns "Yes" / "No" using either attribute or child element
    val = ri.get(tag)
    if val is None:
        elem = ri.find(tag)
        val = elem.text if (elem is not None) else None
    return "Yes" if _boolish(val) else (val.strip() if isinstance(val, str) and val.strip() else "No")


def extract_rows_from_file(nessus_path: Path) -> List[Dict[str, object]]:
    LOG.info("Parsing: %s", nessus_path.name)
    try:
        tree = ET.parse(nessus_path)
    except ET.ParseError as e:
        LOG.error("XML parse error in %s: %s", nessus_path, e)
        return []

    root = tree.getroot()
    rows: List[Dict[str, object]] = []

    for report in root.findall("Report"):
        for host in report.findall("ReportHost"):
            host_name = host.get("name") or ""
            props = parse_host_properties(host)

            # Common host properties (case-insensitive lookup via _coalesce)
            ip = _coalesce(
                props,
                "host-ip",
                "Host-IP",
                "host_ip",
                "Host IP",
            )
            fqdn = _coalesce(props, "host-fqdn", "FQDN", "host-fqdn0")
            netbios = _coalesce(props, "netbios-name", "host-netbios-name", "NetBIOS-Name")
            os_name = _coalesce(props, "operating-system", "Operating System", "os")

            # Credentialed scan flags and user (best-effort across exporters)
            cred_flag = _coalesce(
                props,
                "Credentialed_Scan",
                "credentialed_scan",
                "host-credentialed-scan",
                "local_checks_enabled",
                "Local Checks Enabled",
            )
            credentialed_check = "Yes" if _boolish(cred_flag) else "No"

            credentialed_user = _coalesce(
                props,
                # Seen in some exports when SSH auth is used
                "ssh-login-used",
                "ssh_login_used",
                # Seen in some Windows/SMB contexts
                "smb-login-used",
                "host-smb-login-used",
                # Occasionally present as a generic field
                "credentialed_user",
                "local_checks_user",
            )

            ip_or_name = ip or host_name

            for ri in host.findall("ReportItem"):
                severity_id = (ri.get("severity") or "").strip()

                plugin_id = ri.get("pluginID") or ri.get("plugin_id") or ""
                plugin_name = ri.get("pluginName") or ri.get("plugin_name") or parse_text_child(ri, "plugin_name")
                plugin_output = parse_report_item_output(ri)

                row = {
                    "File": nessus_path.name,
                    "IP Address": ip,
                    "FQDN": fqdn,
                    "Netbios Name": netbios,
                    "OS": os_name,
                    "IP/Name": ip_or_name,
                    "Severity": severity_id,
                    "Plugin ID": plugin_id,
                    "Plugin Name": plugin_name,
                    "Plugin Output": plugin_output,
                    "Credentialed Check": credentialed_check,
                    "Credentialed User": credentialed_user,
                }
                rows.append(row)

    return rows


# ------------------------------ Excel Output --------------------------------

def write_to_xlsx(rows: List[Dict[str, object]], out_path: Path) -> None:
    if not rows:
        LOG.warning("No rows to write. Creating an empty workbook with headers.")

    columns = [
        "File",
        "IP Address",
        "FQDN",
        "Netbios Name",
        "OS",
        "IP/Name",
        "Severity",
        "Plugin ID",
        "Plugin Name",
        "Plugin Output",
        "Credentialed Check",
        "Credentialed User",
    ]

    df = pd.DataFrame(rows, columns=columns)

    with pd.ExcelWriter(out_path, engine="openpyxl") as writer:
        sheet_name = "Nessus Export"
        df.to_excel(writer, index=False, sheet_name=sheet_name)

        # Basic formatting via openpyxl
        wb = writer.book
        ws = writer.sheets[sheet_name]

        # Freeze header row and set auto-filter
        ws.freeze_panes = "A2"
        ws.auto_filter.ref = ws.dimensions

        # Adjust column widths (simple heuristic)
        widths = {
            "A": 24,  # File
            "B": 16,  # IP Address
            "C": 40,  # FQDN
            "D": 28,  # Netbios Name
            "E": 28,  # OS
            "F": 28,  # IP/Name
            "G": 10,  # Severity (0-4)
            "H": 12,  # Plugin ID
            "I": 36,  # Plugin Name
            "J": 80,  # Plugin Output
            "K": 18,  # Credentialed Check
            "L": 24,  # Credentialed User
        }
        for col, width in widths.items():
            ws.column_dimensions[col].width = width

        # Wrap text for long text columns
        from openpyxl.styles import Alignment

        for col_letter in ("I", "J"):
            for cell in ws[col_letter]:
                cell.alignment = Alignment(wrap_text=True, vertical="top")

        # Align headers
        for cell in ws[1]:
            cell.alignment = Alignment(horizontal="center", vertical="center")


# ------------------------------ Main ----------------------------------------

def main() -> int:
    inputs = find_nessus_in_script_dir()
    if not inputs:
        LOG.error("No .nessus inputs found alongside the script. Place .nessus files in the same folder.")
        return 2

    all_rows: List[Dict[str, object]] = []
    for fp in inputs:
        rows = extract_rows_from_file(fp)
        LOG.info("Collected %d rows from %s", len(rows), fp.name)
        all_rows.extend(rows)

    out_path = Path(__file__).resolve().parent / "consolidado_scan.xlsx"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    write_to_xlsx(all_rows, out_path)

    LOG.info("Wrote %d rows to %s", len(all_rows), out_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())