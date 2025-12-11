<#
.SYNOPSIS
    CIS Control 2.3.11.2 - 2.3.11.2 (L1) Ensure 'Network security: Allow LocalSystem NULL session fallback'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Allow LocalSystem NULL session fallback
 
Impact:
 
None - this is the default behavior. A...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.11.2
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.11.2.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.11.2" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.11.2 (L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Disabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Allow LocalSystem NULL session fallback
 
Impact:
 
None - this is the default behavior. Any applications that require NULL sessions for LocalSystem will not work as designed.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.1.7


800-171R3
03.01."
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
