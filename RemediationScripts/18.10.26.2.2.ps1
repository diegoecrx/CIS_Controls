<#
.SYNOPSIS
    CIS Control 18.10.26.2.2 - 18.10.26.2.2 (L1) Ensure 'Security: Specify the maximum log file size (KB)' is s

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 196,608 or greater :
 
Computer Configuration\Policies\Administrative Templates\Windows Components\Event Log Se...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.26.2.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Specify the maximum log file size (KB)
    Recommended Value: Enabled: 196,608 or greater
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.26.2.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.26.2.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Specify the maximum log file size (KB)"
    $value = "Enabled: 196,608 or greater"
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
        Write-Host "Successfully applied CIS Control 18.10.26.2.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.26.2.2: $_" -ForegroundColor Red
    exit 1
}
