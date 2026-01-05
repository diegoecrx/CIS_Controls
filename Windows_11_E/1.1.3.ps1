#Requires -RunAsAdministrator
# 1.1.3 (L1) Ensure 'Minimum password age' is set to '1 or more day(s)'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
MinPasswordAge=1
"@
$tempFile = "$env:TEMP\1.1.3.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.1.3.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
