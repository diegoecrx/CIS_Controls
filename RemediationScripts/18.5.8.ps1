<#
.SYNOPSIS
    CIS Control 18.5.8 - 18.5.8 (L2) Ensure 'MSS: (PerformRouterDiscovery) Allow IRDP to detect and confi

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Administrative Templates\MSS (Legacy)\MSS: (PerformRouterDiscovery) Allow I...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.5.8
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: MSS: (PerformRouterDiscovery) Allow IRDP to detect and configure Default Gateway addresses
    Recommended Value: Disabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.5.8.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.5.8..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "MSS: (PerformRouterDiscovery) Allow IRDP to detect and configure Default Gateway addresses"
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
        Write-Host "Successfully applied CIS Control 18.5.8" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.5.8: $_" -ForegroundColor Red
    exit 1
}
