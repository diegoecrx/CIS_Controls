#Requires -RunAsAdministrator
# 1.2.2 (L1) Ensure 'Account lockout threshold' is set to '5 or fewer invalid logon attempt(s), but not 0'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
LockoutBadCount=5
"@
$tempFile = "$env:TEMP\1.2.2.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.2.2.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
