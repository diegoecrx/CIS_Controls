<#
.SYNOPSIS
    CIS Control 5.37 - 5.37 (L2) Ensure 'WinHTTP Web Proxy Auto-Discovery Service (WinHttpAutoProxySvc)

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\WinHTTP Web Proxy Auto-Discovery Service
 
Impact:
 
WPAD will cease to function for automatic HTTP proxy routing, which may ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.37
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.37.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.37" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.37 (L2) Ensure 'WinHTTP Web Proxy Auto-Discovery Service (WinHttpAutoProxySvc)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\WinHTTP Web Proxy Auto-Discovery Service
 
Impact:
 
WPAD will cease to function for automatic HTTP proxy routing, which may prevent Internet connectivity for workstations in organizations that currently use WPAD. Microsoft also cautions that some software that uses the network stack may have a functional dependency on this service.

Please refer to the CIS Benchmark documentation for complete details." -ForegroundColor White
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
