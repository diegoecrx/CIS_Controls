# Update all category scripts to handle policy-only settings

$files = @(
    "section18_18.5_MSSLegacy.ps1",
    "section18_18.6_Network.ps1",
    "section18_18.7_Printers.ps1",
    "section18_18.8_StartMenu.ps1",
    "section18_18.9_System.ps1"
)

foreach ($file in $files) {
    $path = "C:\Users\DiegoCamargo\Downloads\Windows11_E\$file"
    Write-Host "Updating $file..." -ForegroundColor Cyan
    
    $content = Get-Content $path -Raw
    
    # Replace the foreach loop to separate registry and policy-only settings
    $content = $content -replace 
        'foreach \(\$setting in \$settings\) \{',
        '$registrySettings = @($settings | Where-Object { $_.Path -ne "N/A" })
$policyOnlySettings = @($settings | Where-Object { $_.Path -eq "N/A" })

foreach ($setting in $registrySettings) {'
    
    # Replace the catch block to include error message
    $content = $content -replace 
        'catch \{\s*\$results \+= \[PSCustomObject\]@\{\s*Control = \$setting\.Control\s*Level = \$setting\.Level\s*Description = \$setting\.Description\s*CurrentValue = "Error"\s*AppliedValue = \$setting\.Value\s*Status = "Failed"\s*\}\s*\}',
        'catch {
        $errorMsg = $_.Exception.Message
        $results += [PSCustomObject]@{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            CurrentValue = "Error"
            AppliedValue = $setting.Value
            Status = "Failed: $errorMsg"
        }
        Write-Host "$($setting.Control) | $($setting.Description) | Error" -ForegroundColor Red
    }'
    
    # Add policy-only handling before the Write-Host summary line
    $summaryPattern = 'Write-Host ""(\s*)Write-Host "Summary - (\d+\.\d+):'
    $replacement = @'
}

foreach ($setting in $policyOnlySettings) {
    $results += [PSCustomObject]@{
        Control = $setting.Control
        Level = $setting.Level
        Description = $setting.Description
        CurrentValue = "N/A"
        AppliedValue = "N/A (Group Policy)"
        Status = "Policy-Only"
    }
    Write-Host "$($setting.Control) | $($setting.Description) | (requires Group Policy)" -ForegroundColor Yellow
}

Write-Host ""$1Write-Host "Summary - $2:
'@
    
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, $summaryPattern, $replacement)
    
    # Save the updated content
    Set-Content -Path $path -Value $content -Encoding UTF8
    Write-Host "  ✓ Updated" -ForegroundColor Green
}

Write-Host "`nAll scripts updated!" -ForegroundColor Green
