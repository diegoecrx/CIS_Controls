<#
.SYNOPSIS
    CIS Control 5.34 - 5.34 (L2) Ensure 'Windows Push Notifications System Service (WpnService)' is set

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Push Notifications System Service
 
Impact:
 
Live Tiles and other features will not get live updates.

See Also

htt...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.34
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.34.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.34" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.34 (L2) Ensure 'Windows Push Notifications System Service (WpnService)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Push Notifications System Service
 
Impact:
 
Live Tiles and other features will not get live updates.

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


800-53
CM-7


800-53R5
CM-6
"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
