<#
.SYNOPSIS
    CIS Control 2.3.11.12 - 2.3.11.12 (L1) Ensure 'Network security: Restrict NTLM: Audit Incoming NTLM Traf

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enable auditing for all accounts :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Restrict NTLM: Audit Incoming NTLM Traffic
 
Impact:
 
The event l...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.11.12
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.11.12.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.11.12" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.11.12 (L1) Ensure 'Network security: Restrict NTLM: Audit Incoming NTLM Traffic' is set to 'Enable auditing for all accounts'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enable auditing for all accounts :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Restrict NTLM: Audit Incoming NTLM Traffic
 
Impact:
 
The event log will contain information on incoming NTLM authentication traffic.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.3.1


800-171
3.3.2


800-171
3.3.6


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
