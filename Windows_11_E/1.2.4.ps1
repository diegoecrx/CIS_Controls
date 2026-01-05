#Requires -RunAsAdministrator
# 1.2.4 (L1) Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
ResetLockoutCount=15
"@
$tempFile = "$env:TEMP\1.2.4.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.2.4.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
