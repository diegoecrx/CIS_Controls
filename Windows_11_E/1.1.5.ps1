#Requires -RunAsAdministrator
# 1.1.5 (L1) Ensure 'Password must meet complexity requirements' is set to 'Enabled'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
PasswordComplexity=1
"@
$tempFile = "$env:TEMP\1.1.5.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.1.5.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
