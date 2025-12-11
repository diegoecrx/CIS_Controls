<#
.SYNOPSIS
    CIS Control 5.16 - 5.16 (L2) Ensure 'Remote Access Auto Connection Manager (RasAuto)' is set to 'Di

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Access Auto Connection Manager
 
Impact:
 
'Dial on demand' functionality will no longer operate - remote dial-in (POT...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.16
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.16.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.16" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.16 (L2) Ensure 'Remote Access Auto Connection Manager (RasAuto)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Remote Access Auto Connection Manager
 
Impact:
 
'Dial on demand' functionality will no longer operate - remote dial-in (POTS) and VPN connections must be initiated manually by the user.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.4.2


800-171
3.4.6


800-171
3.4.7


800-171"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
