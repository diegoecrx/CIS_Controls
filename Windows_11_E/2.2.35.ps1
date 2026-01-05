#Requires -RunAsAdministrator
# 2.2.35 (L1) Ensure 'Profile system performance' is set to 'Administrators, NT SERVICE\WdiServiceHost'
$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
revision=1
[Privilege Rights]
SeSystemProfilePrivilege = *S-1-5-32-544
"@
$tempFile = "$env:TEMP\2.2.35.inf"
$infContent | Out-File -FilePath $tempFile -Encoding Unicode -Force
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $tempFile /log "$env:TEMP\2.2.35.log" /quiet
Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
