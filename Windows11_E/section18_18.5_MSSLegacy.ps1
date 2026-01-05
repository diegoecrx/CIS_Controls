param([switch]$Report)

$settingsDb = Import-PowerShellDataFile -Path "$PSScriptRoot\section18_settings.psd1"
$settings = $settingsDb.Settings | Where-Object { $_.Control -match '^18\.5' }

$results = @()
Write-Host ""
Write-Host "=== Section 18.5 - MSS Legacy Settings ===" -ForegroundColor Cyan
Write-Host "Configuring $($settings.Count) settings..." -ForegroundColor White

$registrySettings = @($settings | Where-Object { $_.Path -ne "N/A" })
$policyOnlySettings = @($settings | Where-Object { $_.Path -eq "N/A" })

foreach ($setting in $registrySettings) {
    try {
        $path = $setting.Path
        $name = $setting.Name
        $value = $setting.Value
        $type = $setting.Type
        
        $current = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
        $currentValue = if ($current) { $current.$name } else { "Not Set" }
        
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force | Out-Null
        
        $results += [PSCustomObject]@{
            Control = $setting.Control
            Level = $setting.Level
            Description = $setting.Description
            CurrentValue = $currentValue
            AppliedValue = $value
            Status = "Success"
        }
        Write-Host "$($setting.Control) | $($setting.Description) | $currentValue -> $value" -ForegroundColor Green
    }
    catch {
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
    }
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

Write-Host ""
Write-Host "Summary - 18.5: Applied $(($results | Where-Object {$_.Status -eq 'Success'}).Count), Failed $(($results | Where-Object {$_.Status -ne 'Success'}).Count)" -ForegroundColor Yellow

if ($Report) {
    $results | Export-Csv -Path "$PSScriptRoot\section18_18.5_report.csv" -NoTypeInformation
}

return $results
