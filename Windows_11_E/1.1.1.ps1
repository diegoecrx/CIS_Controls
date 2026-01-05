#Requires -RunAsAdministrator
# 1.1.1 (L1) Ensure 'Enforce password history' is set to '24 or more password(s)'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
PasswordHistorySize=24
"@
$tempFile = "$env:TEMP\1.1.1.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.1.1.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
