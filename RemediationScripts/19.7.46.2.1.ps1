<#
.SYNOPSIS
    CIS Control 19.7.46.2.1 - 19.7.46.2.1 (L2) Ensure 'Prevent Codec Download' is set to 'Enabled'

.DESCRIPTION
    To establish the recommended configuration via GP, set the following UI path to Enabled:
 
User Configuration\Policies\Administrative Templates\Windows Components\Windows Media Player\Playback\Prevent Codec Download
 
Note: This Group Policy path is provided by the Group Policy template WindowsMedia...

.NOTES
    This script requires administrative privileges.
    
    CIS Control: 19.7.46.2.1
    
    This control requires manual configuration or complex automation beyond
    simple registry/policy changes.
    
.EXAMPLE
    PS> .\19.7.46.2.1.ps1
#>

#Requires -RunAsAdministrator

Write-Host "CIS Control 19.7.46.2.1" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Control: 19.7.46.2.1 (L2) Ensure 'Prevent Codec Download' is set to 'Enabled'" -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Cyan
Write-Host "To establish the recommended configuration via GP, set the following UI path to Enabled:
 
User Configuration\Policies\Administrative Templates\Windows Components\Windows Media Player\Playback\Prevent Codec Download
 
Note: This Group Policy path is provided by the Group Policy template WindowsMediaPlayer.admx/adml that is included with all versions of the Microsoft Windows Administrative Templates.
 
Impact:
 
Windows Media Player is prevented from automatically downloading codecs to your compu"
Write-Host ""
Write-Host "This control requires manual review and configuration." -ForegroundColor Yellow
Write-Host "Please refer to the CIS Benchmark documentation for detailed steps." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow

Write-Host ""
Write-Host "This control requires manual configuration." -ForegroundColor Yellow
Write-Host "Review the information above and apply the settings manually." -ForegroundColor Yellow
