#Requires -RunAsAdministrator
# 17.7.1 (L1) Ensure 'Audit Audit Policy Change' is set to include 'Success'
auditpol /set /subcategory:"{0cce922f-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
