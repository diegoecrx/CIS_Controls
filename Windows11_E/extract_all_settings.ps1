# Extract all settings from Section18 markdown files
$sourceDir = "C:\Users\DiegoCamargo\Downloads\Codigos\cis_markdown_files\Section18"
$allSettings = @()

Get-ChildItem -Path $sourceDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $fileName = $_.BaseName
    
    # Extract control number from filename
    if ($fileName -match "^(\d+\.\d+(\.\d+)?)") {
        $controlNum = $matches[1]
        
        # Look for Registry Path
        $pathMatch = $content -match "Registry Path:\s*(.+?)(?:\n|$)"
        $path = if ($pathMatch) { $matches[1].Trim() } else { "" }
        
        # Look for Value Name
        $nameMatch = $content -match "Value Name:\s*(.+?)(?:\n|$)"
        $name = if ($nameMatch) { $matches[1].Trim() } else { "" }
        
        # Look for Value Type (DWord, String, etc)
        $typeMatch = $content -match "Value Type:\s*(.+?)(?:\n|$)"
        $type = if ($typeMatch) { $matches[1].Trim() } else { "" }
        
        # Look for Value (the actual registry value)
        $valueMatch = $content -match "Value(?:\sData)?:\s*(.+?)(?:\n|$)"
        $value = if ($valueMatch) { $matches[1].Trim() } else { "" }
        
        # Look for CIS Level (L1 or L2)
        $levelMatch = $content -match "CIS Level:\s*([L1L2]+)"
        $level = if ($levelMatch) { $matches[1].Trim() } else { "L1" }
        
        # Look for Description/Recommendation
        $descMatch = $content -match "# (.+?)(?:\n|$)"
        $description = if ($descMatch) { $matches[1].Trim() } else { "" }
        
        # Only add if we have path and name
        if ($path -and $name) {
            # Convert value based on type
            $convertedValue = $value
            if ($type -eq "DWord" -and $value -match "^\d+$") {
                $convertedValue = [int]$value
            }
            
            $allSettings += @{
                Control = $controlNum
                Level = $level
                Path = $path
                Name = $name
                Value = $convertedValue
                Type = if ($type) { $type } else { "DWord" }
                Description = $description
                File = $fileName
            }
            
            Write-Host "$controlNum | $name | $value" -ForegroundColor Gray
        }
    }
}

Write-Host "`nTotal settings extracted: $($allSettings.Count)" -ForegroundColor Green

# Show counts by section
$allSettings | Group-Object { $_.Control.Split('.')[0] + "." + $_.Control.Split('.')[1] } | 
    ForEach-Object { Write-Host "$($_.Name): $($_.Count) settings" }

# Export for review
$allSettings | ConvertTo-Json | Set-Content "C:\Users\DiegoCamargo\Downloads\Windows11_E\extracted_settings.json"
Write-Host "`nSettings exported to extracted_settings.json" -ForegroundColor Cyan
