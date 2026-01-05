#Requires -RunAsAdministrator
# 17.7.3 (L1) Ensure 'Audit Authorization Policy Change' is set to include 'Success'
auditpol /set /subcategory:"{0cce9231-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
