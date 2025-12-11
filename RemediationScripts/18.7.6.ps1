<#
.SYNOPSIS
    CIS Control 18.7.6 - 18.7.6 (L1) Ensure 'Configure RPC listener settings: Authentication protocol to 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Negotiate or higher:
 
Computer Configuration\Policies\Administrative Templates\Printers\Configure RPC listener...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.7.6
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure RPC listener settings: Configure protocol options for incoming RPC connections
    Recommended Value: Enabled: Negotiate
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.7.6.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.7.6..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure RPC listener settings: Configure protocol options for incoming RPC connections"
    $value = "Enabled: Negotiate"
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
        Write-Host "Successfully applied CIS Control 18.7.6" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.7.6: $_" -ForegroundColor Red
    exit 1
}
