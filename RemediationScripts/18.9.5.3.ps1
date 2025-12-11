<#
.SYNOPSIS
    CIS Control 18.9.5.3 - 18.9.5.3 (L1) Ensure 'Turn On Virtualization Based Security: Virtualization Base

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled with UEFI lock :
 
Computer Configuration\Policies\Administrative Templates\System\Device Guard\Turn On Virtuali...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.5.3
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Turn On Virtualization Based Security: Virtualization Based Protection of Code Integrity
    Recommended Value: Enabled with UEFI lock
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.5.3.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.5.3..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Turn On Virtualization Based Security: Virtualization Based Protection of Code Integrity"
    $value = "Enabled with UEFI lock"
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
        Write-Host "Successfully applied CIS Control 18.9.5.3" -ForegroundColor Green
    Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.5.3: $_" -ForegroundColor Red
    Write-Host "FAIL" -ForegroundColor Red
    exit 1
}
