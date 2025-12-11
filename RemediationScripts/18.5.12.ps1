<#
.SYNOPSIS
    CIS Control 18.5.12 - 18.5.12 (L2) Ensure 'MSS: (TcpMaxDataRetransmissions) How many times unacknowled

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled: 3 :
 
Computer Configuration\Policies\Administrative Templates\MSS (Legacy)\MSS:(TcpMaxDataRetransmissions) How...

.NOTES
    This script requires administrative privileges.
    It modifies registry settings.
    
    CIS Control: 18.5.12
    Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows
    Value Name: MSS:(TcpMaxDataRetransmissions) How many times unacknowledged data is retransmitted
    Recommended Value: Enabled: 3
    
.EXAMPLE
    Run this script with administrative privileges:
    PS> .\18.5.12.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "Applying CIS Control 18.5.12..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
    $valueName = "MSS:(TcpMaxDataRetransmissions) How many times unacknowledged data is retransmitted"
    $value = "Enabled: 3"
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
        Write-Host "Successfully applied CIS Control 18.5.12" -ForegroundColor Green
    } else {
        Write-Host "Warning: Verification failed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Error applying CIS Control 18.5.12: $_" -ForegroundColor Red
    exit 1
}
