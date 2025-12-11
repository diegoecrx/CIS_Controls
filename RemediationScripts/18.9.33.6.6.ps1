<#
.SYNOPSIS
    CIS Control 18.9.33.6.6 - 18.9.33.6.6 (L1) Ensure 'Require a password when a computer wakes (plugged in)' 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled :
 
Computer Configuration\Policies\Administrative Templates\System\Power Management\Sleep Settings\Require a pa...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.33.6.6
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Require a password when a computer wakes (plugged in)
    Recommended Value: Enabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.33.6.6.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.33.6.6..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Require a password when a computer wakes (plugged in)"
    $value = 1
    $type = "DWord"
    
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
        Write-Host "Successfully applied CIS Control 18.9.33.6.6" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.33.6.6: $_" -ForegroundColor Red
    exit 1
}
