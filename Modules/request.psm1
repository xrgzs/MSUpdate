function Invoke-UUPWebRequest {
    param (
        [string]$Url
    )
    $RetryCount = 0
    while ($RetryCount -lt 10) {
        if (($RetryCount) % 2 -eq 0) {
            $Entrypoint = "https://uupdump.net"
        } else {
            $Entrypoint = "https://uup.xrgzs.top"
        }
        $RequestUri = "$Entrypoint/$Url"
        Write-Host -ForegroundColor Yellow "Attempting request to $RequestUri (Attempt $($RetryCount + 1))..."
        $Response = Invoke-WebRequest -Uri $RequestUri `
            -SkipHttpErrorCheck `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0" `
            -Headers @{ "accept-language" = "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" }
        if ($Response.Content -notmatch 'Just a moment' -and $Response.StatusCode -eq 200) {
            Write-Host -ForegroundColor Green "Request successful!"
            return $Response
        }
        Write-Host -ForegroundColor Red "Request failed. Retrying in 1 seconds..."
        Start-Sleep -Seconds 1
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
            $Links = $Links | Where-Object { $_.href -like $LinkFilter }
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
    if ($null -ne $Links -and $Links.Count -gt 0) {
        if ($FirstLink) {
            return $Links[0].href
        } else {
            return $Links
        }
    } else {
        Write-Error "No links found!"
        return $null
    }
}

function Request-Update {
    [OutputType([string])]
    param (
        [string] $Category,
        [string] $QueryString
    )
    if ($Category) {
        $Name = $Category
        $AllLinks = Invoke-UUPWebRequestLink -Url "known.php?q=category:$Category" -LinkFilter @("*selectlang.php?id=*") -ContentFilter @("*amd64*")
    } elseif ($QueryString) {
        $Name = $QueryString
        $AllLinks = Invoke-UUPWebRequestLink -Url "known.php?q=$QueryString" -LinkFilter @("*selectlang.php?id=*") -ContentFilter @("*amd64*")
    } else {
        Write-Host -ForegroundColor Red "Please specify the correct parameter."
        return $null
    }
    Write-Host "Retrieved all known links of $Name : $($AllLinks | ConvertTo-Json)"

    $Link = $AllLinks | Where-Object { $_.outerHTML -match '\((\d+\.\d+)\)' } | Select-Object -First 1
    if ($Link -and $Link.outerHTML -match '\((\d+\.\d+)\)') {
        $LatestVersion = $Matches[1]
        Write-Host -ForegroundColor Green "The latest version of $Name is $LatestVersion"
        return $LatestVersion
    }

    $Link = $AllLinks | Where-Object { $_.outerHTML -match '10\.0\.(\d+\.\d+)' } | Select-Object -First 1
    if ($Link -and $Link.outerHTML -match '10\.0\.(\d+\.\d+)') {
        $LatestVersion = $Matches[1]
        Write-Host -ForegroundColor Green "The latest version of $Name is $LatestVersion"
        return $LatestVersion
    }
    Write-Host -ForegroundColor Red "Failed to get the latest version of $Name"
    return $null
}

Export-ModuleMember -Function Invoke-UUPWebRequest, Invoke-UUPWebRequestLink, Request-Update
