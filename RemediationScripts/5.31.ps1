<#
.SYNOPSIS
    CIS Control 5.31 - 5.31 (L2) Ensure 'Windows Event Collector (Wecsvc)' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Event Collector
 
Impact:
 
If this service is stopped or disabled event subscriptions cannot be created and forwarde...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.31
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.31.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.31" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.31 (L2) Ensure 'Windows Event Collector (Wecsvc)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Event Collector
 
Impact:
 
If this service is stopped or disabled event subscriptions cannot be created and forwarded events cannot be accepted.
 
Note: Many remote management tools and third-party security audit tools depend on this service.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References
"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
