<#
.SYNOPSIS
    CIS Control 18.7.12 - 18.7.12 (L1) Ensure 'Point and Print Restrictions: When installing drivers for a

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Show warning and elevation prompt :
 
Computer Configuration\Policies\Administrative Templates\Printers\Point a...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.7.12
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Point and Print Restrictions: When installing drivers for a new connection
    Recommended Value: Enabled: Show warning and elevation prompt
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.7.12.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.7.12..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Point and Print Restrictions: When installing drivers for a new connection"
    $value = "Enabled: Show warning and elevation prompt"
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
        Write-Host "Successfully applied CIS Control 18.7.12" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.7.12: $_" -ForegroundColor Red
    exit 1
}
