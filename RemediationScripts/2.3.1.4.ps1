<#
.SYNOPSIS
    CIS Control 2.3.1.4 - 2.3.1.4 (L1) Configure 'Accounts: Rename guest account'

.DESCRIPTION
    To establish the recommended configuration via GP, configure the following UI path:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Accounts: Rename guest account
 
Impact:
 
There should be little impact, because the Guest account is disabled by ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.1.4
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.1.4.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.1.4" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.1.4 (L1) Configure 'Accounts: Rename guest account'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, configure the following UI path:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Accounts: Rename guest account
 
Impact:
 
There should be little impact, because the Guest account is disabled by default.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.5.2


800-171R3
03.05.12


800-53
IA-5


800-53R5
IA-5


CSCV8
4.7


CSF
PR.AC-1


CSF2.0
PR.AA-01
"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
