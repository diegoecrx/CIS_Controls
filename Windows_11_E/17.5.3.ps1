#Requires -RunAsAdministrator
# 17.5.3 (L1) Ensure 'Audit Logoff' is set to include 'Success'
auditpol /set /subcategory:"{0cce9216-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
