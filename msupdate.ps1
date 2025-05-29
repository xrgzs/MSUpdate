$ErrorActionPreference = 'Stop'

# Define Helper Functions
function Get-Appx($Name) {
    $Body = @{
        type = 'PackageFamilyName'
        url  = $Name + '_8wekyb3d8bbwe'
        ring = 'RP'
        lang = 'zh-CN'
    }
    $msstoreApis = @(
        "https://api.xrgzs.top/msstore/GetFiles",
        "https://store.rg-adguard.net/api/GetFiles"
    )
    
    while ($true) {
        try {
            foreach ($url in $msstoreApis) {
                try {
                    $obj = Invoke-WebRequest -Uri $url `
                        -Method "POST" `
                        -ContentType "application/x-www-form-urlencoded" `
                        -Body $Body `
                        -ConnectionTimeoutSeconds 5 -OperationTimeoutSeconds 5
                    break
                } catch {
                    if ($url -eq $msstoreApis[-1]) {
                        throw "All requests failed. $_"
                    }
                    Write-Warning "Request failed with $url, trying next url... ($_)"
                    continue
                }
            }
            foreach ($link in $obj.Links) {
                if ($link.outerHTML -match '(?<=<a\b[^>]*>).*?(?=</a>)') {
                    $linkText = $Matches[0]
                    if ($linkText -match '(arm64|x64|x86|neutral).*\.(appx|appxbundle|msixbundle)\b') {
                        Write-Debug "$linkText : $($link.href)"
                        if (Test-Path -Path $linkText) {
                            Write-Warning "Already exists, skiping $linkText"
                        } else {
                            Write-Host "== $linkText ($($link.href))"
                            Invoke-WebRequest -Uri $link.href -OutFile "$PSScriptRoot\msstore\$linkText"
                        }
                    }
                }
            }
            break
        } catch {
            Write-Warning "Request failed, retrying in 3 seconds... ($_)"
            Start-Sleep -Seconds 3
        }
    }
}

function Invoke-UUPWebRequest {
    param (
        [string]$Url
    )
    $RetryCount = 0
    $Entrypoint = "https://uupdump.net"
    while ($RetryCount -lt 10) {
        Write-Host "Attempting request to $Url (Attempt $($RetryCount + 1))..."
        $Response = Invoke-WebRequest -Uri "$Entrypoint/$Url" `
            -SkipHttpErrorCheck `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0"
        if ($Response.Content -notmatch 'Just a moment' -and $Response.StatusCode -eq 200) {
            Write-Host "Request successful!"
            return $Response
        }
        Write-Host "Request failed. Retrying in 1 seconds..."
        Start-Sleep -Seconds 1
        if ($RetryCount -ge 2) {
            $Entrypoint = "https://uup.xrgzs.top"
        }
        if ($RetryCount -ge 5) {
            $Entrypoint = "https://uupdump.cn"
        }
        $RetryCount++
    }
    throw "Failed to retrieve content from $Url after 10 attempts."
}

function Invoke-UUPWebRequestLink {
    param(
        [string]$Url,
        $LinkFilter,
        $ContentFilter,
        [switch]$FirstLink
    )
    $Response = Invoke-UUPWebRequest -Url $Url
    $Links = $Response.Links
    if ($LinkFilter) {
        if ($LinkFilter -is [string]) {
            $Links = $Links | Where-Object { $_.outerHTML -like $LinkFilter }
        } elseif ($LinkFilter -is [array]) {
            foreach ($f in $LinkFilter) {
                $Links = $Links | Where-Object { $_.href -like $f }
            }
        }
    }
    if ($ContentFilter) {
        if ($ContentFilter -is [string]) {
            $Links = $Links | Where-Object { $_.outerHTML -like $ContentFilter }
        } elseif ($ContentFilter -is [array]) {
            foreach ($f in $ContentFilter) {
                $Links = $Links | Where-Object { $_.outerHTML -like $f }
            }
        }
    }
    if ($FirstLink) {
        if ($null -ne $Links -and $Links.Count -gt 0) {
            return $Links[0].href
        } else {
            Write-Error "No links found!"
            return $null
        }
    } else {
        return $Links
    }
}

function Invoke-Aria2Download {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [uri]$Uri,

        [Parameter(Position = 1)]
        [string]$Destination,

        [Parameter(Position = 2)]
        [string]$Name,
        
        [switch]$Big,

        [string[]]$Options = @()
    )
    
    function Get-RedirectedUrl {
        param(
            [Parameter(Mandatory, ValueFromPipeline)][string]$Uri,
            [string]$UserAgent = "aria2/1.37.0"
        )
        try {
            while ($true) {
                $req = [System.Net.WebRequest]::Create($Uri)
                $req.UserAgent = $UserAgent
                $req.AllowAutoRedirect = $false
                $res = $req.GetResponse()
                $loc = $res.GetResponseHeader('Location')
                $res.Close()
                if ($loc) { $Uri = $loc } else { return $Uri }
            }
        } catch { return $Uri }
    }
    
    function Get-Aria2Error($exitcode) {
        $codes = @{
            0  = 'All downloads were successful'
            1  = 'An unknown error occurred'
            2  = 'Timeout'
            3  = 'Resource was not found'
            4  = 'Aria2 saw the specified number of "resource not found" error. See --max-file-not-found option'
            5  = 'Download aborted because download speed was too slow. See --lowest-speed-limit option'
            6  = 'Network problem occurred.'
            7  = 'There were unfinished downloads. This error is only reported if all finished downloads were successful and there were unfinished downloads in a queue when aria2 exited by pressing Ctrl-C by an user or sending TERM or INT signal'
            8  = 'Remote server did not support resume when resume was required to complete download'
            9  = 'There was not enough disk space available'
            10 = 'Piece length was different from one in .aria2 control file. See --allow-piece-length-change option'
            11 = 'Aria2 was downloading same file at that moment'
            12 = 'Aria2 was downloading same info hash torrent at that moment'
            13 = 'File already existed. See --allow-overwrite option'
            14 = 'Renaming file failed. See --auto-file-renaming option'
            15 = 'Aria2 could not open existing file'
            16 = 'Aria2 could not create new file or truncate existing file'
            17 = 'File I/O error occurred'
            18 = 'Aria2 could not create directory'
            19 = 'Name resolution failed'
            20 = 'Aria2 could not parse Metalink document'
            21 = 'FTP command failed'
            22 = 'HTTP response header was bad or unexpected'
            23 = 'Too many redirects occurred'
            24 = 'HTTP authorization failed'
            25 = 'Aria2 could not parse bencoded file (usually ".torrent" file)'
            26 = '".torrent" file was corrupted or missing information that aria2 needed'
            27 = 'Magnet URI was bad'
            28 = 'Bad/unrecognized option was given or unexpected option argument was given'
            29 = 'The remote server was unable to handle the request due to a temporary overloading or maintenance'
            30 = 'Aria2 could not parse JSON-RPC request'
            31 = 'Reserved. Not used'
            32 = 'Checksum validation failed'
        }
        if ($null -eq $codes[$exitcode]) {
            return 'An unknown error occurred'
        }
        return $codes[$exitcode]
    }

    # aria2 options
    $Options += @(
        '--no-conf=true'
        '--continue'
        '--allow-overwrite=true'
        '--summary-interval=0'
        '--remote-time=true'
        '--retry-wait=5'
        '--check-certificate=false'
    )

    # set task info
    $Uri = Get-RedirectedUrl -Uri $Uri
    $Options += "`"$Uri`""
    if ($Destination) {
        $Options += "--dir=`"$Destination`""
    }
    if ($Name) {
        $Options += "--out=`"$Name`""
    }
    if ($Big) {
        $Options += @(
            '-s16'
            '-x16'
        )
    }

    # build aria2 command
    $aria2 = "& .\bin\aria2c.exe $($Options -join ' ')"

    # handle aria2 console output
    Write-Host 'Starting download with aria2 ...' -ForegroundColor Green
    Write-Host "  Command: $aria2" -ForegroundColor Cyan
    Invoke-Command ([scriptblock]::Create($aria2))

    # handle aria2 error
    Write-Host ''
    if ($LASTEXITCODE -gt 0) {
        Write-Error "Download failed! (Error $LASTEXITCODE) $(Get-Aria2Error $lastexitcode)"
    }
}

# set system info
switch ($MakeVersion) {
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
                -Url "known.php?q=category:w11-25h2-dev" `
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MiracastLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgpack = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package-arm64-zh-CN.esd" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
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
                -Url "known.php?q=category:w11-25h2-dev" `
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MiracastLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgpack = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $msstore = $true
    }
    "w1124h2a64" {
        # make 11 24h2 arm64
        $os_ver = "11"
        $os_rsversion = "24H2"
        $os_build = "26100"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "arm64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_OEM/X23-81947_26100.1742.240906-0331.ge_release_svc_refresh_CLIENTCHINA_OEM_A64FRE_zh-cn.iso"
        # $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_RTM/Win11_24H2_China_GGK_Chinese_Simplified_Arm64.iso"
        $os_md5 = "8cc8080e1c4b08ccd0ad4435ac0f2e5c"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MiracastLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgpack = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package-arm64-zh-CN.esd" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $msstore = $true
    }
    "w1124h264" {
        # make 11 24h2 x64
        $os_ver = "11"
        $os_rsversion = "24H2"
        $os_build = "26100"
        $os_edition = "CoreCountrySpecific"
        $os_display = "Windows $os_ver $os_rsversion"
        $os_arch = "x64"
        $os_lang = "zh-cn"
        $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_OEM/X23-81948_26100.1742.240906-0331.ge_release_svc_refresh_CLIENTCHINA_OEM_x64FRE_zh-cn.iso"
        # $os_path = "/系统/MSDN/NT10.0_Win11/26100_24H2/1742_RTM/Win11_24H2_China_GGK_Chinese_Simplified_x64.iso"
        $os_md5 = "e5c05b0215d3e4af2f2fd4ea16252f91"
        $UpdateFromUUP = $true
        $uupid = (Invoke-UUPWebRequestLink `
                -Url "known.php?q=category:w11-24h2" `
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MiracastLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgpack = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package-amd64-zh-CN.esd" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
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
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
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
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*amd64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-CN.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MultiEdition = $false
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
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 11*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MiracastLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-cn.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorer = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $iexplorerLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-arm64-zh-cn.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgpack = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package_zh-cn-arm64-zh-cn.esd" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
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
                    -LinkFilter @("selectlang.php?id=*") `
                    -ContentFilter @("*Windows 11*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $MiracastLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-cn.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $iexplorer = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-amd64.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $iexplorerLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-InternetExplorer-Optional-Package-amd64-zh-cn.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $entgpack = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $entgLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
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
                -LinkFilter @("selectlang.php?id=*") `
                -ContentFilter @("*Windows 10*arm64*") `
                -FirstLink
        ).Replace("selectlang.php?id=", "")
        $Miracast = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $MiracastLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-arm64-zh-cn.cab" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
    
        $entgpack = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
        $entgLP = Invoke-UUPWebRequestLink `
            -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package_zh-cn-arm64-zh-cn.esd" `
            -ContentFilter @("*mp.microsoft.com*") `
            -FirstLink
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
                    -LinkFilter @("selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*amd64*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $MiracastLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-amd64-zh-cn.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $entgpack = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $entgLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package_zh-cn-amd64-zh-cn.esd" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
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
                    -LinkFilter @("selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*x86*") `
                    -FirstLink
            ).Replace("selectlang.php?id=", "")
            $Miracast = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $MiracastLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-WirelessDisplay-FOD-Package-x86-zh-cn.cab" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $entgpack = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
            $entgLP = Invoke-UUPWebRequestLink `
                -Url "getfile.php?id=$uupid&file=Microsoft-Windows-Client-LanguagePack-Package_zh-cn-x86-zh-cn.esd" `
                -ContentFilter @("*mp.microsoft.com*") `
                -FirstLink
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
                    -LinkFilter @("selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*amd64*") `
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
                    -LinkFilter @("selectlang.php?id=*") `
                    -ContentFilter @("*Windows 10*x86*") `
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
                    -LinkFilter @("selectlang.php?id=*") `
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
                    -LinkFilter @("selectlang.php?id=*") `
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

if (-not (Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    Write-Error "7-zip not found, please install it manually!"
}
if (-not (Test-Path -Path ".\bin\aria2c.exe")) {
    Write-Host "aria2c not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip' -outfile .\temp\aria2.zip
    Expand-Archive -Path .\temp\aria2.zip -DestinationPath .\temp -Force
    Move-Item -Path .\temp\aria2-1.37.0-win-64bit-build1\aria2c.exe -Destination .\bin\aria2c.exe -Force
}
if (-not (Test-Path -Path ".\bin\wimlib-imagex.exe")) {
    Write-Host "wimlib-imagex not found, downloading..."
    Invoke-WebRequest -Uri 'https://wimlib.net/downloads/wimlib-1.14.4-windows-x86_64-bin.zip' -outfile .\temp\wimlib.zip
    Expand-Archive -Path .\temp\wimlib.zip -DestinationPath .\temp\wimlib -Force
    Copy-Item -Path .\temp\wimlib\wimlib-imagex.exe -Destination .\bin\wimlib-imagex.exe
    Copy-Item -Path .\temp\wimlib\libwim-15.dll -Destination .\bin\libwim-15.dll
}
if (-not (Test-Path -Path ".\bin\PSFExtractor.exe")) {
    Write-Host "PSFExtractor not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/Secant1006/PSFExtractor/releases/download/v3.07/PSFExtractor-v3.07-x64.zip' -outfile .\temp\PSFExtractor.zip
    Expand-Archive -Path .\temp\PSFExtractor.zip -DestinationPath .\bin -Force
}
if (-not (Test-Path -Path ".\bin\NSudoLC.exe")) {
    Write-Host "NSudo not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/M2TeamArchived/NSudo/releases/download/8.2/NSudo_8.2_All_Components.zip' -outfile .\temp\NSudo.zip
    Expand-Archive -Path .\temp\NSudo.zip -DestinationPath .\temp\NSudo -Force
    Copy-Item -Path '.\temp\NSudo\NSudo Launcher\x64\NSudoLC.exe' -Destination .\bin\NSudoLC.exe
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
#     Invoke-WebRequest -Uri 'https://github.com/abbodi1406/WHD/raw/refs/heads/master/scripts/PSFX_MSU_5.zip' -outfile .\temp\PSFX_MSU.zip
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
        Get-Appx 'Microsoft.VCLibs.140.00'
    } else {
        Get-Appx 'Microsoft.DesktopAppInstaller'
        Get-Appx 'Microsoft.WindowsStore'
        Get-Appx 'Microsoft.WindowsTerminal'
    }
    $MSStoreScript = @"
for %%a in (%~dp0msstore\Microsoft.UI.Xaml.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00.UWPDesktop_14.0.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00_14.0.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.NET.Native.Runtime.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.NET.Native.Framework.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.WindowsStore_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
for %%a in (%~dp0msstore\Microsoft.WindowsTerminal_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage "%%a"
"@
}

if ($true -eq $SkipCheck) { 
    # get appraiserres.dll from Windows 10 19041 latest setup
    Invoke-WebRequest -Uri "https://github.com/user-attachments/files/17200856/appraiserres.zip" -OutFile ".\temp\appraiserres.zip"
    Expand-Archive -Path ".\temp\appraiserres.zip" -DestinationPath ".\temp"
}

# abbodi1406/W10UI, auto inject hook
$W10UI = "@chcp 65001`n"
$W10UI += (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abbodi1406/BatUtil/master/W10UI/W10UI.cmd").Content
$W10UI = $W10UI.Replace("if %AddDrivers%==1 call :doDrv", "call %~dp0hook_beforewim.cmd`nif %AddDrivers%==1 call :doDrv")

# write hook script
@"
echo.
echo ============================================================
echo Hook W10UI beforewim Successfully!
echo Current Dir: %cd%
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
    $downloadedMd5 = Get-FileHash -Path ".\temp\$os_file" -Algorithm MD5 | Select-Object -ExpandProperty Hash
    Write-Host "Expected MD5: $os_md5"
    Write-Host "Actual   MD5: $downloadedMd5"
    if ($downloadedMd5 -ne $os_md5) {
        Write-Error "MD5 check failed, the file may be corrupted."
    } else {
        Write-Host "MD5 check passed."
    }
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
if ($null -eq $Cleanup) { $Cleanup = $true }
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

# stop cloudflare wrap to avoid long time disconnection of github
if (Test-Path "C:\Program Files\Cloudflare\Cloudflare WARP\warp-cli.exe") {
    try {
        . "C:\Program Files\Cloudflare\Cloudflare WARP\warp-cli.exe" disconnect
    } catch {
        Write-Warning "Failed to disconnect Cloudflare WARP"
    }
}

# execute W10UI script
.\bin\NSudoLC.exe -Wait -U:T -P:E -CurrentDirectory:. -UseCurrentConsole .\W10UI.cmd

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