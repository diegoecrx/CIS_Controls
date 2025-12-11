<#
.SYNOPSIS
    CIS Control 18.4.6 - 18.4.6 (L1) Ensure 'NetBT NodeType configuration' is set to 'Enabled: P-node (re

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: P-node (recommended) :
 
Computer Configuration\Policies\Administrative Templates\MS Security Guide\NetBT NodeT...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.4.6
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: NetBT NodeType configuration
    Recommended Value: Enabled: P-node (recommended)
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.4.6.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.4.6..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "NetBT NodeType configuration"
    $value = "Enabled: P-node (recommended)"
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
        Write-Host "Successfully applied CIS Control 18.4.6" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.4.6: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
