<#
.SYNOPSIS
    CIS Control 18.9.26.2 - 18.9.26.2 (L1) Ensure 'Configures LSASS to run as a protected process' is set to

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Enabled with UEFI Lock :
 
Computer Configuration\Policies\Administrative Templates\System\Local Security Autho...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.9.26.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configures LSASS to run as a protected process
    Recommended Value: Enabled: Enabled with UEFI Lock
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.9.26.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.9.26.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configures LSASS to run as a protected process"
    $value = "Enabled: Enabled with UEFI Lock"
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
        Write-Host "Successfully applied CIS Control 18.9.26.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.9.26.2: $_" -ForegroundColor Red
    exit 1
}
