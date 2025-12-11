<#
.SYNOPSIS
    CIS Control 18.10.43.11.1.2.1 - 18.10.43.11.1.2.1 (L2) Ensure 'Configure how aggressively Remote Encryption Prot

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Medium or higher:
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Microsoft Defen...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.43.11.1.2.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Configure how aggressively Remote Encryption Protection blocks threats
    Recommended Value: Enabled: Medium
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.43.11.1.2.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.43.11.1.2.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Configure how aggressively Remote Encryption Protection blocks threats"
    $value = "Enabled: Medium"
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
        Write-Host "Successfully applied CIS Control 18.10.43.11.1.2.1" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.43.11.1.2.1: $_" -ForegroundColor Red
    exit 1
}
