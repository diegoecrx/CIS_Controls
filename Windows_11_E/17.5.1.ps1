#Requires -RunAsAdministrator
# 17.5.1 (L1) Ensure 'Audit Account Lockout' is set to include 'Failure'
auditpol /set /subcategory:"{0cce9217-69ae-11d9-bed3-505054503030}" /success:disable /failure:enable
