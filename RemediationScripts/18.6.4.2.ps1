<#
.SYNOPSIS
    CIS Control 18.6.4.2 - 18.6.4.2 (L1) Ensure 'Configure NetBIOS settings' is set to 'Enabled: Disable Ne

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Disable NetBIOS name resolution on public networks :
 
Computer Configuration\Policies\Administrative Templates...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.6.4.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure NetBIOS settings
    Recommended Value: Enabled: Disable NetBIOS name resolution on public networks
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.6.4.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.6.4.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure NetBIOS settings"
    $value = "Enabled: Disable NetBIOS name resolution on public networks"
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
        Write-Host "Successfully applied CIS Control 18.6.4.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.6.4.2: $_" -ForegroundColor Red
    exit 1
}
