function Download-Appx($Name) {
    $obj = Invoke-WebRequest -Uri "https://store.xr6.xyz/api/GetFiles" `
    -Method "POST" `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{
        type = 'PackageFamilyName'
        url = $Name + '_8wekyb3d8bbwe'
        ring = 'RP'
        lang = 'zh-CN'
    }

    foreach ($link in $obj.Links) {
        if ($link.outerHTML -match '(?<=<a\b[^>]*>).*?(?=</a>)') {
            $linkText = $Matches[0]
            if ($linkText -match '(x64|neutral).*\.(appx|appxbundle|msixbundle)\b') {
                Write-Debug "$linkText : $($link.href)"
                if (Test-Path -Path $linkText) {
                    Write-Warning "Already exists, skiping $linkText"
                } else {
                    Invoke-WebRequest -Uri $link.href -OutFile "$PSScriptRoot\msstore\$linkText"
                }
            }
        }
    }
}
Remove-Item -Path "$PSScriptRoot\msstore" -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$PSScriptRoot\msstore" -ErrorAction SilentlyContinue

Download-Appx 'Microsoft.DesktopAppInstaller'
Download-Appx 'Microsoft.WindowsStore'
