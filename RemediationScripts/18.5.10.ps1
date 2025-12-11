<#
.SYNOPSIS
    CIS Control 18.5.10 - 18.5.10 (L1) Ensure 'MSS: (ScreenSaverGracePeriod) The time in seconds before th

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 5 or fewer seconds :
 
Computer Configuration\Policies\Administrative Templates\MSS (Legacy)\MSS: (ScreenSaverG...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.5.10
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: MSS: (ScreenSaverGracePeriod) The time in seconds before the screen saver grace period expires
    Recommended Value: Enabled: 5 or fewer seconds
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.5.10.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.5.10..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "MSS: (ScreenSaverGracePeriod) The time in seconds before the screen saver grace period expires"
    $value = "Enabled: 5 or fewer seconds"
    $type = "String"
    
    # Ensure the registry path exists
    if (-not (Test-Path $regPath)) {
        Write-Host "Creating registry path: $regPath"
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Set the registry value
    Write-Host "Setting $valueName = $value"
    Set-ItemProperty -Path $regPath -Name $valueName -Value $value -Type $type -Force
    
    # Verify the setting
    $currentValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
    if ($currentValue.$valueName -eq $value) {
        Write-Host "Successfully applied CIS Control 18.5.10" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.5.10: $_" -ForegroundColor Red
    exit 1
}
