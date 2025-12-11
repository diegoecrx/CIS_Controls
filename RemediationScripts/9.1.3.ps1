<#
.SYNOPSIS
    CIS Control 9.1.3 - 9.1.3 (L1) Ensure 'Windows Firewall: Domain: Settings: Display a notification' i

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to No :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Prof...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.1.3
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.1.3.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.1.3" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.1.3 (L1) Ensure 'Windows Firewall: Domain: Settings: Display a notification' is set to 'No'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to No :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Profile\Settings Customize\Display a notification
 
Impact:
 
Windows Firewall will not display a notification when a program is blocked from receiving inbound connections.

See Also

https://workbench.ci"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
