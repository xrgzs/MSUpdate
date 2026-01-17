#Requires -Version 7
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\Modules\request.psm1"
Import-Module "$PSScriptRoot\Modules\aria2.psm1"
Import-Module "$PSScriptRoot\Modules\msstore.psm1"

# Define Helper Functions

# set system info
switch ($MakeVersion) {
    "w1126h1a64" {
        # make 11 26h1 arm64
        $os_ver = "11"
        $os_rsversion = "26H1"
        $os_build = "28000"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/28000/arm64/28000.1.251103-1709.BR_RELEASE_CLIENTCHINA_OEM_A64FRE_ZH-CN.ISO"
        $os_md5 = "E8E187CAC22085FED8420BE8B97DE54A"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-26h1" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-arm64-zh-CN.esd"
        $msstore = $true
    }
    "w1126h164" {
        # make 11 26h1 x64
        $os_ver = "11"
        $os_rsversion = "26H1"
        $os_build = "28000"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/28000/amd64/28000.1.251103-1709.BR_RELEASE_CLIENTCHINA_OEM_X64FRE_ZH-CN.ISO"
        $os_md5 = "521276FBA781C5B151E89596EE32FC3D"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-26h1" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd"
        $msstore = $true
    }
    "w1125h2a64" {
        # make 11 25h2 arm64
        $os_ver = "11"
        $os_rsversion = "25H2"
        $os_build = "26200"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_OEM/X23-81947_26100.1742.240906-0331.ge_release_svc_refresh_CLIENTCHINA_OEM_A64FRE_zh-cn.iso"
        # $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_RTM/Win11_24H2_China_GGK_Chinese_Simplified_Arm64.iso"
        $os_md5 = "8cc8080e1c4b08ccd0ad4435ac0f2e5c"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-25h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-arm64-zh-CN.esd"
        $msstore = $true
    }
    "w1125h264" {
        # make 11 25h2 x64
        $os_ver = "11"
        $os_rsversion = "25H2"
        $os_build = "26200"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_OEM/X23-81948_26100.1742.240906-0331.ge_release_svc_refresh_CLIENTCHINA_OEM_x64FRE_zh-cn.iso"
        # $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_RTM/Win11_24H2_China_GGK_Chinese_Simplified_x64.iso"
        $os_md5 = "e5c05b0215d3e4af2f2fd4ea16252f91"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-25h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd"
        $msstore = $true
    }
    "w11lt24a64" {
        # make 11 ltsc2024 arm64
        $os_ver = "11"
        $os_rsversion = "24H2"
        $os_build = "26100"
        $os_edition = "LTSC2024"
        $os_display = "Windows $os_ver LTSC 2024"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/26100/arm64/26100.1742.240906-0331.ge_release_svc_refresh_CLIENT_ENTERPRISES_OEM_A64FRE_zh-cn.iso"
        $os_md5 = "53ec7752fceea6f95329a06955c3ff59"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $MultiEdition = $false
    }
    "w11lt2464" {
        # make 11 ltsc2024 x64
        $os_ver = "11"
        $os_rsversion = "24H2"
        $os_build = "26100"
        $os_edition = "LTSC2024"
        $os_display = "Windows $os_ver LTSC 2024"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_LTSC2024/1742_RTM/zh-cn_windows_11_enterprise_ltsc_2024_x64_dvd_cff9cd2d.iso"
        $os_md5 = "1a13ade0178082432f90df951a88842f"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11,*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
    }
    "w1123h2a64" {
        # make 11 23h2 arm64
        $os_ver = "11"
        $os_rsversion = "23H2"
        $os_build = "22631"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/22621/22621.1.220506-1250.NI_RELEASE_CLIENTCHINA_OEM_A64FRE_ZH-CN.ISO"
        $os_md5 = "6ef5a0a8eb488a8064d8ca33f64ff835"
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-23h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab"
        $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab"
        $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-CN.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-arm64-zh-cn.esd"
        $msstore = $true
    }
    "w1123h264" {
        # make 11 23h2 x64
        $os_ver = "11"
        $os_rsversion = "23H2"
        $os_build = "22631"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/22631_23H2/2861_202312/Win11_23H2_China_GGK_Chinese_Simplified_x64v2.iso"
        $os_md5 = "99835f9f2efee5f30d0348f749484a88"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w11-23h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 11*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
            $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab"
            $iexplorer = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab"
            $iexplorerLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-CN.cab"
            $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_22621_x64.meta4"
            $Miracast = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~~.cab"
            $MiracastLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~zh-CN~.cab"
            $iexplorer = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~~.cab"
            $iexplorerLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~zh-CN~.cab"
            $entgpack = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/22621/amd64/Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        }
        $msstore = $true
    }
    "w1022h2a64" {
        # make 10 22h2 arm64
        $os_ver = "10"
        $os_rsversion = "22H2"
        $os_build = "19045"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/Windows/Win10/Res/19041/arm64/19041.1.191206-1406.VB_RELEASE_CLIENTCHINA_OEM_A64FRE_ZH-CN.ISO"
        $os_md5 = "d84ddb4150d7c699a5dabf91a1430786"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w10-22h2" `
                -LinkFilter @("*selectlang.php?id=*") `
                -ContentFilter @("*Windows 10,*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab"
        $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-cn.cab"
        $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
        $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-arm64-zh-cn.esd"
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_19041_arm64.meta4"
        $msstore = $true
    }
    "w1022h264" {
        # make 10 22h2 x64
        $os_ver = "10"
        $os_rsversion = "22H2"
        $os_build = "19045"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/Win10_22H2_China_GGK_Chinese_Simplified_x64.iso"
        $os_md5 = "67615f768a49392d5e080e25a0036975"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-22h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab"
            $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-cn.cab"
            $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"
            $Miracast = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~~.cab"
            $MiracastLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~zh-CN~.cab"
            $entgpack = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/amd64/Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
        $msstore = $true
    }
    "w1022h232" {
        # make 10 22h2 x86
        $os_ver = "10"
        $os_rsversion = "22H2"
        $os_build = "19045"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/Win10_22H2_China_GGK_Chinese_Simplified_x32.iso"
        $os_md5 = "e85fc523e95410fb49901afab1e02876"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-22h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            $MiracastLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-WirelessDisplay-FOD-Package-x86-zh-cn.cab"
            $entgpack = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = Get-UUPFileLink -Id $uupid -FileName "Microsoft-Windows-Client-LanguagePack-Package_zh-cn-x86-zh-cn.esd"
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x86.meta4"
            $Miracast = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~x86~~.cab"
            $MiracastLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~x86~zh-CN~.cab"
            $entgpack = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD"
            $entgLP = "https://alist.xrgzs.top/d/pxy/System/Windows/Win10/Res/19041/x86/Microsoft-Windows-Client-LanguagePack-Package_zh-cn-x86-zh-cn.esd"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x86.meta4"
        $msstore = $true
    }
    "w10lt2164" {
        # make 10 ltsc2021 x64
        $os_ver = "10"
        $os_rsversion = "21H2"
        $os_build = "19044"
        $os_edition = "LTSC2021"
        $os_display = "Windows $os_ver LTSC 2021"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19044_LTSC2021/zh-cn_windows_10_enterprise_ltsc_2021_x64_dvd_033b7312.iso"
        $os_md5 = "2579b3865c0591ead3a2b45af3cabeee"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-21h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
    }
    "w10lt2132" {
        # make 10 ltsc2021 x86
        $os_ver = "10"
        $os_rsversion = "21H2"
        $os_build = "19044"
        $os_edition = "LTSC2021"
        $os_display = "Windows $os_ver LTSC 2021"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/19044_LTSC2021/zh-cn_windows_10_enterprise_ltsc_2021_x86_dvd_30600d9c.iso"
        $os_md5 = "a4f6f8f67d9a59ad462ff51506c5cd3a"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-21h2" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10,*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x86.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x86.meta4"
    }
    "w10lt1964" {
        # make 10 ltsc2019 x64
        $os_ver = "10"
        $os_rsversion = "1809"
        $os_build = "17763"
        $os_edition = "LTSC2019"
        $os_display = "Windows $os_ver LTSC 2019"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/17763_LTSC2019/1_RTM/cn_windows_10_enterprise_ltsc_2019_x64_dvd_2efc9ac2.iso"
        $os_md5 = "2eb4d2bf684f3852458991c654907d12"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-1809" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_17763_x64.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_17763_x64.meta4"
    }
    "w10lt1932" {
        # make 10 ltsc2019 x32
        $os_ver = "10"
        $os_rsversion = "1809"
        $os_build = "17763"
        $os_edition = "LTSC2019"
        $os_display = "Windows $os_ver LTSC 2019"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/17763_LTSC2019/1_RTM/cn_windows_10_enterprise_ltsc_2019_x86_dvd_2908ee10.iso"
        $os_md5 = "c5d58f64093ed0693aa770e3f7b98e13"
        if ($true -eq $UpdateFromUUP) {
            $uupid = (Invoke-UUPWebRequestLink `
                    -Url "known.php?q=category:w10-1809" `
                    -LinkFilter @("*selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
        } else {
            $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_17763_x86.meta4"
        }
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_17763_x86.meta4"
    }
    "w10lt1664" {
        # make 10 ltsb2016 x64 (unsupport uup)
        $os_ver = "10"
        $os_rsversion = "1607"
        $os_build = "14393"
        $os_edition = "LTSB2016"
        $os_display = "Windows $os_ver LTSB 2016"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win10/14393_LTSB2016/cn_windows_10_enterprise_2016_ltsb_x64_dvd_9060409.iso"
        $os_md5 = "0343dc55184a406af9a8ab0d964cccc6"
        $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_14393_x64.meta4"
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_14393_x64.meta4"
        $MultiEdition = $false
    }
    "w10lt1632" {
        # make 10 ltsb2016 x86 (unsupport uup)
        $os_ver = "10"
        $os_rsversion = "1607"
        $os_build = "14393"
        $os_edition = "LTSB2016"
        $os_display = "Windows $os_ver LTSB 2016"
        $os_arch = "x86"
        $os_lang = "zh-cn"
        # $os_path = "/系统/MSDN/NT10.0_Win10/14393_LTSB2016/cn_windows_10_enterprise_2016_ltsb_x86_dvd_9057089.iso"
        # $os_md5 = "e628fac2494476612967fdd86ae1b547"
        $os_path = "/系统/Windows/Win10/LTSB2016/cn_windows_10_enterprise_2016_ltsb_x86_dvd_9057089_FixSSShim.iso"
        $os_md5 = "dd23b8a175d76564c257b189fa7a3916"
        $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_14393_x86.meta4"
        $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_14393_x86.meta4"
        $MultiEdition = $false
    }
    default {
        Write-Error "Not defined or Unsupported OS version!
        Example:
            `$MakeVersion   = [string] `"w1064`"
            `$UpdateFromUUP = [bool]   `$False
            `$MultiEdition  = [bool]   `$True
            .\msupdate.ps1
        "
    }
}

# ltsxfix
if ($os_edition -like "*LTS*") {
    $msstore = $true
    $os_release = $os_edition
} else {
    $os_release = $os_rsversion
    # os_edition fix
    if ($MultiEdition -eq $true) {
        $os_edition = "Multi"
    }
}

# remove temporaty files
Remove-Item -Path ".\temp\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\entg\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\patch\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\fod\" -Recurse -ErrorAction Ignore
Remove-Item -Path ".\W10UI.cmd" -Recurse -ErrorAction Ignore
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction Ignore
New-Item -Path ".\bin\" -ItemType "directory" -ErrorAction Ignore

# Installing dependencies
function Test-Hashes {
    param (
        [hashtable]$Hashes,
        [string]$Algorithm
    )
    return $Hashes.GetEnumerator() | ForEach-Object {
        $file = $_.Key
        $expectedHash = $_.Value
        Write-Host -ForegroundColor Blue "Verifying $file $Algorithm hash ..."
        Write-Host -ForegroundColor Gray "Expected: $expectedHash"
        $actualHash = (Get-FileHash -Path $file -Algorithm $Algorithm).Hash
        Write-Host -ForegroundColor Gray "Actual  : $actualHash"
        if ($actualHash -ne $expectedHash) {
            # return $false
            Write-Error "$file hash not match."
        } else {
            Write-Host -ForegroundColor Green "$file hash match."
        }
    }
}
function Test-SHA256 ([hashtable]$Hashes) { return Test-Hashes -Hashes $Hashes -Algorithm "SHA256" }
function Test-MD5 ([hashtable]$Hashes) { return Test-Hashes -Hashes $Hashes -Algorithm "MD5" }

if (-not (Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    Write-Error "7-zip not found, please install it manually!"
}
if (-not (Test-Path -Path ".\bin\aria2c.exe")) {
    Write-Host "aria2c not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip' -OutFile ".\temp\aria2.zip"
    Expand-Archive -Path ".\temp\aria2.zip" -DestinationPath ".\temp" -Force
    Move-Item -Path ".\temp\aria2-1.37.0-win-64bit-build1\aria2c.exe" -Destination ".\bin\aria2c.exe" -Force
}
Test-SHA256 @{ 
    ".\bin\aria2c.exe" = "BE2099C214F63A3CB4954B09A0BECD6E2E34660B886D4C898D260FEBFE9D70C2" 
}
if (-not (Test-Path -Path ".\bin\wimlib-imagex.exe")) {
    Write-Host "wimlib-imagex not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/user-attachments/files/24684304/wimlib-1.14.4-windows-x86_64-bin.zip' -OutFile ".\temp\wimlib.zip"
    Expand-Archive -Path ".\temp\wimlib.zip" -DestinationPath ".\temp\wimlib" -Force
    Copy-Item -Path ".\temp\wimlib\wimlib-imagex.exe" -Destination ".\bin\wimlib-imagex.exe"
    Copy-Item -Path ".\temp\wimlib\libwim-15.dll" -Destination ".\bin\libwim-15.dll"
}
Test-SHA256 @{ 
    ".\bin\wimlib-imagex.exe" = "401BF99D6DEC2B749B464183F71D146327AE0856A968C309955F71A0C398A348"
    ".\bin\libwim-15.dll"     = "6480B53D4ECD4423AF9E100FE15E3D2C3D114EFF33FBA07977E46C1AB124342E"
}
if (-not (Test-Path -Path ".\bin\PSFExtractor.exe")) {
    Write-Host "PSFExtractor not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/Secant1006/PSFExtractor/releases/download/v3.07/PSFExtractor-v3.07-x64.zip' -OutFile ".\temp\PSFExtractor.zip"
    Expand-Archive -Path ".\temp\PSFExtractor.zip" -DestinationPath ".\bin" -Force
}
Test-SHA256 @{ 
    ".\bin\PSFExtractor.exe" = "B8A08DD9592E64843056CF5FE518E782FD7ED517D1EE32B70A99B7D7E5767F6C"
}
if (-not (Test-Path -Path ".\bin\MinSudo.exe")) {
    Write-Host "NanaRun\MinSudo not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/user-attachments/files/24684243/x64.zip' -OutFile ".\temp\NanaRun.zip"
    Expand-Archive -Path ".\temp\NanaRun.zip" -DestinationPath ".\temp\NanaRun" -Force
    Copy-Item -Path '.\temp\NanaRun\MinSudo.exe' -Destination ".\bin\MinSudo.exe"
}
Test-SHA256 @{ 
    ".\bin\MinSudo.exe" = "8CC452FA6CF761382AA032BCE5596B727FBD33FA730FF08F0381FD629F885C97"
}

# get wupatch
if ($UpdateFromUUP) {
    $UUPScript = "https://uupdump.net/get.php?id=$uupid&pack=0&edition=updateOnly&aria2=2"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -d ".\temp" -o "UUPScript.txt" "$UUPScript"
    if (!$?) { Write-Error "UUPScript File Download Failed!" }
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -i ".\temp\UUPScript.txt"
    if (!$?) { Write-Error "UUPScript Download Failed!" }
} elseif ($null -ne $WUScript) {
    Invoke-WebRequest -Uri $WUScript -OutFile ".\temp\WUScript.meta4"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -M ".\temp\WUScript.meta4"
    if (!$?) { Write-Error "WUScript Download Failed!" }
} else {
    Write-Error "No Windows Update Scripts Found!"
}
if ($null -ne $NETScript) {
    Invoke-WebRequest -Uri $NETScript -OutFile ".\temp\NETScript.meta4"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -M ".\temp\NETScript.meta4" --metalink-language="neutral"
    if (!$?) { Write-Error "NETScript Download Failed!" }
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -x16 -s16 -j5 -d ".\patch" -M ".\temp\NETScript.meta4" --metalink-language="zh-CN"
    if (!$?) { Write-Error "NETScript Download Failed!" }
}
# Convert WIM+PSF to msu
# Link: https://github.com/abbodi1406/BatUtil/issues/49
# if (Test-Path ".\patch\Windows*.wim") {
#     $patchPath = Resolve-Path ".\patch"
#     Write-Host "Making MSU ($patchPath)..."
#     Invoke-WebRequest -Uri 'https://github.com/abbodi1406/WHD/raw/refs/heads/master/scripts/PSFX_MSU_5.zip' -OutFile .\temp\PSFX_MSU.zip
#     Expand-Archive -Path .\temp\PSFX_MSU.zip -DestinationPath .\temp\PSFX_MSU -Force
#     . ".\temp\PSFX_MSU\PSFX2MSU.cmd" "$patchPath"
# }

# get fod
if ($null -ne $Miracast) {
    # Microsoft-Windows-WirelessDisplay-FOD-Package.cab
    Invoke-Aria2Download -Uri $Miracast -Destination ".\fod\Miracast\" -Name "update.cab"
    expand -f:* ".\fod\Miracast\update.cab" ".\fod\Miracast\" >nul
    # Microsoft-Windows-WirelessDisplay-FOD-Package~zh-CN.cab
    Invoke-Aria2Download -Uri $MiracastLP -Destination ".\fod\MiracastLP\" -Name "update.cab"
    expand -f:* ".\fod\MiracastLP\update.cab" ".\fod\MiracastLP\" >nul
}
if ($null -ne $iexplorer) {
    # microsoft-windows-internetexplorer-optional-package.cab
    Invoke-Aria2Download -Uri $iexplorer -Destination ".\fod\iexplorer\" -Name "update.cab"
    expand -f:* ".\fod\iexplorer\update.cab" ".\fod\iexplorer\" >nul
}
if ($null -ne $iexplorerLP) {
    # Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-cn.cab
    Invoke-Aria2Download -Uri $iexplorerLP -Destination ".\fod\iexplorerLP\" -Name "update.cab"
    expand -f:* ".\fod\iexplorerLP\update.cab" ".\fod\iexplorerLP\" >nul
}
# get entg
if (($null -ne $entgpack) -and ($true -eq $MultiEdition)) {
    # Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
    Invoke-Aria2Download -Uri $entgpack -Destination ".\temp\" -Name "entg.esd"
    ."C:\Program Files\7-Zip\7z.exe" x ".\temp\entg.esd" -o".\entg" -r
}
if (($null -ne $entgLP) -and ($true -eq $MultiEdition)) {
    # Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
    Invoke-Aria2Download -Uri $entgLP -Destination ".\temp\" -Name "entgLP.esd"
    ."C:\Program Files\7-Zip\7z.exe" x ".\temp\entgLP.esd" -o".\entgLP" -r
}

# get msstore
$MSStoreScript = "echo nostore"
if ($true -eq $msstore) {
    Remove-Item -Path "$PSScriptRoot\msstore" -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path "$PSScriptRoot\msstore" -ErrorAction SilentlyContinue
    if ($os_edition -like "*LTS*") {
        # Get-Appx 'Microsoft.VCLibs.140.00'
        Invoke-Aria2Download -Uri "https://aka.ms/Microsoft.VCLibs.$os_arch.14.00.Desktop.appx" -Destination "$PSScriptRoot\msstore\Microsoft.VCLibs.140.00.msix"
    } else {
        Get-Appx '9NBLGGH4NNS1' # 'Microsoft.DesktopAppInstaller'
        Get-Appx '9WZDNCRFJBMP' # 'Microsoft.WindowsStore'
        Get-Appx '9N0DX20HK701' # 'Microsoft.WindowsTerminal'
    }
    $MSStoreScript = @"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00.UWPDesktop*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00*.msix) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.UI.Xaml*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.NET.Native.Runtime*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.NET.Native.Framework*.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.WindowsStore*.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.DesktopAppInstaller*.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.WindowsTerminal*.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
"@
}

if ($true -eq $SkipCheck) { 
    # get appraiserres.dll from Windows 10 19041 latest setup
    Invoke-WebRequest -Uri "https://github.com/user-attachments/files/17200856/appraiserres.zip" -OutFile ".\temp\appraiserres.zip"
    Expand-Archive -Path ".\temp\appraiserres.zip" -DestinationPath ".\temp"
}
if ($null -eq $Cleanup) { $Cleanup = $true }

# abbodi1406/W10UI, auto inject hook
$W10UI = "@chcp 65001`n"
$W10UI += (Invoke-WebRequest -Uri "https://gitlab.com/saiwp/BatUtil/-/raw/master/W10UI/W10UI.cmd").Content
$W10UI = $W10UI.Replace("if %AddDrivers%==1 call :doDrv", "call %~dp0hook_beforewim.cmd`nif %AddDrivers%==1 call :doDrv")
$W10UI = $W10UI.Replace("cd /d `"!net35source!`"", "call %~dp0hook_beforenet35.cmd`ncd /d `"!net35source!`"")
if ($Cleanup) {
    $W10UI = $W10UI.Replace("set Cleanup=0", "set Cleanup=1")
}

# write beforenet35 hook script
@"
echo.
echo ============================================================
echo Hook W10UI beforenet35 Successfully!
echo Current Dir: %cd%
echo Mount Dir: !mountdir!
echo ============================================================

if exist "!mountdir!\Windows\WinSxS\*microsoft-edge-webview*" (
    echo.
    echo ============================================================
    echo Removing Edge WebView2 FOD...
    echo ============================================================
    %_dism2%:"!_cabdir!" %dismtarget% /Remove-Capability /CapabilityName:"Edge.WebView2.Platform~~~~"   
)
"@ | Out-File -FilePath ".\hook_beforenet35.cmd"

# write beforewim hook script
@"
echo.
echo ============================================================
echo Hook W10UI beforewim Successfully!
echo Current Dir: %cd%
echo Mount Dir: !mountdir!
echo ============================================================

if /i "$SkipCheck"=="true" (
    echo skip hardware check by reg
    REG.exe LOAD "HKLM\Mount_SYSTEM" "!mountdir!\Windows\System32\config\SYSTEM"
    for %%a in (BypassCPUCheck,BypassRAMCheck,BypassSecureBootCheck,BypassStorageCheck,BypassTPMCheck) do (
        REG.exe ADD "HKLM\Mount_SYSTEM\Setup\LabConfig" /f /v "%%a" /t REG_DWORD /d 1
    )
    REG.exe ADD "HKLM\Mount_SYSTEM\Setup\MoSetup" /f /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1
    REG.exe UNLOAD "HKLM\Mount_SYSTEM"

    echo skip oobe force-login check
    REG.exe LOAD "HKLM\Mount_SOFTWARE" "!mountdir!\Windows\System32\config\SOFTWARE"
    REG.exe ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f
    REG.exe DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f
    REG.exe DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f
    REG.exe DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f
    REG.exe ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v "HwReqChkVars" /t REG_MULTI_SZ /d "SQ_SSE2ProcessorSupport=TRUE\0SQ_SSE4_2ProcessorSupport=TRUE\0SQ_NXProcessorSupport=TRUE\0SQ_CompareExchange128=TRUE\0SQ_LahfSahfSupport=TRUE\0SQ_PrefetchWSupport=TRUE\0SQ_PopCntInstructionSupport=TRUE\0SQ_SecureBootCapable=TRUE\0SQ_SecureBootEnabled=TRUE\0SQ_TpmVersion=2\0SQ_RamMB=9999\0SQ_SystemDiskSizeMB=99999\0SQ_CpuCoreCount=9\0SQ_CpuModel=99\0SQ_CpuFamily=99\0SQ_CpuMhz=9999" /f
    REG.exe UNLOAD "HKLM\Mount_SOFTWARE"
    
    echo skip personal data export check for cn
    REG LOAD "HKLM\Mount_Default" "!mountdir!\Users\Default\NTUSER.DAT"
    REG ADD "HKLM\Mount_Default\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\PersonalDataExport" /f /v "PDEShown" /t REG_DWORD /d 2
    REG UNLOAD "HKLM\Mount_Default"
)

if exist "!mountdir!\Windows\Servicing\Packages\*WinPE-LanguagePack*.mum" (
    echo.
    echo ============================================================
    echo Hook does not operate for WinPE, exiting...
    echo ============================================================
    exit /b
)

echo.
echo ============================================================
echo Enable Features...
echo ============================================================

%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:LegacyComponents /All
%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:SMB1Protocol
%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:TFTP
%_dism2%:"!_cabdir!" %dismtarget% /Enable-Feature:TelnetClient

echo.
echo ============================================================
echo Adding Features on Demands...
echo ============================================================

echo current dir: %cd%

if exist "%~dp0fod\Miracast\update.mum" (
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\Miracast\update.mum" 
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\MiracastLP\update.mum"
)
if exist "%~dp0fod\iexplorer\update.mum" (
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\iexplorer\update.mum" 
)
if exist "%~dp0fod\iexplorerLP\update.mum" (
    %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%~dp0fod\iexplorerLP\update.mum" 
)
echo.
echo ============================================================
echo Updating Microsoft Store...
echo ============================================================

$MSStoreScript

if /i not "$MultiEdition"=="true" EXIT /B

echo.
echo ============================================================
echo Commiting Base-Edition...
echo ============================================================
%_dism2%:"!_cabdir!" /Commit-Image /MountDir:"!mountdir!"


echo.
echo ============================================================
echo Getting Current-Edition...
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Get-CurrentEdition | find /i "CoreCountrySpecific" && goto :makefromccs
%_dism2%:"!_cabdir!" %dismtarget% /Get-CurrentEdition | find /i "EnterpriseS" && goto :makefroments
echo.
echo Your current edition is not supported, exiting...
set discard=1
EXIT /B


:makefromccs
echo.
echo ============================================================
echo Converting Multi-Edition from CoreCountrySpecific...
echo ============================================================
call :makemulti Core
call :makemulti CoreSingleLanguage
call :makemulti Professional
call :makemulti ProfessionalWorkstation
call :makemulti Education
call :makemulti Enterprise
call :makemulti IoTEnterprise
if exist "%~dp0entg\update.mum" call :makeEntG
if exist "%~dp0entg\update.mum" call :makemulti EnterpriseG
set discard=1
EXIT /B

:makefroments
echo.
echo ============================================================
echo Converting Multi-Edition from EnterpriseS...
echo ============================================================
FOR /F "tokens=3 delims=: " %%a in ('%_dism2%:"!_cabdir!" %dismtarget% /Get-TargetEditions ^| find /i "Target Edition : "') do (
    echo Convertable Edition: %%a
    call :makemulti %%a
)
set discard=1
EXIT /B

:Add-ProvisionedAppxPackage
echo installing - %~n1
%_dism2%:"!_cabdir!" %dismtarget% /Add-ProvisionedAppxPackage /PackagePath:"%~1" /SkipLicense /Region:all
goto :EOF

:makemulti
echo.
echo ============================================================
echo Coverting Edition - %1...
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Set-Edition:%1
if !errorlevel! equ 0 (
    echo.
    echo ============================================================
    echo Commiting Edition - %1...
    echo ============================================================
    %_dism2%:"!_cabdir!" /Commit-Image /MountDir:"!mountdir!" /Append
) else (
    echo.
    echo ============================================================
    echo Coverting Edition - %1 Failed!
    echo ============================================================
)
goto :EOF

:makeEntG
echo.
echo ============================================================
echo Making EnterpriseG Version...
echo ============================================================

echo.
echo ============================================================
echo Installing EnterpriseG Package...
echo.
echo Note: If errors occur, it is normal.
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Set-Edition:Enterprise
FOR %%a IN (%~dp0entg\*.mum) DO %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%%a"
rem add language pack
FOR %%a IN (%~dp0entgLP\*-EnterpriseG-*.mum) DO %_dism2%:"!_cabdir!" %dismtarget% /Add-Package /PackagePath:"%%a"

echo.
echo ============================================================
echo Copying servicing Packages...
echo.
echo Note: If errors occur, it must be 100% faild.
echo ============================================================
for /d %%a in ("!_cabdir!\*") do for %%b in ("%%a\Microsoft-Windows-EnterpriseGEdition~*") do copy /y "%%~b" "!mountdir!\Windows\servicing\Packages"
for /d %%a in ("!_cabdir!\*") do for %%b in ("%%a\Microsoft-Windows-EnterpriseGEdition-wrapper~*") do copy /y "%%~b" "!mountdir!\Windows\servicing\Packages"

echo.
echo ============================================================
echo Getting informartion from registry...
echo ============================================================
REG.exe LOAD HKLM\EntGSOFTWARE "!mountdir!\Windows\System32\config\SOFTWARE"

set _target_arch=%arch%
if "%arch%"=="x64" (
    set _target_arch=amd64
)
for /f "tokens=6,7 delims=~." %%a in ('dir /b "!mountdir!\Windows\servicing\Packages\Microsoft-Windows-EnterpriseGEdition~*"') do set EntGEditionVersion=%%a.%%b

FOR /F "tokens=*" %%i IN ('REG QUERY "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"^|find /i "Microsoft-Windows-Editions-EnterpriseG-Package~31bf3856ad364e35~"') DO (
    FOR /F "tokens=3* skip=2" %%j IN ('REG QUERY "%%i" /v InstallTimeHigh') DO SET "InstallTimeHigh=%%j"
    FOR /F "tokens=3* skip=2" %%k IN ('REG QUERY "%%i" /v InstallTimeLow') DO SET "InstallTimeLow=%%k"
    FOR /F "tokens=3* skip=2" %%l IN ('REG QUERY "%%i" /v InstallUser') DO SET "InstallUser=%%l"
    FOR /F "tokens=3* skip=2" %%m IN ('REG QUERY "%%i" /v InstallLocation') DO SET "InstallLocation=%%m"
)

echo.
echo ============================================================
echo Adding Edition Package informartion to the registry...
echo.
echo TargetArchitecture: %_target_arch%
echo EntGEditionVersion: %EntGEditionVersion%
echo InstallTimeHigh: %InstallTimeHigh%
echo InstallTimeLow: %InstallTimeLow%
echo InstallUser: %InstallUser%
echo InstallLocation: %InstallLocation%
echo ============================================================
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "CurrentState" /t REG_DWORD /d 112
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallClient" /t REG_SZ /d "DISM Package Manager Provider"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallLocation" /t REG_SZ /d "\\?%WorkDisk%\%LCUName%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallName" /t REG_SZ /d "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%.mum"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallTimeHigh" /t REG_DWORD /d "%InstallTimeHigh%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallTimeLow" /t REG_DWORD /d "%InstallTimeLow%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "InstallUser" /t REG_SZ /d "%InstallUser%"
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "SelfUpdate" /t REG_DWORD /d 0
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /f /v "Visibility" /t REG_DWORD /d 1
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%\Owners" /f
REG.exe ADD "HKLM\EntGSOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%\Owners" /f /v "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~%_target_arch%~~10.0.%EntGEditionVersion%" /t REG_DWORD /d 131184

REG.exe UNLOAD HKLM\EntGSOFTWARE

echo.
echo ============================================================
echo Setting key and license...
echo ============================================================
%_dism2%:"!_cabdir!" %dismtarget% /Set-ProductKey:FV469-WGNG4-YQP66-2B2HY-KD8YX
%_dism2%:"!_cabdir!" %dismtarget% /Get-CurrentEdition

goto :EOF
"@ | Out-File -FilePath ".\hook_beforewim.cmd"

if ($true -eq $MultiEdition) {
    $W10UI = $W10UI.Replace("`n:dvdproceed", "`n:dvdproceed`ncall %~dp0hook_beforedvd.cmd")
    @"
cd /d "%~dp0"
set "filename=ISO\sources\install.wim"
set "wimlib=bin\wimlib-imagex.exe"

for /F "tokens=3" %%a in ('%wimlib% info "%filename%" ^| findstr /C:"Image Count:"') do set "ImageCount=%%a"
for /L %%# in (1,1,%ImageCount%) do call :editwiminfo %%#

if /i "$SkipCheck"=="true" (
    echo change installation type to server
    for /L %%# in (1,1,%ImageCount%) do (
        %wimlib% info "%filename%" %%# --image-property WINDOWS/INSTALLATIONTYPE=Server
    )

    echo write ei.cfg
    >ISO\sources\ei.cfg echo [Channel]
    >>ISO\sources\ei.cfg echo _Default
    >>ISO\sources\ei.cfg echo [VL]
    >>ISO\sources\ei.cfg echo 0

    echo replace appraiserres.dll to windows 10 19041 setup
    copy /y "temp\appraiserres.dll" "ISO\sources\appraiserres.dll"

    echo write 4+1+1 batch file to ISO root path
    >ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f
    >>ISO\SkipCheck.cmd echo REG.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f
    >>ISO\SkipCheck.cmd echo REG.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f
    >>ISO\SkipCheck.cmd echo REG.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f
    >>ISO\SkipCheck.cmd echo REG.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v "HwReqChkVars" /t REG_MULTI_SZ /d "SQ_SSE2ProcessorSupport=TRUE\0SQ_SSE4_2ProcessorSupport=TRUE\0SQ_NXProcessorSupport=TRUE\0SQ_CompareExchange128=TRUE\0SQ_LahfSahfSupport=TRUE\0SQ_PrefetchWSupport=TRUE\0SQ_PopCntInstructionSupport=TRUE\0SQ_SecureBootCapable=TRUE\0SQ_SecureBootEnabled=TRUE\0SQ_TpmVersion=2\0SQ_RamMB=9999\0SQ_SystemDiskSizeMB=99999\0SQ_CpuCoreCount=9\0SQ_CpuModel=99\0SQ_CpuFamily=99\0SQ_CpuMhz=9999" /f
    >>ISO\SkipCheck.cmd echo PAUSE
)
exit /b

:readwiminfo
for /f "tokens=1,2 delims=:" %%a in ('%wimlib% info "%filename%" %1 ^| find /i %2') do (for /f "tokens=*" %%c in ("%%b") do (set "%%a=%%c"))
goto :eof

:editwiminfo
call :readwiminfo %1 "Edition ID"
call :readwiminfo %1 "Build"
if %Build% GEQ 22000 (
    set sysver=Windows 11
) else (
    set sysver=Windows 10
)
if /i "%Edition ID%"=="Core" set "CNEDITION=家庭版"
if /i "%Edition ID%"=="CoreSingleLanguage" set "CNEDITION=家庭单语言版"
if /i "%Edition ID%"=="CoreCountrySpecific" set "CNEDITION=家庭中文版"
if /i "%Edition ID%"=="Professional" set "CNEDITION=专业版"
if /i "%Edition ID%"=="ProfessionalCountrySpecific" set "CNEDITION=专业中文版"
if /i "%Edition ID%"=="ProfessionalEducation" set "CNEDITION=专业教育版"
if /i "%Edition ID%"=="ProfessionalSingleLanguage" set "CNEDITION=专业单语言版"
if /i "%Edition ID%"=="ProfessionalWorkstation" set "CNEDITION=专业工作站版"
if /i "%Edition ID%"=="Education" set "CNEDITION=教育版"
if /i "%Edition ID%"=="Enterprise" set "CNEDITION=企业版"
if /i "%Edition ID%"=="IoTEnterprise" set "CNEDITION=IoT 企业版"
if /i "%Edition ID%"=="IoTEnterpriseK" set "CNEDITION=IoT 企业版订阅"
if /i "%Edition ID%"=="ServerRdsh" set "CNEDITION=企业版多会话"
if /i "%Edition ID%"=="CloudEdition" set "CNEDITION=SE"
if /i "%Edition ID%"=="EnterpriseG" set "CNEDITION=企业版 G"
if /i "%Edition ID%"=="EnterpriseS" set "CNEDITION=企业版 LTSC"
if /i "%Edition ID%"=="IoTEnterpriseS" set "CNEDITION=IoT 企业版 LTSC"
if /i "%Edition ID%"=="IoTEnterpriseSK" set "CNEDITION=IoT 企业版订阅 LTSC"
if /i "%CNEDITION%"=="" set "CNEDITION=%Edition ID%"
%wimlib% info "%filename%" %1 "%sysver% %Edition ID%" "%sysver% %Edition ID%" --image-property "DISPLAYNAME"="%sysver% %CNEDITION%" --image-property "DISPLAYDESCRIPTION"="%sysver% %CNEDITION%" --image-property "FLAGS"="%Edition ID%"
goto :eof
"@ | Out-File -FilePath ".\hook_beforedvd.cmd"
}

# write W10UI
$W10UI | Out-File -FilePath ".\W10UI.cmd" -Encoding utf8
$W10UI = ""

# get osimage
# get original system direct link
if ($null -ne $os_path) {
    Write-Host "Get Original System Image Link for $os_path..."
    $obj = Invoke-RestMethod -Uri "https://alist.xrgzs.top/api/fs/get" `
        -Method "POST" `
        -ContentType "application/json;charset=UTF-8" `
        -Body (@{
            path     = $os_path
            password = ""
        } | Convertto-Json)
    if ($obj.data.name -and $obj.data.raw_url) {
        Write-Host "Get $($obj.data.name): $($obj.data.raw_url)"
        $os_file = $obj.data.name
        $os_url = $obj.data.raw_url
    } else {
        Write-Error "Get Original System Image Failed! $($obj | ConvertTo-Json)"
    }
}
Write-Host "Original system file: $os_file
Original system download link: $os_url
"

Write-Host "Downloading original system image..."
Invoke-Aria2Download -Uri $os_url -Destination ".\temp\" -Name $os_file -Big

Write-Host "Verifying hash of original system image..."

if ($os_md5) {
    Test-MD5 @{".\temp\$os_file" = $os_md5 }
}

# $isopath = Resolve-Path -Path ".\temp\$os_file"
# $isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter
# Target        =${isomount}:
."C:\Program Files\7-Zip\7z.exe" x ".\temp\$os_file" -o".\ISO" -r

# select 1 edition only
# if ($null -ne $SelectEdition) {
#     .\bin\wimlib-imagex.exe info ".\ISO\sources\install.wim" --extract-xml ".\temp\WIMInfo.xml"
#     $WIMInfo = [xml](Get-Content ".\temp\WIMInfo.xml")
#     $WIMIndex = $WIMInfo.WIM.IMAGE | Where-Object {$_.WINDOWS.EDITIONID -eq "$SelectEdition"} | Select-Object -ExpandProperty INDEX
#     $WIMIndexs = $WIMInfo.WIM.IMAGE.Index | Measure-Object | Select-Object -ExpandProperty Count
#     for ($i = $WIMIndexs; $i -gt $WIMIndex; $i--) {
#         # .\bin\wimlib-imagex.exe delete ".\ISO\sources\install.wim" $i --soft
#         Remove-WindowsImage -ImagePath ".\ISO\sources\install.wim" -Index $i
#     }
#     for ($i = 1; $i -lt $WIMIndex; $i++) {
#         Remove-WindowsImage -ImagePath ".\ISO\sources\install.wim" -Index 1
#     }
# }

.\bin\wimlib-imagex.exe info ".\ISO\sources\install.wim" --extract-xml ".\temp\WIMInfo2.xml"
Get-Content ".\temp\WIMInfo2.xml"
# write W10UI conf
@"
[W10UI-Configuration]
Target        =%cd%\ISO
Repo          =%cd%\patch
DismRoot      =dism.exe

Net35         =1
Net35Source   =%cd%\ISO\sources\sxs
Cleanup       =$($Cleanup ? 1 : 0)
ResetBase     =0
LCUwinre      =1
WinRE         =1
UpdtBootFiles =1
SkipEdge      =0
UseWimlib     =1

_CabDir       =W10UItemp
MountDir      =W10UImount
WinreMount    =W10UImountre

wim2esd       =1
wim2swm       =0
ISO           =1
ISODir        =
Delete_Source =0


AutoStart     =1

AddDrivers    =0
Drv_Source    =\Drivers
"@ | Out-File -FilePath ".\W10UI.ini"

# execute W10UI script
.\bin\MinSudo.exe --TrustedInstaller --Privileged --WorkDir=. whoami /all
.\bin\MinSudo.exe --TrustedInstaller --Privileged --WorkDir=. .\W10UI.cmd

# ensure iso exists
$isoFiles = Get-ChildItem -Path ".\*.iso" -File
if (-not $isoFiles) {
    Write-Error "No ISO files found in the directory. Please ensure the script has generated the ISO files correctly."
    exit 1
}

# rename
$isoFiles | ForEach-Object {
    $NewName = $_.Name
    if ($os_edition -like "*LTS*") {
        $NewName = $NewName -replace "_CLIENT_", "_CLIENT_ENTERPRISES_"
    }
    if ($true -eq $MultiEdition) {
        $NewName = $NewName -replace "_CLIENT", "_CLIENTMULTI"
    }
    if ($true -eq $UpdateFromUUP) {
        $NameAppend += "_FromUUP"
    }
    if ($true -eq $AddVMD) {
        $NameAppend += "_VMD"
    }
    if ($true -eq $AddUnattend) {
        $NameAppend += "_Unattend"
    }
    if ($true -eq $SkipCheck) {
        $NameAppend += "_SkipCheck"
    }
    if ($null -ne $NameAppend) {
        $NewName = $NewName -replace ".iso", "$NameAppend.iso"
    }
    if ($_.Name -ne $NewName) {
        Rename-Item -Path $_.Name -NewName $NewName
    }
}

# get hash
Get-ChildItem -Path ".\*.iso" -File | ForEach-Object {
    Write-Host "Getting hash for $($_.Name)..."
    $FileInfo = [ordered] @{}
    $FileInfo.uuid = [guid]::NewGuid().ToString()
    $FileInfo.name = $_.Name
    $FileInfo.size = $_.Length
    $FileInfo.date = $_.LastWriteTime
    $FileInfo.hash = @{}
    $FileInfo.hash.sha256 = Get-FileHash -Path $_.Name -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    $FileInfo.hash.md5 = Get-FileHash -Path $_.Name -Algorithm MD5 | Select-Object -ExpandProperty Hash
    $FileInfo.os_ver = [string] $os_ver
    $FileInfo.os_display = $os_display
    $FileInfo.os_version = [string] $_.Name.Split(".")[0] + "." + $_.Name.Split(".")[1]
    $FileInfo.os_rsversion = $os_rsversion
    $FileInfo.os_release = $os_release
    $FileInfo.os_build = [string] $os_build
    $FileInfo.os_build_number = [string] $_.Name.Split(".")[0]
    $FileInfo.os_build_qfe = [string] $_.Name.Split(".")[1]
    $FileInfo.os_build_stamp = [string] $_.Name.Split(".")[2]
    $FileInfo.os_build_branch = [string] $_.Name.split(".")[3].split("_")[0] + "_" + $_.Name.split(".")[3].split("_")[1]
    $FileInfo.os_edition = $os_edition
    $FileInfo.os_arch = $os_arch
    $FileInfo.os_lang = $os_lang
    $FileInfo.os_type = "MSUpdate"
    $FileInfo.msupdate = @{}
    $FileInfo.msupdate.makeversion = $MakeVersion
    $FileInfo.msupdate.multiedition = $MultiEdition
    $FileInfo.msupdate.updatefromuup = $UpdateFromUUP
    $FileInfo.msupdate.addunattend = $AddUnattend
    $FileInfo.msupdate.skipcheck = $SkipCheck
    $FileInfo.msupdate.cleanup = $Cleanup
    $FileInfo.msupdate.makefrom = $os_file
    $FileInfo | ConvertTo-Json | Out-File -FilePath ".\$($_.Name).json" -Encoding utf8
}