<#
.SYNOPSIS
    CIS Control 18.10.76.2.1 - 18.10.76.2.1 (L1) Ensure 'Configure Windows Defender SmartScreen' is set to 'Ena

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Warn and prevent bypass :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Windows...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.76.2.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender
    Value Name: Configure Windows Defender SmartScreen
    Recommended Value: Enabled: Warn and prevent bypass
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.76.2.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.76.2.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $valueName = "Configure Windows Defender SmartScreen"
    $value = "Enabled: Warn and prevent bypass"
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
        Write-Host "Successfully applied CIS Control 18.10.76.2.1" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.76.2.1: $_" -ForegroundColor Red
    exit 1
}
