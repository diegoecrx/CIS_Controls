# Comprehensive extraction from Section18 markdown files
param(
    [string]$SourceDir = "C:\Users\DiegoCamargo\Downloads\Codigos\cis_markdown_files\Section18",
    [string]$OutputPath = "C:\Users\DiegoCamargo\Downloads\Windows11_E\section18_complete_settings.psd1"
)

$allSettings = @()
$fileCount = 0
$settingCount = 0

Write-Host "Parsing Section 18 markdown files..." -ForegroundColor Cyan

Get-ChildItem -Path $SourceDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
    $fileCount++
    $content = Get-Content $_.FullName -Raw
    $fileName = $_.BaseName
    
    # Extract control number from filename
    if ($fileName -match "^(18\.\d+(?:\.\d+)*)") {
        $controlNum = $matches[1]
        
        # Extract title from heading
        $titleMatch = $content -match "^# +(.+?)(?:\n|$)"
        $title = if ($titleMatch) { $matches[1].Trim() } else { "No title" }
        
        # Remove control number from title if present
        $title = $title -replace "^[\d.]+\s*[-]\s*", ""
        $title = $title -replace "\s+\([BL]+\)\s*", ""
        $title = $title -replace "\s+\(Automated\)\s*$", ""
        $title = $title -replace "\s+\(Manual\)\s*$", ""
        
        # Determine Level (L1, L2, BL)
        $level = "L1"
        if ($content -match "Level 2|L2") { $level = "L2" }
        if ($content -match "BitLocker") { $level = "BL" }
        if ($content -match "L1.*BL|BL.*L1") { $level = "L1+BL" }
        if ($content -match "L2.*BL|BL.*L2") { $level = "L2+BL" }
        
        # Look for registry information
        $regPath = ""
        $regName = ""
        $regValue = ""
        $regType = "DWord"
        
        # Try various registry path patterns
        if ($content -match "HKLM\\\\([^\\s\\n:]+)") {
            $regPath = "HKLM:\$($matches[1])"
            if ($content -match "Value Name:\s*([^\\n\\r]+)") {
                $regName = $matches[1].Trim()
            }
            if ($content -match "Value\s*(?:Data)?:\s*([^\\n\\r]+)") {
                $regValue = $matches[1].Trim()
                if ($regValue -match "^\\d+$") { $regType = "DWord" }
                else { $regType = "String" }
            }
        }
        
        # For policies without direct registry, we use the GP path or note it's policy-only
        $isRegistryBased = -not [string]::IsNullOrWhiteSpace($regPath)
        
        # Only add if we have enough information
        if ($isRegistryBased -or $controlNum) {
            $setting = @{
                Control = $controlNum
                Level = $level
                Description = $title
            }
            
            if ($isRegistryBased) {
                $setting.Path = $regPath
                $setting.Name = $regName
                $setting.Value = $regValue
                $setting.Type = $regType
            } else {
                # Policy-based without registry
                $setting.Path = "N/A (Group Policy)"
                $setting.Name = "N/A"
                $setting.Value = "N/A"
                $setting.Type = "N/A"
            }
            
            $allSettings += $setting
            $settingCount++
            
            if ($isRegistryBased) {
                Write-Host "[$controlNum] $regName" -ForegroundColor Green
            } else {
                Write-Host "[$controlNum] (GP-only) $title" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "`nProcessed $fileCount files, extracted $settingCount settings" -ForegroundColor Cyan

# Show breakdown by section and registry status
Write-Host "`nBreakdown by section:" -ForegroundColor Cyan
$allSettings | Group-Object { $_.Control.Substring(0, 4) } | 
    ForEach-Object { 
        $withReg = @($_.Group | Where-Object { $_.Path -ne "N/A (Group Policy)" }).Count
        $gpOnly = @($_.Group | Where-Object { $_.Path -eq "N/A (Group Policy)" }).Count
        Write-Host "  $($_.Name): $($_.Count) settings ($withReg registry, $gpOnly policy-only)"
    }

Write-Host "`nBreakdown by level:" -ForegroundColor Cyan
$allSettings | Group-Object Level | 
    ForEach-Object { 
        Write-Host "  $($_.Name): $($_.Count) settings"
    }

# Generate PSD1 file with settings
$psd1Content = '@{' + "`r`n" + '    Settings = @(' + "`r`n"

foreach ($setting in $allSettings) {
    if ($setting.Path -eq "N/A (Group Policy)") {
        $psd1Content += "        @{ Control = `"$($setting.Control)`"; Level = `"$($setting.Level)`"; Path = `"N/A (Group Policy)`"; Name = `"N/A`"; Value = `"`"; Type = `"N/A`"; Description = `"$($setting.Description)`" },`r`n"
    } else {
        $psd1Content += "        @{ Control = `"$($setting.Control)`"; Level = `"$($setting.Level)`"; Path = `"$($setting.Path)`"; Name = `"$($setting.Name)`"; Value = `"$($setting.Value)`"; Type = `"$($setting.Type)`"; Description = `"$($setting.Description)`" },`r`n"
    }
}

$psd1Content = $psd1Content.Substring(0, $psd1Content.Length - 3)
$psd1Content += "`r`n    )`r`n}`r`n"

# Write to file
$psd1Content | Set-Content $OutputPath -Encoding UTF8

Write-Host "`nSettings saved to: $OutputPath" -ForegroundColor Green
Write-Host "Total settings in PSD1: $($allSettings.Count)" -ForegroundColor Green
