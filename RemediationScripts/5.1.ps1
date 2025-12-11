<#
.SYNOPSIS
    CIS Control 5.1 - 5.1 (L2) Ensure 'Bluetooth Audio Gateway Service (BTAGService)' is set to 'Disab

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to: Disabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Bluetooth Audio Gateway Service
 
Note: This service was first introduced in Windows 10 Release 1803. It appears to have re...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 5.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\5.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 5.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 5.1 (L2) Ensure 'Bluetooth Audio Gateway Service (BTAGService)' is set to 'Disabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to: Disabled :
 
Computer Configuration\Policies\Windows Settings\Security Settings\System Services\Bluetooth Audio Gateway Service
 
Note: This service was first introduced in Windows 10 Release 1803. It appears to have replaced the older
 
Bluetooth Handsfree Service (BthHFSrv)
 
, which was removed from Windows in that release (it is not simply a rename, but a different service).
 
Impact:
 
Bluetooth hands-free devi"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
