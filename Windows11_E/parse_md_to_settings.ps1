
# Parse all markdown files and generate section18_settings.psd1

$mdPath = "C:\Users\DiegoCamargo\Downloads\Windows11_E_md\Section18"
$outputPath = "C:\Users\DiegoCamargo\Downloads\Windows11_E\section18_settings.psd1"

$mdFiles = Get-ChildItem $mdPath -Filter "*.md" | Sort-Object Name
Write-Host "Found $($mdFiles.Count) markdown files"

$settings = @()
$parsed = 0
$skipped = 0

foreach ($file in $mdFiles) {
    $content = Get-Content $file.FullName -Raw
    $controlId = $file.BaseName
    
    # Extract Level
    if ($content -match "\(L[12]\)") {
        $level = $matches[0] -replace "[()]", ""
    } else {
        $level = "L1"
    }
    
    # Extract registry path and value name
    if ($content -match "HKLM\\[^:]+:(\w+)") {
        $registryPath = [regex]::Match($content, "HKLM\\[^:]+").Value
        $valueName = [regex]::Match($content, "HKLM\\[^:]+:(\w+)").Groups[1].Value
        
        $value = 1
        $type = "DWord"
        
        # Set values based on control type
        if ($controlId -match "18\.10\.(4\.1|10|12\.1|15|18\.|50\.1|69\.1|79\.1|80\.1)") {
            $value = 0
        }
        elseif ($controlId -match "18\.10\.7\.2") {
            $value = 255
        }
        elseif ($controlId -match "18\.6\.21\.1") {
            $value = 3
        }
        elseif ($controlId -eq "18.4.2") {
            $value = 4
        }
        elseif ($controlId -eq "18.4.6") {
            $value = 2
        }
        elseif ($controlId -match "18\.5\.(2|3)") {
            $value = 2
        }
        elseif ($controlId -eq "18.5.6") {
            $value = 300000
        }
        elseif ($controlId -match "18\.5\.(11|12)") {
            $value = 3
        }
        elseif ($controlId -eq "18.5.13") {
            $value = 90
        }
        elseif ($controlId -match "18\.9\.13\.1") {
            $value = 3
        }
        elseif ($controlId -match "18\.9\.36\.[12]") {
            $value = 1
        }
        elseif ($controlId -eq "18.10.51.2.3") {
            $value = 2
        }
        elseif ($controlId -eq "18.10.51.2.5") {
            $value = 3
        }
        
        # String values
        if ($controlId -match "18\.5\.(1|10)") {
            $value = "0"
            $type = "String"
        }
        elseif ($controlId -match "18\.10\.26\.\d+\.1R") {
            $value = "0"
            $type = "String"
        }
        
        # Extract title - handle multi-line titles
        $lines = $content -split "`n"
        $titleLine = $lines[0]
        if ($lines.Count -gt 1 -and $lines[1] -match "^\s*[A-Z]") {
            $titleLine = $titleLine + " " + $lines[1].Trim()
        }
        
        $titleMatch = [regex]::Match($titleLine, "^#\s+[\d.]+\s+-\s+[\d.]+\s+\(L[12]\)\s+(.+?)\s+\(")
        if ($titleMatch.Success) {
            $title = $titleMatch.Groups[1].Value.Trim()
        } else {
            $title = $controlId
        }
        
        $settings += @{
            Control = $controlId
            Level = $level
            Path = $registryPath
            Name = $valueName
            Value = $value
            Type = $type
            Description = $title
        }
        
        $parsed++
    } else {
        Write-Host "SKIP: $controlId" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host "Parsed: $parsed controls, Skipped: $skipped controls"

# Generate PSD1
$psd1Lines = @()
$psd1Lines += "@{"
$psd1Lines += "    Settings = @("

foreach ($setting in $settings) {
    $valStr = if ($setting.Type -eq "String") { "'$($setting.Value)'" } else { $setting.Value }
    $descClean = $setting.Description.Replace("'", "''")
    $line = "        @{ Control = '$($setting.Control)'; Level = '$($setting.Level)'; Path = '$($setting.Path)'; Name = '$($setting.Name)'; Value = $valStr; Type = '$($setting.Type)'; Description = '$descClean' }"
    $psd1Lines += $line
}

$psd1Lines += "    )"
$psd1Lines += "}"

$psd1 = $psd1Lines -join "`n"
Set-Content -Path $outputPath -Value $psd1 -Encoding UTF8

$size = [Math]::Round((Get-Item $outputPath).Length / 1KB, 1)
Write-Host "DONE: $outputPath ($size KB) with $($settings.Count) controls"
