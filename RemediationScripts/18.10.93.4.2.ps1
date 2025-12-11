<#
.SYNOPSIS
    CIS Control 18.10.93.4.2 - 18.10.93.4.2 (L1) Ensure 'Select when Preview Builds and Feature Updates are rec

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 180 or more days :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Windows Update...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.93.4.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    Value Name: Select when Preview Builds and Feature Updates are received
    Recommended Value: Enabled: 180 or more days
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.93.4.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.93.4.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $valueName = "Select when Preview Builds and Feature Updates are received"
    $value = "Enabled: 180 or more days"
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
        Write-Host "Successfully applied CIS Control 18.10.93.4.2" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.93.4.2: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
