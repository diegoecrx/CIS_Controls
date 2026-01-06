# CIS Windows 11 Enterprise - Section 18 Configuration Test
# Test without registry modifications

\ = Get-Date
\ = @()

# Load settings
\ = Import-PowerShellDataFile -Path "section18_settings.psd1"
Write-Host "Loaded \ total settings"

# Count by category
\ = @{
    "18.1" = 0
    "18.4" = 0
    "18.5" = 0
    "18.6" = 0
    "18.7" = 0
    "18.8" = 0
    "18.9" = 0
    "18.10" = 0
}

\.Settings | ForEach-Object {
    \System.Collections.Hashtable = \.Control.Split('.')[0..1] -join '.'
    \[\System.Collections.Hashtable]++
}

Write-Host "Settings by category:" -ForegroundColor Cyan
\.GetEnumerator() | Sort-Object Name | ForEach-Object { Write-Host "  \: \" }
