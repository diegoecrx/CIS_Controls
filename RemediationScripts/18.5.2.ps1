<#
.SYNOPSIS
    CIS Control 18.5.2 - 18.5.2 (L1) Ensure 'MSS: (DisableIPSourceRouting IPv6) IP source routing protect

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Highest protection, source routing is completely disabled :
 
Computer Configuration\Policies\Administrative Te...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.5.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: MSS: (DisableIPSourceRouting IPv6) IP source routing protection level
    Recommended Value: Enabled: Highest protection, source routing is completely disabled
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.5.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.5.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "MSS: (DisableIPSourceRouting IPv6) IP source routing protection level"
    $value = "Enabled: Highest protection, source routing is completely disabled"
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
        Write-Host "Successfully applied CIS Control 18.5.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.5.2: $_" -ForegroundColor Red
    exit 1
}
