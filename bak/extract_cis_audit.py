#!/usr/bin/env python3
import re
import os
import glob
import sys

# Auto-detect .audit file in current directory
if len(sys.argv) > 1:
    audit_file = sys.argv[1]
else:
    audit_files = glob.glob("*.audit")
    if not audit_files:
        print("Error: No .audit file found")
        sys.exit(1)
    if len(audit_files) > 1:
        print("Multiple .audit files found. Specify one:")
        for f in audit_files:
            print(f"  {f}")
        sys.exit(1)
    audit_file = audit_files[0]
    print(f"Using: {audit_file}")

with open(audit_file, 'r', encoding='utf-8') as f:
    content = f.read()

items = re.findall(r'(<custom_item>.*?</custom_item>)', content, re.DOTALL)

for item in items:
    # Extract description and CIS ID
    desc_match = re.search(r'description\s*:\s*"(.*?)"', item, re.DOTALL)
    if not desc_match:
        continue
    description = desc_match.group(1).strip()
    cis_id_match = re.search(r'^(\d+(?:\.\d+)*)', description)
    if not cis_id_match:
        continue
    cis_id = cis_id_match.group(1).replace('.', '.')
    filename = f"{cis_id}.sh"

    # Extract ALL fields
    fields = {}
    for key in ['type', 'description', 'info', 'solution', 'reference', 'see_also', 'cmd', 'expect', 'file', 'owner', 'group', 'mask']:
        match = re.search(fr'{key}\s*:\s*(?:"(.*?)(?<!\\)"|([^\s"].*?))(?:\s|<|$)', item, re.DOTALL)
        if match:
            val = match.group(1) if match.group(1) is not None else match.group(2) or ''
            fields[key] = val.strip()

    # Clean solution (unescape)
    solution = fields.get('solution', '')
    solution = solution.replace('\\n', '\n').replace('\\"', '"').replace('\\\\', '\\').replace('\\#', '#').strip()

    # Detect if solution contains a full script
    has_script = '#!/usr/bin/env bash' in solution or '#!/bin/bash' in solution

    with open(filename, 'w', encoding='utf-8', newline='\n') as out:
        out.write('#!/bin/bash\n')
        out.write('#' + '='*78 + '\n')
        out.write(f'# CIS Rule: {description}\n')
        out.write('#' + '='*78 + '\n\n')

        # Dump every field as comment
        for k, v in fields.items():
            if k == 'solution' and has_script:
                continue  # will be added as code later
            if v:
                out.write(f"# {k.upper():<12}: {v.replace(chr(10), chr(10)+'#             ')}\n")
        out.write('\n# ' + '-'*78 + '\n\n')

        # Add the actual remediation code
        if has_script:
            script_start = solution.find('#!')
            script = solution[script_start:].strip()
            script = re.sub(r'\s*"\s*reference.*$', '', script, flags=re.DOTALL).strip()
            script = re.sub(r'^[\n\s]*\{?[\n\s]*', '', script).strip()
            script = re.sub(r'[\n\s]*\}?[\n\s]*$', '', script).strip()
            out.write(script + '\n')
        else:
            # Use the last non-dash line from solution as command
            lines = [l.strip() for l in solution.split('\n') if l.strip() and not l.strip().startswith('-')]
            cmd = lines[-1] if lines else ''
            if cmd.startswith('#'):
                cmd = cmd[1:].strip()
            out.write(f"{cmd}\n")

    os.chmod(filename, 0o755)
    print(f"Created {filename} (all metadata in comments)")

print("\nAll done – every custom_item now has its full content preserved as comments + executable code")