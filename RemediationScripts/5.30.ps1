<#
.SYNOPSIS
    CIS Control 5.30 - 5.30 (L2) Ensure 'Windows Error Reporting Service (WerSvc)' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Error Reporting Service
 
Impact:
 
If this service is stopped, error reporting might not work correctly and results ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.30
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.30.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.30" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.30 (L2) Ensure 'Windows Error Reporting Service (WerSvc)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Error Reporting Service
 
Impact:
 
If this service is stopped, error reporting might not work correctly and results of diagnostic services and repairs might not be displayed.

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
0"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
