#Requires -RunAsAdministrator
# 1.1.7 (L1) Ensure 'Store passwords using reversible encryption' is set to 'Disabled'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[System Access]
ClearTextPassword=0
"@
$tempFile = "$env:TEMP\1.1.7.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\1.1.7.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
