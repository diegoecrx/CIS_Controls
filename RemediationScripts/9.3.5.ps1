<#
.SYNOPSIS
    CIS Control 9.3.5 - 9.3.5 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local connection se

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to No :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Prof...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.3.5
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.3.5.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.3.5" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.3.5 (L1) Ensure 'Windows Firewall: Public: Settings: Apply local connection security rules' is set to 'No'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to No :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Public Profile\Settings Customize\Apply local connection security rules
 
Impact:
 
Administrators can still create local connection security rules, but the rules will not be applied.

See Also

https://workbenc"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow
