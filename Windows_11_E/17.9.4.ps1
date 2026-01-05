#Requires -RunAsAdministrator
# 17.9.4 (L1) Ensure 'Audit Security System Extension' is set to include 'Success'
auditpol /set /subcategory:"{0cce9211-69ae-11d9-bed3-505054503030}" /success:enable /failure:disable
