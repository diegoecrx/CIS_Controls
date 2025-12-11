<#
.SYNOPSIS
    CIS Control 5.19 - 5.19 (L2) Ensure 'Remote Desktop Services UserMode Port Redirector (UmRdpService

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Desktop Services UserMode Port Redirector
 
Impact:
 
Printers, drives and ports (COM, LPT, PnP, etc.) will not be all...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.19
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.19.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.19" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.19 (L2) Ensure 'Remote Desktop Services UserMode Port Redirector (UmRdpService)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Desktop Services UserMode Port Redirector
 
Impact:
 
Printers, drives and ports (COM, LPT, PnP, etc.) will not be allowed to be redirected inside RDP sessions.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.4.2


800-171
3.4.6


800-171
3.4.7


800-171R3
03.04.02


800-17"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
