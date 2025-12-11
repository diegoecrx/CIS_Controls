<#
.SYNOPSIS
    CIS Control 18.10.16.2 - 18.10.16.2 (L2) Ensure 'Configure Authenticated Proxy usage for the Connected Us

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: Disable Authenticated Proxy usage :
 
Computer Configuration\Policies\Administrative Templates\Windows Componen...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.10.16.2
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: Configure Authenticated Proxy usage for the Connected User Experience and Telemetry service
    Recommended Value: Enabled: Disable Authenticated Proxy usage
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.10.16.2.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.10.16.2..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "Configure Authenticated Proxy usage for the Connected User Experience and Telemetry service"
    $value = "Enabled: Disable Authenticated Proxy usage"
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
        Write-Host "Successfully applied CIS Control 18.10.16.2" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.10.16.2: $_" -ForegroundColor Red
    exit 1
}
