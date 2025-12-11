<#
.SYNOPSIS
    CIS Control 5.23 - 5.23 (L2) Ensure 'Server (LanmanServer)' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Server
 
Impact:
 
File, print and named-pipe sharing functions will be unavailable from this machine over the network.
 
Not...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.23
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.23.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.23" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.23 (L2) Ensure 'Server (LanmanServer)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Server
 
Impact:
 
File, print and named-pipe sharing functions will be unavailable from this machine over the network.
 
Note: Many remote administration tools, such as System Center Configuration Manager (SCCM), require the Server service to be operational for remote management. In addition, many vulnerability scanners us"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
