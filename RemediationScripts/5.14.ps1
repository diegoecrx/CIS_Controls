<#
.SYNOPSIS
    CIS Control 5.14 - 5.14 (L2) Ensure 'Print Spooler (Spooler)' is set to 'Disabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Print Spooler
 
Impact:
 
Users will not be able to print, including printing to files (such as Adobe Portable Document For...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.14
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.14.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.14" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.14 (L2) Ensure 'Print Spooler (Spooler)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Print Spooler
 
Impact:
 
Users will not be able to print, including printing to files (such as Adobe Portable Document Format (PDF)) which uses the Print Spooler service.

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


"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
