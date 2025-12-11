<#
.SYNOPSIS
    CIS Control 5.32 - 5.32 (L1) Ensure 'Windows Media Player Network Sharing Service (WMPNetworkSvc)' 

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled or ensure the service is not installed.
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Media Player Network Sharing Service
 
Impact:
 
Windows Media Player librari...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.32
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.32.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.32" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.32 (L1) Ensure 'Windows Media Player Network Sharing Service (WMPNetworkSvc)' is set to 'Disabled' or 'Not Installed'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled or ensure the service is not installed.
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Windows Media Player Network Sharing Service
 
Impact:
 
Windows Media Player libraries will not be shared over the network to other devices and systems.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.4.2


800-171
3.4.6


800-171
3.4.7


8"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
