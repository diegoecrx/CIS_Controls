# Generate proper PSD1 with correct escaping
$sourceDir = "C:\Users\DiegoCamargo\Downloads\Codigos\cis_markdown_files\Section18"
$allSettings = @()
$fileCount = 0

Write-Host "Parsing Section 18 markdown files..." -ForegroundColor Cyan

Get-ChildItem -Path $sourceDir -Filter "*.md" | Sort-Object Name | ForEach-Object {
    $fileCount++
    $content = Get-Content $_.FullName -Raw
    $fileName = $_.BaseName
    
    # Extract control number from filename
    if ($fileName -match "^(18\.\d+(?:\.\d+)*)") {
        $controlNum = $matches[1]
        
        # Extract title from heading
        $titleMatch = $content -match "^# +(.+?)(?:\n|$)"
        $title = if ($titleMatch) { $matches[1].Trim() } else { "No title" }
        
        # Clean up title
        $title = $title -replace "^\d+\.\d+[.\d]*\s*[-]\s*", ""
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
        $isRegistryBased = $false
        
        # Try various registry path patterns
        if ($content -match "HKLM\\([^\\s\\n:]+)") {
            $regPath = "HKLM:\$($matches[1])"
            if ($content -match "Value Name:\s*([^\n\r]+)") {
                $regName = $matches[1].Trim()
            }
            if ($content -match "Value\s*(?:Data)?:\s*([^\n\r]+)") {
                $regValue = $matches[1].Trim()
                if ($regValue -match "^\\d+$") { $regType = "DWord" }
                else { $regType = "String" }
            }
            $isRegistryBased = $true
        }
        
        # Build setting object
        $setting = [PSCustomObject]@{
            Control = $controlNum
            Level = $level
            Description = $title
            Path = if ($isRegistryBased) { $regPath } else { "N/A" }
            Name = if ($isRegistryBased) { $regName } else { "N/A" }
            Value = if ($isRegistryBased) { $regValue } else { "" }
            Type = if ($isRegistryBased) { $regType } else { "N/A" }
            IsRegistry = $isRegistryBased
        }
        
        $allSettings += $setting
    }
}

Write-Host "Processed $fileCount files, extracted $($allSettings.Count) settings" -ForegroundColor Green

# Build PSD1 content with proper escaping
$psd1Lines = @('@{')
$psd1Lines += '    Settings = @('

foreach ($setting in $allSettings) {
    # Escape single quotes and special characters in description
    $desc = $setting.Description -replace "'", "''"
    
    $line = "        @{ Control = '$($setting.Control)'; Level = '$($setting.Level)'; Path = '$($setting.Path)'; Name = '$($setting.Name)'; Value = '$($setting.Value)'; Type = '$($setting.Type)'; Description = '$desc' },"
    $psd1Lines += $line
}

# Remove trailing comma from last entry
$psd1Lines[-1] = $psd1Lines[-1] -replace ",$", ""

$psd1Lines += '    )'
$psd1Lines += '}'

# Write file with UTF8 encoding
$outputPath = "C:\Users\DiegoCamargo\Downloads\Windows11_E\section18_settings.psd1"
$psd1Lines | Set-Content -Path $outputPath -Encoding UTF8

Write-Host "Settings file saved: $outputPath" -ForegroundColor Green
Write-Host "Total settings: $($allSettings.Count)" -ForegroundColor Green

# Verify it's valid PowerShell
Write-Host "Validating PSD1 syntax..." -ForegroundColor Cyan
try {
    $testData = Import-PowerShellDataFile -Path $outputPath
    Write-Host "PSD1 syntax is valid!" -ForegroundColor Green
    Write-Host "Loaded $($testData.Settings.Count) settings" -ForegroundColor Green
} catch {
    Write-Host "ERROR: PSD1 syntax is invalid!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
