<#
.SYNOPSIS
    CIS Control 2.3.11.6 - 2.3.11.6 (L1) Ensure 'Network security: Force logoff when logon hours expire' is

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Force logoff when logon hours expire
 
Impact:
 
None - this is the default behavior.

See Al...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.11.6
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.11.6.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.11.6" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.11.6 (L1) Ensure 'Network security: Force logoff when logon hours expire' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Force logoff when logon hours expire
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.1.2


800-171R3
03.01.01


800-53
AC-2(12)


800-53R5
AC-2(12)


CN-L3
7.1.3.2(d)


CSCV7
16.13


CSF
DE.CM-1


CSF"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
