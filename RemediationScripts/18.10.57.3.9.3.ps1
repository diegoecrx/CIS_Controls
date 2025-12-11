<#
.SYNOPSIS
    CIS Control 18.10.57.3.9.3 - 18.10.57.3.9.3 (L1) Ensure 'Require use of specific security layer for remote (R

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: SSL :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Remote Desktop Services\Rem...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.57.3.9.3
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services
    Value Name: Require use of specific security layer for remote (RDP) connections
    Recommended Value: Enabled: SSL
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.57.3.9.3.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.57.3.9.3..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $valueName = "Require use of specific security layer for remote (RDP) connections"
    $value = "Enabled: SSL"
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
        Write-Host "Successfully applied CIS Control 18.10.57.3.9.3" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.57.3.9.3: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
