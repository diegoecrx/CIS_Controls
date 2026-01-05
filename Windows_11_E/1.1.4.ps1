#Requires -RunAsAdministrator
# 1.1.4 (L1) Ensure 'Minimum password length' is set to '14 or more character(s)'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
MinimumPasswordLength=14
"@
$tempFile = "$env:TEMP\1.1.4.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.1.4.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
