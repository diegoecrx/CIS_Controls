<#
.SYNOPSIS
    CIS Control 2.3.11.13 - 2.3.11.13 (L1) Ensure 'Network security: Restrict NTLM: Outgoing NTLM traffic to

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Audit all or higher:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers
 
Impact:
 
The event log...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.11.13
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.11.13.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.11.13" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.11.13 (L1) Ensure 'Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers' is set to 'Audit all' or higher" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Audit all or higher:
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers
 
Impact:
 
The event log will contain information on outgoing NTLM authentication traffic.

See Also

https://workbench.cisecurity.org/benchmarks/21318

References









800-171
3.3.1


800-171
3.3.2


800-171
3.3.6


800"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
