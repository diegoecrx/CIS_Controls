#Requires -RunAsAdministrator
# 1.2.1 (L1) Ensure 'Account lockout duration' is set to '15 or more minute(s)'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
LockoutDuration=15
"@
$tempFile = "$env:TEMP\1.2.1.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.2.1.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
