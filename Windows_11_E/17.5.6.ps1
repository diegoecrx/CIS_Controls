#Requires -RunAsAdministrator
# 17.5.6 (L1) Ensure 'Audit Special Logon' is set to include 'Success'
auditpol /set /subcategory:"{0cce921b-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
