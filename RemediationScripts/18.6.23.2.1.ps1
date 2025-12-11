<#
.SYNOPSIS
    CIS Control 18.6.23.2.1 - 18.6.23.2.1 (L1) Ensure 'Allow Windows to automatically connect to suggested ope

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Administrative Templates\Network\WLAN Service\WLAN Settings\Allow Windows t...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.6.23.2.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services
    Recommended Value: Disabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.6.23.2.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.6.23.2.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services"
    $value = 0
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
        Write-Host "Successfully applied CIS Control 18.6.23.2.1" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.6.23.2.1: $_" -ForegroundColor Red
    exit 1
}
