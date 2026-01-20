#!/usr/bin/env python3

import sys
import os
import re
import xml.etree.ElementTree as ET

NS = "{http://www.nessus.org/cm}"

def get_ns_text(elem, tag):
    node = elem.find(NS + tag)
    if node is not None and node.text:
        return node.text.strip()
    return ""

def extract_rule_number(text):
    if not text:
        return None
    m = re.match(r"^(\d+(?:\.\d+)+)", text.strip())
    if m:
        return m.group(1)
    return None

def main():
    if len(sys.argv) != 2:
        print("Usage: python nessus_to_md.py <file.nessus>")
        sys.exit(1)

    nessus_file = sys.argv[1]

    if not os.path.isfile(nessus_file):
        print("File not found:", nessus_file)
        sys.exit(1)

    base_name = os.path.splitext(os.path.basename(nessus_file))[0]
    output_dir = base_name
    os.makedirs(output_dir, exist_ok=True)

    print(f"Reading: {nessus_file}")
    print(f"Output folder: {output_dir}")

    tree = ET.parse(nessus_file)
    root = tree.getroot()

    extracted = 0
    skipped = 0

    for item in root.iter("ReportItem"):
        plugin_family = item.get("pluginFamily", "")

        if "Compliance" not in plugin_family:
            continue

        name = get_ns_text(item, "compliance-check-name")
        rule_number = extract_rule_number(name)

        if not rule_number:
            skipped += 1
            continue

        solution = get_ns_text(item, "compliance-solution")
        policy_value = get_ns_text(item, "compliance-policy-value")
        output_val = get_ns_text(item, "compliance-actual-value")

        filename = f"{rule_number}.md"
        filepath = os.path.join(output_dir, filename)

        with open(filepath, "w", encoding="utf-8") as f:
            f.write(f"# {name}\n\n")

            f.write("## Solution\n")
            f.write((solution or "N/A") + "\n\n")

            f.write("## Policy Value\n")
            f.write((policy_value or "N/A") + "\n\n")

            f.write("## Output\n")
            f.write((output_val or "N/A") + "\n")

        extracted += 1

    print("Done.")
    print(f"Extracted: {extracted}")
    print(f"Skipped: {skipped}")

if __name__ == "__main__":
    main()
