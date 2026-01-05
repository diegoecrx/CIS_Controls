#Requires -RunAsAdministrator
# 17.9.3 (L1) Ensure 'Audit Security State Change' is set to include 'Success'
auditpol /set /subcategory:"{0cce9210-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
