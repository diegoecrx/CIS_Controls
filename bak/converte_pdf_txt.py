#!/usr/bin/env python3
"""
converte_pdf_txt.py

Uses the extractor implemented in converte_pdf_xlsx.py to parse CIS PDF benchmarks
and export a plain text CSV-style file with columns:
  id, Name of control, Profile Applicability, Remediation, Default Value

Behavior:
 - Imports extrair_cis_sections() from converte_pdf_xlsx.py (assumes the file is
   reachable in the same directory or a provided path).
 - Produces a single-line-per-record CSV-style text file. Internal newlines in fields
   are replaced with the literal sequence '\n' to keep records one-line each.
 - Fields are written in the exact order requested.
"""
from __future__ import annotations

import argparse
import csv
import logging
import os
import sys
import time
from pathlib import Path
from typing import List, Dict

# Attempt to import the parser module from the same directory as this script or current working dir.
# This allows reuse of your existing extraction logic in converte_pdf_xlsx.py.
SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

try:
    import converte_pdf_xlsx  # type: ignore
    extrair_cis_sections = getattr(converte_pdf_xlsx, "extrair_cis_sections")
except Exception as e:
    # Try to import by filename fallback (if the file is located at /mnt/data)
    alt_path = Path("/mnt/data/converte_pdf_xlsx.py")
    if alt_path.exists():
        alt_dir = str(alt_path.parent)
        if alt_dir not in sys.path:
            sys.path.insert(0, alt_dir)
        try:
            import converte_pdf_xlsx  # type: ignore
            extrair_cis_sections = getattr(converte_pdf_xlsx, "extrair_cis_sections")
        except Exception as e2:
            raise ImportError(
                "Failed to import extrair_cis_sections from converte_pdf_xlsx.py. "
                "Ensure converte_pdf_xlsx.py is in the same directory or /mnt/data."
            ) from e2
    else:
        raise ImportError(
            "converte_pdf_xlsx.py not found in the script directory or /mnt/data. "
            "Place converte_pdf_xlsx.py next to this script or adjust the path."
        ) from e

# --- Logging ---
logger = logging.getLogger("converte_pdf_txt")
logger.setLevel(logging.INFO)
_handler = logging.StreamHandler(sys.stdout)
_handler.setFormatter(logging.Formatter("%(asctime)s | %(levelname)s | %(message)s", "%Y-%m-%d %H:%M:%S"))
logger.addHandler(_handler)


def _sanitize_field(s: str) -> str:
    """
    Prepare field for one-line CSV output:
      - Normalize spaces
      - Replace internal newlines with literal '\n'
      - Strip leading/trailing whitespace
    """
    if s is None:
        return ""
    # convert CR/LF to LF, then replace LF with literal two chars \n
    s2 = s.replace("\r\n", "\n").replace("\r", "\n")
    s2 = s2.replace("\n", "\\n")
    # collapse multiple spaces
    s2 = " ".join(s2.split())
    return s2.strip()


def export_to_txt(rows: List[Dict[str, str]], out_path: str) -> None:
    """
    Write rows to a text file with CSV formatting and the following columns (in order):
      id, Name of control, Profile Applicability, Remediation, Default Value
    """
    HEADER = ["id", "Name of control", "Profile Applicability", "Remediation", "Default Value"]
    out_path = Path(out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Use newline='' with csv to avoid double newlines on Windows
    with out_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        # write header (optional — if you don't want a header, remove this line)
        writer.writerow(HEADER)

        for item in rows:
            id_ = _sanitize_field(item.get("ID", "") or item.get("Id", "") or "")
            nome = _sanitize_field(item.get("Nome Completo", "") or item.get("Name", "") or "")
            profile = _sanitize_field(item.get("Profile Applicability", "") or item.get("Profile", ""))
            remediation = _sanitize_field(item.get("Remediation", ""))
            default_value = _sanitize_field(item.get("Default Value", "") or item.get("Default", ""))

            writer.writerow([id_, nome, profile, remediation, default_value])


def parse_args(argv=None):
    ################################################################################################################
    p = argparse.ArgumentParser(description="Convert CIS PDF -> plain text (CSV-style) using existing parser.")
    p.add_argument("--pdf", required=False, default="CIS_Oracle_Linux_7_Benchmark_v4.0.0_ARCHIVE.pdf", help="Input PDF path.")
    p.add_argument("--out", required=False, default="cis_parsed.txt", help="Output text file path.")
    p.add_argument("-v", "--verbose", action="count", default=0, help="Increase verbosity.")
    return p.parse_args(argv)


def main():
    args = parse_args()
    if args.verbose:
        logger.setLevel(logging.DEBUG)
        logger.debug("Verbose logging enabled.")

    pdf_path = str(Path(args.pdf).expanduser())
    out_path = str(Path(args.out).expanduser())

    logger.info("PDF input: %s", pdf_path)
    logger.info("Text output: %s", out_path)

    if not Path(pdf_path).exists():
        logger.error("PDF file not found: %s", pdf_path)
        return 2

    t0 = time.perf_counter()
    try:
        logger.info("Calling PDF extractor...")
        dados = extrair_cis_sections(pdf_path)
        logger.info("Extractor returned %d items", len(dados) if dados is not None else 0)
        export_to_txt(dados or [], out_path)
        logger.info("Export completed. Wrote %s", out_path)
    except Exception as e:
        logger.exception("Failed during processing: %s", e)
        return 1
    finally:
        logger.info("Total time: %.3fs", time.perf_counter() - t0)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
