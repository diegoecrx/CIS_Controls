@{
    # CIS Windows 11 Enterprise v3.0.0 - Section 18 Administrative Templates (Computer)
    # Registry-based policy settings
    Settings = @(
        # Section 18.1 - Control Panel
        @{ Control = '18.1.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'; Name = 'NoLockScreenCamera'; Value = 1; Type = 'DWord'; Description = 'Prevent enabling lock screen camera' }
        @{ Control = '18.1.1.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'; Name = 'NoLockScreenSlideshow'; Value = 1; Type = 'DWord'; Description = 'Prevent enabling lock screen slide show' }
        @{ Control = '18.1.2.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'; Name = 'AllowInputPersonalization'; Value = 0; Type = 'DWord'; Description = 'Disallow online speech recognition services' }
        @{ Control = '18.1.3'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'AllowOnlineTips'; Value = 0; Type = 'DWord'; Description = 'Disable Allow Online Tips' }

        # Section 18.4 - MS Security Guide
        @{ Control = '18.4.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'LocalAccountTokenFilterPolicy'; Value = 0; Type = 'DWord'; Description = 'Apply UAC restrictions to local accounts on network logons' }
        @{ Control = '18.4.2'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10'; Name = 'Start'; Value = 4; Type = 'DWord'; Description = 'Disable SMB v1 client driver' }
        @{ Control = '18.4.3'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'; Name = 'SMB1'; Value = 0; Type = 'DWord'; Description = 'Disable SMB v1 server' }
        @{ Control = '18.4.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config'; Name = 'EnableCertPaddingCheck'; Value = '1'; Type = 'String'; Description = 'Enable Certificate Padding' }
        @{ Control = '18.4.5'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'; Name = 'DisableExceptionChainValidation'; Value = 0; Type = 'DWord'; Description = 'Enable SEHOP' }
        @{ Control = '18.4.6'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters'; Name = 'NodeType'; Value = 2; Type = 'DWord'; Description = 'NetBT NodeType P-node' }
        @{ Control = '18.4.7'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'; Name = 'UseLogonCredential'; Value = 0; Type = 'DWord'; Description = 'Disable WDigest Authentication' }

        # Section 18.5 - MSS Legacy
        @{ Control = '18.5.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'; Name = 'AutoAdminLogon'; Value = '0'; Type = 'String'; Description = 'Disable AutoAdminLogon' }
        @{ Control = '18.5.2'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'; Name = 'DisableIPSourceRouting'; Value = 2; Type = 'DWord'; Description = 'DisableIPSourceRouting IPv6 Highest protection' }
        @{ Control = '18.5.3'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name = 'DisableIPSourceRouting'; Value = 2; Type = 'DWord'; Description = 'DisableIPSourceRouting Highest protection' }
        @{ Control = '18.5.4'; Level = 'L2'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Parameters'; Name = 'DisableSavePassword'; Value = 1; Type = 'DWord'; Description = 'Prevent dial-up password saving' }
        @{ Control = '18.5.5'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name = 'EnableICMPRedirect'; Value = 0; Type = 'DWord'; Description = 'Disable ICMP redirects override OSPF' }
        @{ Control = '18.5.6'; Level = 'L2'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name = 'KeepAliveTime'; Value = 300000; Type = 'DWord'; Description = 'KeepAliveTime 300000ms' }
        @{ Control = '18.5.7'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters'; Name = 'NoNameReleaseOnDemand'; Value = 1; Type = 'DWord'; Description = 'Ignore NetBIOS name release requests' }
        @{ Control = '18.5.8'; Level = 'L2'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name = 'PerformRouterDiscovery'; Value = 0; Type = 'DWord'; Description = 'Disable IRDP router discovery' }
        @{ Control = '18.5.9'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'; Name = 'SafeDllSearchMode'; Value = 1; Type = 'DWord'; Description = 'Enable Safe DLL search mode' }
        @{ Control = '18.5.10'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'; Name = 'ScreenSaverGracePeriod'; Value = '5'; Type = 'String'; Description = 'ScreenSaver grace period 5 seconds' }
        @{ Control = '18.5.11'; Level = 'L2'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'; Name = 'TcpMaxDataRetransmissions'; Value = 3; Type = 'DWord'; Description = 'TcpMaxDataRetransmissions IPv6 = 3' }
        @{ Control = '18.5.12'; Level = 'L2'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name = 'TcpMaxDataRetransmissions'; Value = 3; Type = 'DWord'; Description = 'TcpMaxDataRetransmissions = 3' }
        @{ Control = '18.5.13'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security'; Name = 'WarningLevel'; Value = 90; Type = 'DWord'; Description = 'Security log warning level 90%' }

        # Section 18.6 - Network
        @{ Control = '18.6.4.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name = 'EnableMulticast'; Value = 0; Type = 'DWord'; Description = 'Turn off multicast name resolution LLMNR' }
        @{ Control = '18.6.4.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name = 'DisableSmartNameResolution'; Value = 1; Type = 'DWord'; Description = 'Disable NetBIOS smart name resolution' }
        @{ Control = '18.6.5.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'EnableFontProviders'; Value = 0; Type = 'DWord'; Description = 'Disable Font Providers' }
        @{ Control = '18.6.8.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation'; Name = 'AllowInsecureGuestAuth'; Value = 0; Type = 'DWord'; Description = 'Disable insecure guest logons' }
        @{ Control = '18.6.10.2'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Peernet'; Name = 'Disabled'; Value = 1; Type = 'DWord'; Description = 'Turn off Peer-to-Peer Networking Services' }
        @{ Control = '18.6.11.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections'; Name = 'NC_AllowNetBridge_NLA'; Value = 0; Type = 'DWord'; Description = 'Prohibit Network Bridge' }
        @{ Control = '18.6.11.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections'; Name = 'NC_ShowSharedAccessUI'; Value = 0; Type = 'DWord'; Description = 'Prohibit Internet Connection Sharing' }
        @{ Control = '18.6.11.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections'; Name = 'NC_StdDomainUserSetLocation'; Value = 1; Type = 'DWord'; Description = 'Require elevation for network location' }
        @{ Control = '18.6.19.2.1'; Level = 'L2'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'; Name = 'DisabledComponents'; Value = 255; Type = 'DWord'; Description = 'Disable IPv6' }
        @{ Control = '18.6.21.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'; Name = 'fMinimizeConnections'; Value = 3; Type = 'DWord'; Description = 'Minimize simultaneous connections' }
        @{ Control = '18.6.21.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'; Name = 'fBlockNonDomain'; Value = 1; Type = 'DWord'; Description = 'Block non-domain networks when on domain' }
        @{ Control = '18.6.23.2.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config'; Name = 'AutoConnectAllowedOEM'; Value = 0; Type = 'DWord'; Description = 'Disable auto-connect to suggested hotspots' }

        # Section 18.7 - Printers
        @{ Control = '18.7.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers'; Name = 'RegisterSpoolerRemoteRpcEndPoint'; Value = 2; Type = 'DWord'; Description = 'Disable Print Spooler client connections' }
        @{ Control = '18.7.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers'; Name = 'RedirectionguardPolicy'; Value = 1; Type = 'DWord'; Description = 'Enable Redirection Guard' }
        @{ Control = '18.7.7'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC'; Name = 'RpcTcpPort'; Value = 0; Type = 'DWord'; Description = 'Configure RPC over TCP port 0' }
        @{ Control = '18.7.10'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'; Name = 'RestrictDriverInstallationToAdministrators'; Value = 1; Type = 'DWord'; Description = 'Limit print driver installation to Administrators' }
        @{ Control = '18.7.12'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'; Name = 'NoWarningNoElevationOnInstall'; Value = 0; Type = 'DWord'; Description = 'Point and Print show warning on install' }
        @{ Control = '18.7.13'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint'; Name = 'UpdatePromptSettings'; Value = 0; Type = 'DWord'; Description = 'Point and Print show warning on update' }

        # Section 18.8 - Start Menu and Taskbar
        @{ Control = '18.8.1.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'; Name = 'NoCloudApplicationNotification'; Value = 1; Type = 'DWord'; Description = 'Turn off notifications network usage' }

        # Section 18.9 - System
        @{ Control = '18.9.3.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'; Name = 'ProcessCreationIncludeCmdLine_Enabled'; Value = 1; Type = 'DWord'; Description = 'Include command line in process creation events' }
        @{ Control = '18.9.4.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters'; Name = 'AllowEncryptionOracle'; Value = 0; Type = 'DWord'; Description = 'Encryption Oracle Remediation Force Updated Clients' }
        @{ Control = '18.9.4.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'; Name = 'AllowProtectedCreds'; Value = 1; Type = 'DWord'; Description = 'Allow delegation of non-exportable credentials' }
        @{ Control = '18.9.7.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Value = 1; Type = 'DWord'; Description = 'Prevent device metadata retrieval from Internet' }
        @{ Control = '18.9.13.1'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch'; Name = 'DriverLoadPolicy'; Value = 3; Type = 'DWord'; Description = 'Boot-Start Driver Initialization Policy' }
        @{ Control = '18.9.19.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}'; Name = 'NoBackgroundPolicy'; Value = 0; Type = 'DWord'; Description = 'Registry policy processing background' }
        @{ Control = '18.9.19.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}'; Name = 'NoGPOListChanges'; Value = 0; Type = 'DWord'; Description = 'Process even if GPO not changed' }
        @{ Control = '18.9.19.6'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'EnableCdp'; Value = 0; Type = 'DWord'; Description = 'Disable Continue experiences on this device' }
        @{ Control = '18.9.26.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'AllowCustomSSPsAPs'; Value = 0; Type = 'DWord'; Description = 'Disallow Custom SSPs and APs in LSASS' }
        @{ Control = '18.9.26.2'; Level = 'L1'; Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name = 'RunAsPPL'; Value = 1; Type = 'DWord'; Description = 'LSASS as protected process' }
        @{ Control = '18.9.28.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'BlockUserFromShowingAccountDetailsOnSignin'; Value = 1; Type = 'DWord'; Description = 'Block showing account details on sign-in' }
        @{ Control = '18.9.28.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'DontDisplayNetworkSelectionUI'; Value = 1; Type = 'DWord'; Description = 'Do not display network selection UI' }
        @{ Control = '18.9.28.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'DontEnumerateConnectedUsers'; Value = 1; Type = 'DWord'; Description = 'Do not enumerate connected users' }
        @{ Control = '18.9.28.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'EnumerateLocalUsers'; Value = 0; Type = 'DWord'; Description = 'Disable Enumerate local users' }
        @{ Control = '18.9.28.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'DisableLockScreenAppNotifications'; Value = 1; Type = 'DWord'; Description = 'Turn off app notifications on lock screen' }
        @{ Control = '18.9.28.6'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'BlockDomainPicturePassword'; Value = 1; Type = 'DWord'; Description = 'Turn off picture password sign-in' }
        @{ Control = '18.9.28.7'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'AllowDomainPINLogon'; Value = 0; Type = 'DWord'; Description = 'Disable convenience PIN sign-in' }
        @{ Control = '18.9.31.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'AllowCrossDeviceClipboard'; Value = 0; Type = 'DWord'; Description = 'Disable Clipboard sync across devices' }
        @{ Control = '18.9.31.2'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'UploadUserActivities'; Value = 0; Type = 'DWord'; Description = 'Disable upload of User Activities' }
        @{ Control = '18.9.33.6.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9'; Name = 'DCSettingIndex'; Value = 0; Type = 'DWord'; Description = 'Disable network during connected-standby battery' }
        @{ Control = '18.9.33.6.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9'; Name = 'ACSettingIndex'; Value = 0; Type = 'DWord'; Description = 'Disable network during connected-standby plugged' }
        @{ Control = '18.9.33.6.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'; Name = 'DCSettingIndex'; Value = 1; Type = 'DWord'; Description = 'Require password on wake battery' }
        @{ Control = '18.9.33.6.6'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'; Name = 'ACSettingIndex'; Value = 1; Type = 'DWord'; Description = 'Require password on wake plugged' }
        @{ Control = '18.9.35.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fAllowUnsolicited'; Value = 0; Type = 'DWord'; Description = 'Disable Offer Remote Assistance' }
        @{ Control = '18.9.35.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fAllowToGetHelp'; Value = 0; Type = 'DWord'; Description = 'Disable Solicited Remote Assistance' }
        @{ Control = '18.9.36.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc'; Name = 'EnableAuthEpResolution'; Value = 1; Type = 'DWord'; Description = 'Enable RPC Endpoint Mapper Client Authentication' }
        @{ Control = '18.9.36.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc'; Name = 'RestrictRemoteClients'; Value = 1; Type = 'DWord'; Description = 'Restrict Unauthenticated RPC clients' }
        @{ Control = '18.9.49.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; Name = 'DisabledByGroupPolicy'; Value = 1; Type = 'DWord'; Description = 'Turn off the advertising ID' }
        @{ Control = '18.9.51.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\W32Time\TimeProviders\NtpClient'; Name = 'Enabled'; Value = 1; Type = 'DWord'; Description = 'Enable Windows NTP Client' }
        @{ Control = '18.9.51.1.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\W32Time\TimeProviders\NtpServer'; Name = 'Enabled'; Value = 0; Type = 'DWord'; Description = 'Disable Windows NTP Server' }
        # Section 18.10 - Windows Components
        @{ Control = '18.10.3.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx'; Name = 'AllowAllTrustedApps'; Value = 0; Type = 'DWord'; Description = 'Disallow all trusted apps to install' }
        @{ Control = '18.10.4.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'; Name = 'LetAppsActivateWithVoice'; Value = 2; Type = 'DWord'; Description = 'Force Deny apps activate with voice' }
        @{ Control = '18.10.5.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'MSAOptional'; Value = 1; Type = 'DWord'; Description = 'Allow Microsoft accounts to be optional' }
        @{ Control = '18.10.5.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'BlockHostedAppAccessWinRT'; Value = 1; Type = 'DWord'; Description = 'Block UWP apps with WinRT API' }
        @{ Control = '18.10.7.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoAutoplayfornonVolume'; Value = 1; Type = 'DWord'; Description = 'Disallow Autoplay for non-volume devices' }
        @{ Control = '18.10.7.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoDriveTypeAutoRun'; Value = 255; Type = 'DWord'; Description = 'Do not execute autorun commands' }
        @{ Control = '18.10.7.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoAutorun'; Value = 1; Type = 'DWord'; Description = 'Turn off Autoplay All drives' }
        @{ Control = '18.10.8.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures'; Name = 'EnhancedAntiSpoofing'; Value = 1; Type = 'DWord'; Description = 'Enable enhanced anti-spoofing' }
        @{ Control = '18.10.9.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'; Name = 'DisableExternalDMAUnderLock'; Value = 1; Type = 'DWord'; Description = 'Disable new DMA devices when locked' }
        @{ Control = '18.10.10.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Camera'; Name = 'AllowCamera'; Value = 0; Type = 'DWord'; Description = 'Disable Use of Camera' }
        @{ Control = '18.10.12.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableConsumerAccountStateContent'; Value = 1; Type = 'DWord'; Description = 'Turn off cloud consumer account state content' }
        @{ Control = '18.10.12.3'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsConsumerFeatures'; Value = 1; Type = 'DWord'; Description = 'Turn off Microsoft consumer experiences' }
        @{ Control = '18.10.13.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect'; Name = 'RequirePinForPairing'; Value = 1; Type = 'DWord'; Description = 'Require pin for pairing First Time' }
        @{ Control = '18.10.14.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI'; Name = 'DisablePasswordReveal'; Value = 1; Type = 'DWord'; Description = 'Do not display password reveal button' }
        @{ Control = '18.10.14.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI'; Name = 'EnumerateAdministrators'; Value = 0; Type = 'DWord'; Description = 'Disable Enumerate administrator accounts on elevation' }
        @{ Control = '18.10.15.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowTelemetry'; Value = 0; Type = 'DWord'; Description = 'Diagnostic Data off or required only' }
        @{ Control = '18.10.15.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DisableOneSettingsDownloads'; Value = 1; Type = 'DWord'; Description = 'Disable OneSettings Downloads' }
        @{ Control = '18.10.15.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DoNotShowFeedbackNotifications'; Value = 1; Type = 'DWord'; Description = 'Do not show feedback notifications' }
        @{ Control = '18.10.15.6'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'EnableOneSettingsAuditing'; Value = 1; Type = 'DWord'; Description = 'Enable OneSettings Auditing' }
        @{ Control = '18.10.15.7'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'LimitDiagnosticLogCollection'; Value = 1; Type = 'DWord'; Description = 'Limit Diagnostic Log Collection' }
        @{ Control = '18.10.15.8'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'LimitDumpCollection'; Value = 1; Type = 'DWord'; Description = 'Limit Dump Collection' }
        @{ Control = '18.10.15.9'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'; Name = 'AllowBuildPreview'; Value = 0; Type = 'DWord'; Description = 'Disable Insider builds' }
        @{ Control = '18.10.25.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'; Name = 'MaxSize'; Value = 32768; Type = 'DWord'; Description = 'Application log max size 32768KB' }
        @{ Control = '18.10.25.2.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'; Name = 'MaxSize'; Value = 196608; Type = 'DWord'; Description = 'Security log max size 196608KB' }
        @{ Control = '18.10.25.3.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup'; Name = 'MaxSize'; Value = 32768; Type = 'DWord'; Description = 'Setup log max size 32768KB' }
        @{ Control = '18.10.25.4.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System'; Name = 'MaxSize'; Value = 32768; Type = 'DWord'; Description = 'System log max size 32768KB' }
        @{ Control = '18.10.26.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'NoHeapTerminationOnCorruption'; Value = 0; Type = 'DWord'; Description = 'Do not turn off heap termination on corruption' }
        @{ Control = '18.10.26.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'NoDataExecutionPrevention'; Value = 0; Type = 'DWord'; Description = 'Do not turn off shell protocol protected mode' }
        @{ Control = '18.10.28.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HomeGroup'; Name = 'DisableHomeGroup'; Value = 1; Type = 'DWord'; Description = 'Prevent joining homegroup' }
        @{ Control = '18.10.39.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount'; Name = 'DisableUserAuth'; Value = 1; Type = 'DWord'; Description = 'Block consumer Microsoft account auth' }
        @{ Control = '18.10.43.5.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'; Name = 'DisableFileSyncNGSC'; Value = 1; Type = 'DWord'; Description = 'Prevent OneDrive for file storage' }
        @{ Control = '18.10.50.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall'; Name = 'DisablePushToInstall'; Value = 1; Type = 'DWord'; Description = 'Turn off Push To Install service' }
        @{ Control = '18.10.51.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fDisableCcm'; Value = 1; Type = 'DWord'; Description = 'Disable COM port redirection' }
        @{ Control = '18.10.51.1.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fDisableLPT'; Value = 1; Type = 'DWord'; Description = 'Disable LPT port redirection' }
        @{ Control = '18.10.51.1.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fDisablePNPRedir'; Value = 1; Type = 'DWord'; Description = 'Disable PnP device redirection' }
        @{ Control = '18.10.51.2.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fPromptForPassword'; Value = 1; Type = 'DWord'; Description = 'Always prompt for password upon connection' }
        @{ Control = '18.10.51.2.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fEncryptRPCTraffic'; Value = 1; Type = 'DWord'; Description = 'Require secure RPC communication' }
        @{ Control = '18.10.51.2.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'SecurityLayer'; Value = 2; Type = 'DWord'; Description = 'Require SSL security layer for RDP' }
        @{ Control = '18.10.51.2.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'UserAuthentication'; Value = 1; Type = 'DWord'; Description = 'Require NLA for remote connections' }
        @{ Control = '18.10.51.2.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'MinEncryptionLevel'; Value = 3; Type = 'DWord'; Description = 'Set client encryption level High' }
        @{ Control = '18.10.51.3.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'fSingleSessionPerUser'; Value = 1; Type = 'DWord'; Description = 'Restrict to single RDS session' }
        @{ Control = '18.10.51.3.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name = 'DeleteTempDirsOnExit'; Value = 1; Type = 'DWord'; Description = 'Delete temp folders on exit' }
        @{ Control = '18.10.52.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds'; Name = 'DisableEnclosureDownload'; Value = 1; Type = 'DWord'; Description = 'Prevent downloading of enclosures' }
        @{ Control = '18.10.55.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortana'; Value = 0; Type = 'DWord'; Description = 'Disable Cortana' }
        @{ Control = '18.10.55.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortanaAboveLock'; Value = 0; Type = 'DWord'; Description = 'Disable Cortana above lock screen' }
        @{ Control = '18.10.55.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowIndexingEncryptedStoresOrItems'; Value = 0; Type = 'DWord'; Description = 'Disallow indexing encrypted files' }
        @{ Control = '18.10.55.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowSearchToUseLocation'; Value = 0; Type = 'DWord'; Description = 'Disallow search using location' }
        @{ Control = '18.10.61.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'; Name = 'DisableOSUpgrade'; Value = 1; Type = 'DWord'; Description = 'Turn off offer to update to latest Windows' }
        @{ Control = '18.10.69.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'AllowNewsAndInterests'; Value = 0; Type = 'DWord'; Description = 'Disable widgets' }
        @{ Control = '18.10.72.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; Name = 'DisableLocalAdminMerge'; Value = 1; Type = 'DWord'; Description = 'Disable local admin merge for lists' }
        @{ Control = '18.10.72.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; Name = 'DisableAntiSpyware'; Value = 0; Type = 'DWord'; Description = 'Enable Microsoft Defender AntiVirus' }
        @{ Control = '18.10.72.9.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'; Name = 'DisableBehaviorMonitoring'; Value = 0; Type = 'DWord'; Description = 'Enable behavior monitoring' }
        @{ Control = '18.10.72.9.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'; Name = 'DisableRealtimeMonitoring'; Value = 0; Type = 'DWord'; Description = 'Enable real-time protection' }
        @{ Control = '18.10.72.9.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'; Name = 'DisableScriptScanning'; Value = 0; Type = 'DWord'; Description = 'Enable script scanning' }
        @{ Control = '18.10.72.12.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan'; Name = 'DisableRemovableDriveScanning'; Value = 0; Type = 'DWord'; Description = 'Enable removable drives scanning' }
        @{ Control = '18.10.72.12.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan'; Name = 'DisableEmailScanning'; Value = 0; Type = 'DWord'; Description = 'Enable email scanning' }
        @{ Control = '18.10.75.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'EnableSmartScreen'; Value = 1; Type = 'DWord'; Description = 'Enable SmartScreen Warn and prevent bypass' }
        @{ Control = '18.10.78.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace'; Name = 'AllowWindowsInkWorkspace'; Value = 1; Type = 'DWord'; Description = 'Allow Windows Ink but disallow above lock' }
        @{ Control = '18.10.79.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'; Name = 'AlwaysInstallElevated'; Value = 0; Type = 'DWord'; Description = 'Disable Always install with elevated privileges' }
        @{ Control = '18.10.80.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'DisableAutomaticRestartSignOn'; Value = 1; Type = 'DWord'; Description = 'Disable auto sign-in after restart' }
        @{ Control = '18.10.87.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'; Name = 'EnableScriptBlockLogging'; Value = 1; Type = 'DWord'; Description = 'Enable PowerShell Script Block Logging' }
        @{ Control = '18.10.87.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription'; Name = 'EnableTranscripting'; Value = 1; Type = 'DWord'; Description = 'Enable PowerShell Transcription' }
        @{ Control = '18.10.89.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client'; Name = 'AllowBasic'; Value = 0; Type = 'DWord'; Description = 'Disable WinRM Client Basic authentication' }
        @{ Control = '18.10.89.1.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client'; Name = 'AllowUnencryptedTraffic'; Value = 0; Type = 'DWord'; Description = 'Disable WinRM Client unencrypted traffic' }
        @{ Control = '18.10.89.1.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client'; Name = 'AllowDigest'; Value = 0; Type = 'DWord'; Description = 'Disallow WinRM Client Digest authentication' }
        @{ Control = '18.10.89.2.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service'; Name = 'AllowBasic'; Value = 0; Type = 'DWord'; Description = 'Disable WinRM Service Basic authentication' }
        @{ Control = '18.10.89.2.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service'; Name = 'AllowUnencryptedTraffic'; Value = 0; Type = 'DWord'; Description = 'Disable WinRM Service unencrypted traffic' }
        @{ Control = '18.10.89.2.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service'; Name = 'DisableRunAs'; Value = 1; Type = 'DWord'; Description = 'Disallow WinRM storing RunAs credentials' }
        @{ Control = '18.10.91.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox'; Name = 'AllowClipboardRedirection'; Value = 0; Type = 'DWord'; Description = 'Disable clipboard sharing with Sandbox' }
        @{ Control = '18.10.91.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Sandbox'; Name = 'AllowNetworking'; Value = 0; Type = 'DWord'; Description = 'Disable networking in Sandbox' }
        @{ Control = '18.10.93.1.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'ManagePreviewBuildsPolicyValue'; Value = 0; Type = 'DWord'; Description = 'Disable preview builds' }
        @{ Control = '18.10.93.2.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'; Name = 'NoAutoUpdate'; Value = 0; Type = 'DWord'; Description = 'Enable Automatic Updates' }
        @{ Control = '18.10.93.2.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'SetDisablePauseUXAccess'; Value = 1; Type = 'DWord'; Description = 'Remove access to Pause updates feature' }

        # === ADDITIONAL MISSING CIS CONTROLS ===
        
        # 18.10.13.2 - Turn off cloud optimized content
        @{ Control = '18.10.13.2'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableCloudOptimizedContent'; Value = 1; Type = 'DWord'; Description = 'Turn off cloud optimized content' }
        
        # 18.10.15.2 - Disable diagnostic data opt-in settings
        @{ Control = '18.10.15.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DisableTelemetryOptInSettingsUx'; Value = 1; Type = 'DWord'; Description = 'Disable Diagnostic Data opt-in settings' }
        
        # 18.10.15.3 - Prevent the use of security questions for local accounts
        @{ Control = '18.10.15.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'NoLocalPasswordResetQuestions'; Value = 1; Type = 'DWord'; Description = 'Prevent the use of security questions for local accounts' }
        
        # 18.10.16.2 - Configure Authenticated Proxy usage
        @{ Control = '18.10.16.2'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DisableEnterpriseAuthProxy'; Value = 1; Type = 'DWord'; Description = 'Configure Authenticated Proxy usage for Connected User Experience' }
        
        # 18.10.17.1 - Download Mode (Delivery Optimization)
        @{ Control = '18.10.17.1'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'; Name = 'DODownloadMode'; Value = 1; Type = 'DWord'; Description = 'Download Mode set to LAN only' }
        
        # 18.10.18.1 - Enable App Installer (Disabled)
        @{ Control = '18.10.18.1'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableAppInstaller'; Value = 0; Type = 'DWord'; Description = 'Disable App Installer' }
        
        # 18.10.18.2 - Enable App Installer Experimental Features
        @{ Control = '18.10.18.2'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableExperimentalFeatures'; Value = 0; Type = 'DWord'; Description = 'Disable App Installer Experimental Features' }
        
        # 18.10.18.3 - Enable App Installer Hash Override
        @{ Control = '18.10.18.3'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableHashOverride'; Value = 0; Type = 'DWord'; Description = 'Disable App Installer Hash Override' }
        
        # 18.10.18.4 - Enable App Installer Local Archive Malware Scan Override
        @{ Control = '18.10.18.4'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableLocalArchiveMalwareScanOverride'; Value = 0; Type = 'DWord'; Description = 'Disable App Installer Local Archive Malware Scan Override' }
        
        # 18.10.18.5 - Enable App Installer MS Store Source Certificate Validation Bypass
        @{ Control = '18.10.18.5'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableMSAppInstallerProtocol'; Value = 0; Type = 'DWord'; Description = 'Disable MS Store Source Certificate Validation Bypass' }
        
        # 18.10.18.6 - Enable App Installer ms-appinstaller protocol
        @{ Control = '18.10.18.6'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableBypassCertificatePinningForMicrosoftStoreApp'; Value = 0; Type = 'DWord'; Description = 'Disable App Installer ms-appinstaller protocol' }
        
        # 18.10.18.7 - Enable Windows Package Manager command line interfaces
        @{ Control = '18.10.18.7'; Level = 'L2'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'; Name = 'EnableWindowsPackageManagerCommandLineInterfaces'; Value = 0; Type = 'DWord'; Description = 'Disable Windows Package Manager command line interfaces' }
        
        # 18.10.26.1.1 - Application: Control Event Log behavior (Retention)
        @{ Control = '18.10.26.1.1R'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'; Name = 'Retention'; Value = '0'; Type = 'String'; Description = 'Application log retention overwrite as needed' }
        
        # 18.10.26.2.1 - Security: Control Event Log behavior (Retention)
        @{ Control = '18.10.26.2.1R'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'; Name = 'Retention'; Value = '0'; Type = 'String'; Description = 'Security log retention overwrite as needed' }
        
        # 18.10.26.3.1 - Setup: Control Event Log behavior (Retention)
        @{ Control = '18.10.26.3.1R'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup'; Name = 'Retention'; Value = '0'; Type = 'String'; Description = 'Setup log retention overwrite as needed' }
        
        # 18.10.26.4.1 - System: Control Event Log behavior (Retention)
        @{ Control = '18.10.26.4.1R'; Level = 'L1'; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System'; Name = 'Retention'; Value = '0'; Type = 'String'; Description = 'System log retention overwrite as needed' }
    )
}

