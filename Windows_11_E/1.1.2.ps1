#Requires -RunAsAdministrator
# 1.1.2 (L1) Ensure 'Maximum password age' is set to '365 or fewer days, but not 0'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
MaxPasswordAge=365
"@
$tempFile = "$env:TEMP\1.1.2.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.1.2.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
