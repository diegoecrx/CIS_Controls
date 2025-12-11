<#
.SYNOPSIS
    CIS Control 18.10.93.2.2 - 18.10.93.2.2 (L1) Ensure 'Configure Automatic Updates: Scheduled install day' is

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to 0 - Every day :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Windows Update\Manage end ...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.93.2.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    Value Name: Configure Automatic Updates: Scheduled install day
    Recommended Value: 0 - Every day
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.93.2.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.93.2.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $valueName = "Configure Automatic Updates: Scheduled install day"
    $value = "0 - Every day"
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
        Write-Host "Successfully applied CIS Control 18.10.93.2.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.93.2.2: $_" -ForegroundColor Red
    exit 1
}
