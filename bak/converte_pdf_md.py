# converte_pdf_md.py
# Requires: pandas, PyMuPDF (pymupdf)
# pip install pandas pymupdf

import argparse
import logging
import sys
import time
from pathlib import Path
from typing import Dict, List, Tuple
import re

# --- PyMuPDF import (works across versions) ---
try:
    import pymupdf as fitz  # modern import name
except Exception:
    import fitz  # legacy module name

import pandas as pd

# === Known section headers in CIS PDFs ===
SECTION_NAMES = [
    "Profile Applicability",
    "Description",
    "Rationale",
    "Impact",
    "Audit",
    "Remediation",
    "Default Value",
    "References",
]
SECTION_REGEXES = {name: re.compile(rf"^{re.escape(name)}:?$", re.IGNORECASE) for name in SECTION_NAMES}

# Section IDs
ID_RELAXED_RE = re.compile(r"^(\d+(?:\.\d+){0,6})\b")   # allow "2" or "2.1.1"
ID_STRICT_RE = re.compile(r"^(\d+(?:\.\d+)+)\b")        # at least one dot

# Fallback ToC detectors
TOC_LINE_RE = re.compile(r"^(\d+(?:\.\d+){0,6})\s+(.+?)\s*$")
# NEW: capture dotted leaders + final page number (e.g., "6.2.16 Title ....... 597")
TOC_DOTTED_RE = re.compile(
    r"^(\d+(?:\.\d+){0,6})\s+(.+?)\s*\.{2,}\s*(\d+)\s*$"
)

logger = logging.getLogger("cis_pdf_parser")


# ----------------------- Logging -----------------------
def setup_logging(verbosity: int, log_file: str | None) -> None:
    level = logging.INFO if verbosity <= 0 else logging.DEBUG
    fmt = "%(asctime)s | %(levelname)s | %(message)s"
    datefmt = "%Y-%m-%d %H:%M:%S"

    for h in list(logger.handlers):
        logger.removeHandler(h)

    logger.setLevel(level)
    console = logging.StreamHandler(sys.stdout)
    console.setLevel(level)
    console.setFormatter(logging.Formatter(fmt=fmt, datefmt=datefmt))
    logger.addHandler(console)

    if log_file:
        fh = logging.FileHandler(log_file, encoding="utf-8")
        fh.setLevel(level)
        fh.setFormatter(logging.Formatter(fmt=fmt, datefmt=datefmt))
        logger.addHandler(fh)

    logger.debug("Logger initialized (level=%s, log_file=%s)", logging.getLevelName(level), log_file)


# ----------------------- Helpers -----------------------
def _normalize_line(s: str) -> str:
    # Mantido o comportamento original + remoção explícita do bullet U+F0B7 ("")
    s = s.replace("\u2028", " ").replace("\u00AD", "")
    # remove/normaliza o bullet "" (alguns PDFs usam esse codepoint via fontes Wingdings/Symbol)
    s = s.replace("\uf0b7", " ")
    # colapsa eventuais ocorrências repetidas do bullet + espaços
    s = re.sub(r"[ \t]*\uf0b7[ \t]*", " ", s)
    # normaliza espaços
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def _starts_with_section(line: str) -> str:
    txt = line.strip()
    for name, rx in SECTION_REGEXES.items():
        if rx.match(txt):
            return name
    return ""


def _find_section_boundaries(lines: List[str], start_idx: int, end_idx: int) -> Dict[str, int]:
    indices = {name: -1 for name in SECTION_NAMES}
    for j in range(start_idx, end_idx):
        raw = lines[j].strip()
        if not raw:
            continue
        if ID_STRICT_RE.match(raw) and j != start_idx:
            break
        sec = _starts_with_section(raw)
        if sec and indices[sec] == -1:
            indices[sec] = j
    return indices


def _next_id_or_end(lines: List[str], start: int, end_idx: int) -> int:
    for p in range(start, end_idx):
        if ID_STRICT_RE.match(lines[p].strip()):
            return p
    return end_idx


def _extract_block(lines: List[str], start: int, end: int) -> str:
    if start < 0:
        return ""
    end = min(end, len(lines))
    block = "\n".join(_normalize_line(ln) for ln in lines[start:end])
    return block.strip()


# ----------------------- PDF text collection + footer cleaner -----------------------
def _clean_rodape_lines(lines: List[str]) -> List[str]:
    cleaned = []
    skip_controls_block = False
    for line in lines:
        txt = line.strip()

        # Remove page footer like "21 | P a g e" or "Page 21"
        if re.match(r"^\d+\s*\|\s*P\s*a\s*g\s*e$", txt, re.IGNORECASE) or re.match(r"^Page\s+\d+$", txt, re.IGNORECASE):
            continue

        # Remove "CIS Controls" footer block lines
        if re.match(r"^CIS\s+Controls:?\s*$", txt, re.IGNORECASE):
            skip_controls_block = True
            continue

        if skip_controls_block:
            if txt.lower() in {"controls", "version", "control", "ig 1 ig 2 ig 3", "v8", 'v8"'}:
                continue
            skip_controls_block = False

        cleaned.append(line)
    return cleaned


def _collect_all_lines(pdf_path: str) -> List[str]:
    logger.info("Opening PDF: %s", pdf_path)
    lines: List[str] = []
    with fitz.open(pdf_path) as doc:
        logger.info("PDF opened. Pages: %d", doc.page_count)
        for pno, page in enumerate(doc, start=1):
            text = page.get_text()
            page_lines = _clean_rodape_lines(text.splitlines())
            lines.extend(page_lines)
            lines.append("")
            if pno % 10 == 0:
                logger.debug("Processed %d pages (cumulative lines: %d)", pno, len(lines))
    logger.info("Collected %d lines from PDF", len(lines))
    return lines


# ----------------------- CIS sections extractor (existing behavior) -----------------------
def extrair_cis_sections(pdf_path: str) -> List[Dict[str, str]]:
    start_t = time.perf_counter()
    lines = _collect_all_lines(pdf_path)
    total = len(lines)
    resultados: List[Dict[str, str]] = []

    logger.info("Starting parse loop over %d lines", total)
    found_items = 0
    kept_items = 0

    i = 0
    while i < total:
        line = lines[i].strip()

        if ID_STRICT_RE.match(line):
            found_items += 1
            title_lines = [line]
            j = i + 1
            while j < total:
                nxt = lines[j].strip()
                if _starts_with_section(nxt) or ID_STRICT_RE.match(nxt):
                    break
                if nxt:
                    title_lines.append(nxt)
                j += 1
            full_name = _normalize_line(" ".join(title_lines))

            end_of_item = _next_id_or_end(lines, j, total)
            indices = _find_section_boundaries(lines, j, end_of_item)

            boundaries: Dict[str, Tuple[int, int]] = {}
            present_sections = [s for s in SECTION_NAMES if indices[s] != -1]
            present_sections_sorted = sorted(present_sections, key=lambda s: indices[s])

            next_boundary_after = {}
            for idx, sec in enumerate(present_sections_sorted):
                start_at = indices[sec]
                if idx + 1 < len(present_sections_sorted):
                    next_boundary_after[start_at] = indices[present_sections_sorted[idx + 1]]
                else:
                    next_boundary_after[start_at] = end_of_item

            if indices["Remediation"] != -1:
                start_r = indices["Remediation"] + 1
                end_r = indices["Default Value"] if indices["Default Value"] != -1 else next_boundary_after[indices["Remediation"]]
                boundaries["Remediation"] = (start_r, end_r)

            if indices["Default Value"] != -1:
                start_dv = indices["Default Value"] + 1
                end_dv = indices["References"] if indices["References"] != -1 else next_boundary_after[indices["Default Value"]]
                boundaries["Default Value"] = (start_dv, end_dv)

            for sec in ["Profile Applicability", "Description", "Rationale", "Impact", "Audit"]:
                if indices[sec] != -1 and sec not in boundaries:
                    start = indices[sec] + 1
                    end = next_boundary_after[indices[sec]]
                    boundaries[sec] = (start, end)

            contents = {s: "" for s in SECTION_NAMES}
            for sec, (sidx, eidx) in boundaries.items():
                contents[sec] = _extract_block(lines, sidx, eidx)

            if any(contents[s].strip() for s in ["Remediation", "Default Value"]):
                first_token = full_name.split()[0] if full_name else ""
                resultados.append({
                    "ID": first_token,
                    "Nome Completo": full_name,
                    "Profile Applicability": contents.get("Profile Applicability", ""),
                    "Description": contents.get("Description", ""),
                    "Rationale": contents.get("Rationale", ""),
                    "Impact": contents.get("Impact", ""),
                    "Audit": contents.get("Audit", ""),
                    "Remediation": contents.get("Remediation", ""),
                    "Default Value": contents.get("Default Value", ""),
                })
                kept_items += 1

            i = end_of_item
            continue

        i += 1

    elapsed = time.perf_counter() - start_t
    logger.info("Parse completed. Found items: %d | Kept: %d | Duration: %.3fs",
                found_items, kept_items, elapsed)
    return resultados


# ----------------------- NEW: Save to Markdown files -----------------------
def salvar_em_markdown(lista_dados: List[Dict[str, str]], output_dir: str) -> None:
    """
    Save each CIS recommendation as a separate markdown file.
    Filename format: {ID}.md (e.g., 1.1.5.md)
    """
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    files_created = 0
    
    for item in lista_dados:
        # Get the ID for filename
        cis_id = item['ID']
        if not cis_id:
            logger.warning("Skipping item with empty ID: %s", item.get('Nome Completo', 'Unknown'))
            continue
            
        # Create filename with just the ID
        file_path = output_path / f"{cis_id}.md"
        
        # Build markdown content
        md_content = _build_markdown_content(item)
        
        # Write to file
        try:
            file_path.write_text(md_content, encoding="utf-8")
            files_created += 1
            logger.debug("Created markdown file: %s", file_path)
        except Exception as e:
            logger.error("Failed to write file %s: %s", file_path, e)
    
    logger.info("Created %d markdown files in directory: %s", files_created, output_path)


def _create_safe_id(id_str: str) -> str:
    """
    Create a safe filename from an ID.
    """
    # Remove any non-ID characters (just in case)
    safe = re.sub(r'[^0-9.]', '_', id_str)
    # Remove consecutive underscores and trim
    safe = re.sub(r'_+', '_', safe)
    safe = safe.strip('_')
    return safe


def _build_markdown_content(item: Dict[str, str]) -> str:
    """
    Build markdown content from a CIS recommendation item.
    """
    lines = []
    
    # Title with ID and full name
    lines.append(f"# {item['ID']} - {item['Nome Completo']}")
    lines.append("")
    
    # Sections in order
    sections = [
        ("Profile Applicability", "## Profile Applicability"),
        ("Description", "## Description"),
        ("Rationale", "## Rationale"),
        ("Impact", "## Impact"),
        ("Audit", "## Audit"),
        ("Remediation", "## Remediation"),
        ("Default Value", "## Default Value"),
    ]
    
    for section_key, header in sections:
        content = item.get(section_key, "").strip()
        if content:
            lines.append(header)
            lines.append("")
            lines.append(content)
            lines.append("")
    
    return "\n".join(lines)


# ----------------------- NEW: Table of Contents extraction -----------------------
def extrair_indice_pdf(pdf_path: str, MAX_TOC_PAGES: int = 60) -> pd.DataFrame | None:
    """
    Extract the PDF Table of Contents into columns: Level, ID, Title, Page.
    Strategy:
      1) Try embedded ToC via doc.get_toc().
      2) Fallback: scan only the first MAX_TOC_PAGES pages, accept ONLY lines
         with dotted leaders and a trailing page number, and set Page from that.
    """
    def _cleanup_toc_title(title: str) -> str:
        s = _normalize_line(title)
        s = re.sub(r"\.{2,}\s*\d+\s*$", "", s)   # remove leaders + page num
        s = s.strip(" .")
        return s

    def _toc_df_from_list(toc_list) -> pd.DataFrame:
        rows = []
        for e in toc_list:
            if isinstance(e, dict):
                level = int(e.get("level", 0))
                title = _normalize_line(str(e.get("title", "")))
                page = int(e.get("page", 0))
            else:
                level = int(e[0]) if len(e) > 0 else 0
                title = _normalize_line(str(e[1])) if len(e) > 1 else ""
                page = int(e[2]) if len(e) > 2 else 0
            m = ID_RELAXED_RE.match(title)
            sec_id = m.group(1) if m else ""
            rows.append({"Level": max(1, sec_id.count(".") + 1) if sec_id else level or 1,
                         "ID": sec_id, "Title": _cleanup_toc_title(title), "Page": page})
        return pd.DataFrame(rows, columns=["Level", "ID", "Title", "Page"])

    def _looks_like_noise(title: str) -> bool:
        t = title.strip()
        if not t:
            return True
        if re.search(r"\bP\s*a\s*g\s*e\b", t, re.IGNORECASE):
            return True
        return False

    def _toc_df_fallback_scan(pdf_path_: str, max_pages: int) -> pd.DataFrame | None:
        rows, seen = [], set()
        with fitz.open(pdf_path_) as doc:
            last = min(max_pages, doc.page_count)
            for pno in range(1, last + 1):
                page = doc.load_page(pno - 1)
                for raw in page.get_text().splitlines():
                    s = _normalize_line(raw)
                    if not s or _looks_like_noise(s):
                        continue
                    # REQUIRE dotted leaders + trailing page number
                    md = TOC_DOTTED_RE.match(s)
                    if not md:
                        continue
                    sec_id, title, page_num = md.group(1), _cleanup_toc_title(md.group(2)), int(md.group(3))

                    # sanity checks
                    if page_num < 1 or page_num > doc.page_count:
                        continue
                    if not re.fullmatch(r"\d+(?:\.\d+){0,6}", sec_id):
                        continue
                    if not re.search(r"[A-Za-z]", title):
                        continue

                    level = sec_id.count(".") + 1
                    key = (sec_id, title)
                    if key in seen:
                        continue
                    seen.add(key)
                    rows.append({"Level": level, "ID": sec_id, "Title": title, "Page": page_num})
        if not rows:
            return None

        def _natkey(sec: str):
            return tuple(int(x) for x in sec.split(".") if x.isdigit())

        rows.sort(key=lambda r: (_natkey(r["ID"]), r["Page"]))
        return pd.DataFrame(rows, columns=["Level", "ID", "Title", "Page"])

    # Try embedded ToC first
    try:
        with fitz.open(pdf_path) as doc:
            try:
                toc_list = doc.get_toc()
            except Exception:
                toc_list = []
        if toc_list:
            df = _toc_df_from_list(toc_list)
            if not df.empty:
                logger.info("Extracted %d ToC entries from embedded ToC.", len(df))
                return df
    except Exception as e:
        logger.warning("Embedded ToC read failed: %s", e)

    # Fallback regex scan (front matter only; dotted leaders required)
    df_fb = _toc_df_fallback_scan(pdf_path, MAX_TOC_PAGES)
    if df_fb is not None and not df_fb.empty:
        logger.info("Built %d ToC entries via fallback scan (first %d pages).", len(df_fb), MAX_TOC_PAGES)
        return df_fb

    logger.info("No ToC could be extracted.")
    return None


# ----------------------- CSV writer (optional) -----------------------
def salvar_em_csv(lista_dados: List[Dict[str, str]], arquivo_saida: str, indice_df: pd.DataFrame | None = None) -> None:
    """
    Save data to CSV files (optional, kept for compatibility).
    """
    out_path = Path(arquivo_saida)
    out_dir = out_path.parent
    out_dir.mkdir(parents=True, exist_ok=True)
    
    # Save main data
    df = pd.DataFrame(lista_dados)
    csv_main = out_path.with_suffix(".csv")
    df.to_csv(csv_main, index=False, encoding="utf-8")
    logger.info("Saved main data to CSV: %s", csv_main)
    
    # Save index if available
    if indice_df is not None and not indice_df.empty:
        csv_idx = out_path.with_name(out_path.stem + "_Index.csv")
        indice_df.to_csv(csv_idx, index=False, encoding="utf-8")
        logger.info("Saved index to CSV: %s", csv_idx)


# ----------------------- CLI -----------------------
def parse_args(argv: List[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Extract CIS sections from PDF and export to individual Markdown files."
    )

    #####################################################################################################
    #####################################################################################################
    p.add_argument("--pdf", required=False, default="CIS_Oracle_Linux_7_Benchmark_v4.0.0.pdf", 
                   help="Input PDF path.")
    p.add_argument("--output-dir", required=False, default="cis_markdown_files",
                   help="Output directory for markdown files.")
    p.add_argument("--csv", required=False, default=None,
                   help="Optional: Also save CSV output (provide filename).")
    #####################################################################################################
    #####################################################################################################
    
    p.add_argument("-v", "--verbose", action="count", default=0, help="Increase verbosity.")
    p.add_argument("--log-file", default=None, help="Optional log file path.")
    p.add_argument("--max-toc-pages", type=int, default=60, 
                   help="Max front pages to scan for ToC when PDF lacks embedded ToC.")
    return p.parse_args(argv)


def main() -> int:
    args = parse_args()
    setup_logging(args.verbose, args.log_file)

    pdf_file = args.pdf
    output_dir = args.output_dir

    logger.info("Parameters | pdf=%s | output_dir=%s | verbose=%d | log_file=%s",
                pdf_file, output_dir, args.verbose, args.log_file or "-")

    t0 = time.perf_counter()
    try:
        # Extract data from PDF
        dados = extrair_cis_sections(pdf_file)
        
        # Save to markdown files
        salvar_em_markdown(dados, output_dir)
        
        # Optionally save CSV
        if args.csv:
            indice_df = extrair_indice_pdf(pdf_file, MAX_TOC_PAGES=args.max_toc_pages)
            salvar_em_csv(dados, args.csv, indice_df=indice_df)

        logger.info("SUCCESS | Items exported: %d | Markdown files created in: %s",
                    len(dados), output_dir)
    except Exception:
        logger.error("FAILED execution due to previous errors.")
        return 1
    finally:
        logger.info("Total runtime: %.3fs", time.perf_counter() - t0)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())