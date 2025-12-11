<#
.SYNOPSIS
    CIS Control 18.9.13.1 - 18.9.13.1 (L1) Ensure 'Boot-Start Driver Initialization Policy' is set to 'Enabl

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Good, unknown and bad but critical:
 
Computer Configuration\Policies\Administrative Templates\System\Early Lau...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.13.1
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Boot-Start Driver Initialization Policy
    Recommended Value: Enabled: Good, unknown and bad but critical
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.13.1.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.13.1..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Boot-Start Driver Initialization Policy"
    $value = "Enabled: Good, unknown and bad but critical"
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
        Write-Host "Successfully applied CIS Control 18.9.13.1" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.13.1: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
