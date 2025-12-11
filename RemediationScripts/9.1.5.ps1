<#
.SYNOPSIS
    CIS Control 9.1.5 - 9.1.5 (L1) Ensure 'Windows Firewall: Domain: Logging: Size limit (KB)' is set to

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to 16,384 KB or greater :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Prop...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 9.1.5
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\9.1.5.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 9.1.5" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 9.1.5 (L1) Ensure 'Windows Firewall: Domain: Logging: Size limit (KB)' is set to '16,384 KB or greater'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to 16,384 KB or greater :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security\Windows Defender Firewall with Advanced Security\Windows Defender Firewall Properties\Domain Profile\Logging Customize\Size limit (KB)
 
Impact:
 
The log file size will be limited to the specified size, old events will be overwritten by newer ones when the limit is reached.

Se"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
