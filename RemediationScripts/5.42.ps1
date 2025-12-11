<#
.SYNOPSIS
    CIS Control 5.42 - 5.42 (L1) Ensure 'Xbox Live Networking Service (XboxNetApiSvc)' is set to 'Disab

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Xbox Live Networking Service
 
Impact:
 
Connections to Xbox Live may fail and applications that interact with that service m...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.42
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.42.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.42" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.42 (L1) Ensure 'Xbox Live Networking Service (XboxNetApiSvc)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Xbox Live Networking Service
 
Impact:
 
Connections to Xbox Live may fail and applications that interact with that service may also fail.

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


800-171R3
03.04.06


800-53
CM-6


"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
