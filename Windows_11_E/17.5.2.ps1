#Requires -RunAsAdministrator
# 17.5.2 (L1) Ensure 'Audit Group Membership' is set to include 'Success'
auditpol /set /subcategory:"{0cce9249-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
