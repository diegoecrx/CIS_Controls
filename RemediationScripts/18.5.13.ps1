<#
.SYNOPSIS
    CIS Control 18.5.13 - 18.5.13 (L1) Ensure 'MSS: (WarningLevel) Percentage threshold for the security e

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 90% or less :
 
Computer Configuration\Policies\Administrative Templates\MSS (Legacy)\MSS: (WarningLevel) Perce...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.5.13
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: MSS: (WarningLevel) Percentage threshold for the security event log at which the system will generate a warning
    Recommended Value: Enabled: 90% or less
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.5.13.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.5.13..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "MSS: (WarningLevel) Percentage threshold for the security event log at which the system will generate a warning"
    $value = "Enabled: 90% or less"
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
        Write-Host "Successfully applied CIS Control 18.5.13" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.5.13: $_" -ForegroundColor Red
    exit 1
}
