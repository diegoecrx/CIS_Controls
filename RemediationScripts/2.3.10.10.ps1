<#
.SYNOPSIS
    CIS Control 2.3.10.10 - 2.3.10.10 (L1) Ensure 'Network access: Restrict clients allowed to make remote c

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Administrators: Remote Access: Allow :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network access: Restrict clients allowed to make remote calls to SAM
 
Impact:
 ...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.10.10
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.10.10.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.10.10" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.10.10 (L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Administrators: Remote Access: Allow :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network access: Restrict clients allowed to make remote calls to SAM
 
Impact:
 
None - this is the default behavior.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.1.5


800-171R3
03.01.05a.


800-53
AC-6(3)


800-53R5
AC-6(3)


CN-L3"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
