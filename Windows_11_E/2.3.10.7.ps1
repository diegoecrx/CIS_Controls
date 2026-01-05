#Requires -RunAsAdministrator
# 2.3.10.7 (L1) Ensure 'Network access: Remotely accessible registry paths' is configured
# Note: Configure based on your organizational requirements
$regPaths = @()
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths" -Name "Machine" -Value $regPaths -Type MultiString -Force -ErrorAction SilentlyContinue
