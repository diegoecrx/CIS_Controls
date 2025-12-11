<#
.SYNOPSIS
    CIS Control 18.10.29.5 - 18.10.29.5 (L1) Ensure 'Turn off heap termination on corruption' is set to 'Disa

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\File Explorer\Turn off heap ter...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.29.5
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Turn off heap termination on corruption
    Recommended Value: Disabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.29.5.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.29.5..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Turn off heap termination on corruption"
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
        Write-Host "Successfully applied CIS Control 18.10.29.5" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.29.5: $_" -ForegroundColor Red
    exit 1
}
