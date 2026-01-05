#Requires -RunAsAdministrator
# 17.6.1 (L1) Ensure 'Audit Detailed File Share' is set to include 'Failure'
auditpol /set /subcategory:"{0cce9244-69ae-11d9-bed3-505054503030}" /success:disable /failure:enable
