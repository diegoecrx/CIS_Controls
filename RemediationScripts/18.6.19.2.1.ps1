<#
.SYNOPSIS
    CIS Control 18.6.19.2.1 - 18.6.19.2.1 (L2) Disable IPv6 (Ensure TCPIP6 Parameter 'DisabledComponents' is s

.DESCRIPTION
    To establish the recommended configuration, set the following Registry value to 0xff (255) (DWORD) :
 
HKLM\SYSTEM\CurrentControlSet\Services\TCPIP6\Parameters:DisabledComponents
 
Note: This change does not take effect until the computer has been restarted.
 
Note #2: Although Microsoft does not pr...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 18.6.19.2.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\18.6.19.2.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 18.6.19.2.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 18.6.19.2.1 (L2) Disable IPv6 (Ensure TCPIP6 Parameter 'DisabledComponents' is set to '0xff (255)')" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration, set the following Registry value to 0xff (255) (DWORD) :
 
HKLM\SYSTEM\CurrentControlSet\Services\TCPIP6\Parameters:DisabledComponents
 
Note: This change does not take effect until the computer has been restarted.
 
Note #2: Although Microsoft does not provide an ADMX template to configure this registry value, a custom .ADM template ( Disable-IPv6-Components-KB929852.adm ) is provided in the CIS Benchmark Build Kit to facilitate its configuration. Be "
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
