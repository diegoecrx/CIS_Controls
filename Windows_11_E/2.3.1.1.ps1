#Requires -RunAsAdministrator
# 2.3.1.1 (L1) Ensure 'Accounts: Guest account status' is set to 'Disabled'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
EnableGuestAccount = 0
"@
$tempFile = "$env:TEMP\2.3.1.1.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.3.1.1.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
