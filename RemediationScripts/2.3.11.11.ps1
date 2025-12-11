<#
.SYNOPSIS
    CIS Control 2.3.11.11 - 2.3.11.11 (L1) Ensure 'Network security: Minimum session security for NTLM SSP b

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Require NTLMv2 session security, Require 128-bit encryption :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Minimum session security for NTLM SSP b...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 2.3.11.11
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\2.3.11.11.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 2.3.11.11" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 2.3.11.11 (L1) Ensure 'Network security: Minimum session security for NTLM SSP based (including secure RPC) servers' is set to 'Require NTLMv2 session security, Require 128-bit encryption'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Require NTLMv2 session security, Require 128-bit encryption :
 
Computer Configuration\Policies\Windows Settings\Security Settings\Local Policies\Security Options\Network security: Minimum session security for NTLM SSP based (including secure RPC) servers
 
Impact:
 
NTLM connections will fail if NTLMv2 protocol and strong encryption (128-bit) are not both negotiated. Server applications that are enforcing these sett"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
