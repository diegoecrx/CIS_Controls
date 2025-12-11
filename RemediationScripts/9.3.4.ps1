<#
.SYNOPSIS
    CIS Control 9.3.4 - 9.3.4 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local firewall rule

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to No :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Prof...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.3.4
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.3.4.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.3.4" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.3.4 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local firewall rules' is set to 'No'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to No :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Profile\Settings Customize\Apply local firewall rules
 
Impact:
 
Administrators can still create firewall rules, but the rules will not be applied.

See Also

https://workbench.cisecurity.org/benchmarks/"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
