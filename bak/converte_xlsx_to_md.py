import pandas as pd
import re
import os

def sanitize_filename(script_name):
    """Extract the policy number from the script name and sanitize it for filename."""
    # Extract the first part before .ps1 (like '5.9', '2.3.7.7', etc.)
    match = re.match(r'^([\d\.]+)', script_name)
    if match:
        return f"{match.group(1)}md"
    
    # Fallback: create a safe filename from the entire script name
    safe_name = re.sub(r'[<>:"/\\|?*]', '', script_name)
    safe_name = safe_name[:50]  # Limit length
    return f"{safe_name}md"

def create_markdown_file(row, output_dir="policy_files"):
    """Create a markdown file for a single policy row."""
    # Extract each column exactly as it appears in Excel
    script_name = str(row['powershell script name']).strip()
    policy_setting = str(row['Policy Setting']).strip()
    compliance_req = str(row['Compliance Requirement']).strip() if pd.notna(row['Compliance Requirement']) else ''
    solution = str(row['Solution']).strip() if pd.notna(row['Solution']) else ''
    gpo_path = str(row['GPO Path']).strip() if pd.notna(row['GPO Path']) else ''
    
    # Create filename from script name
    filename = sanitize_filename(script_name)
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Handle potential duplicate filenames
    counter = 1
    base_filename = filename
    while os.path.exists(os.path.join(output_dir, filename)):
        name_part, ext = os.path.splitext(base_filename)
        filename = f"{name_part}_{counter}{ext}"
        counter += 1
    
    # Create markdown content with each column as a separate section
    md_content = f"""# PowerShell Script
**Script Name:** {script_name}

---

## Policy Setting
{policy_setting}

---

## Compliance Requirement
{compliance_req}

---

## Solution
{solution}

---

## GPO Path
{gpo_path}
"""
    
    # Write to file
    filepath = os.path.join(output_dir, filename)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(md_content)
    
    return filepath

def process_excel_file(excel_path, sheet_name='Windows Policy', output_dir="policy_files"):
    """Process the Excel file and create markdown files for each row."""
    # Read the Excel file
    df = pd.read_excel(excel_path, sheet_name=sheet_name)
    
    print(f"Processing {len(df)} policy settings from '{sheet_name}'...")
    print(f"Columns found: {list(df.columns)}")
    print(f"Sample row:\n{df.iloc[0]}\n")
    
    # Check if all expected columns exist
    expected_columns = ['powershell script name', 'Policy Setting', 'Compliance Requirement', 'Solution', 'GPO Path']
    missing_columns = [col for col in expected_columns if col not in df.columns]
    
    if missing_columns:
        print(f"Warning: Missing expected columns: {missing_columns}")
        print(f"Available columns: {list(df.columns)}")
    
    # Create markdown files for each row
    created_files = []
    for idx, row in df.iterrows():
        try:
            filepath = create_markdown_file(row, output_dir)
            created_files.append(filepath)
            print(f"Created: {os.path.basename(filepath)}")
        except Exception as e:
            print(f"Error processing row {idx}: {e}")
            print(f"Row data: {row}")
    
    print(f"\nSuccessfully created {len(created_files)} markdown files in '{output_dir}' directory.")
    return created_files

if __name__ == "__main__":
    # Specify your Excel file path
    excel_file_path = "W11.xlsx"
    sheet_name = "Windows Policy"
    output_directory = "policy_files"
    
    # Process the Excel file
    process_excel_file(excel_file_path, sheet_name, output_directory)