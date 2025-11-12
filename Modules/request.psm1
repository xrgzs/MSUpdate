function Invoke-UUPApiRequest {
    param (
        [string] $Url
    )
    $RetryCount = 0
    while ($RetryCount -lt 10) {
        switch ($RetryCount % 2) {
            0 { $Entrypoint = "https://api.uupdump.net" }
            1 { $Entrypoint = "https://uup.xrgzs.top/json-api" }
        }
        $RequestUri = "$Entrypoint/$Url"
        Write-Host -ForegroundColor Yellow "Attempting request to $RequestUri (Attempt $($RetryCount + 1))..."
        $Response = Invoke-WebRequest -Uri $RequestUri `
            -SkipHttpErrorCheck `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0" `
            -Headers @{ "accept-language" = "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6" }
        if ($Response.Content -notmatch 'Just a moment' -and $Response.StatusCode -eq 200 -and $Response.Content -ne "") {
            Write-Host -ForegroundColor Green "Request successful!"
            return $Response
        }
        Write-Host -ForegroundColor Red "Request failed. Retrying in 1 seconds..."
        Start-Sleep -Seconds 1
        $RetryCount++
    }
    throw "Failed to retrieve content from $Url after 10 attempts."
}

function Invoke-UUPWebRequest {
    param (
        [string]$Url
    )
    $RetryCount = 0
    while ($RetryCount -lt 10) {
        switch ($RetryCount % 3) {
            0 { $Entrypoint = "https://uupdump.net" }
            1 { $Entrypoint = "https://uup.xrgzs.top" }
            2 { $Entrypoint = "https://uup.671001.xyz" }
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

function Get-UUPFiles {
    param(
        [Parameter(Mandatory = $True)]
        [string] $Id,

        [string] $Lang,
        [string] $Edition,
        [switch] $NoLink
    )
    $query = [System.Web.HttpUtility]::ParseQueryString("")
    if ($id) { $query["id"] = $Id } else { throw "Id is required." }
    if ($lang) { $query["lang"] = $Lang }
    if ($edition) { $query["edition"] = $Edition }
    if ($NoLink) { $query["nolink"] = "1" }

    $response = Invoke-UUPApiRequest -Url "get.php?$($query.ToString())" | ConvertFrom-Json -AsHashtable

    if ($null -eq $response) {
        throw "Null response received from UUP API."
    }


    # {
    #   "response": {
    #     "apiVersion": "string", // Current UUP dump API version
    #     "updateName": "string", // Update title, such as Windows 10 Insider Preview 19577.1000 (rs_prerelease)
    #     "arch": "string", // Update architecture, for example x86
    #     "build": "string", // Update build number, for example 19577.1000
    #     "files": { // All files contained in the package
    #       "string": { // File name, such as 'core_en-us.esd', 'microsoft-windows-client-features-package.esd', etc.
    #         "sha1": "string", // The file's SHA1 checksum.
    #         "size": "string", // File size in bytes
    #         "url": "string", // File download link, 'null' if noLinks=1
    #         "uuid": "string", // File UUIDv4, 'null' if noLinks=1 used
    #         "expire": "string", // Link expiration date, '0' if noLinks=1 used
    #         "debug": "string" // Raw data from Microsoft servers, 'null' if noLinks=1 used
    #       },
    #       ...
    #     }
    #   },
    #   "jsonApiVersion": "string" // Current JSON API version
    # }

    Write-Host -ForegroundColor Green "Remote UUP JSON Api version: $($response.jsonApiVersion)"
    Write-Host -ForegroundColor Green "Update Name: $($response.response.updateName)"
    Write-Host -ForegroundColor Green "Architecture: $($response.response.arch)"
    Write-Host -ForegroundColor Green "Build Number: $($response.response.build)"

    # convert to hashtable for easier access
    $filesHashtable = @{}
    foreach ($fileName in $response.response.files.Keys) {
        $filesHashtable[$fileName] = $response.response.files.$fileName
        # $file = $response.response.files.$fileName
        # Write-Host -ForegroundColor Cyan "File: $fileName, Size: $($file.size), SHA1: $($file.sha1), URL: $($file.url)"
    }

    return $filesHashtable
}


$UUPFilesCacheById = @{}
function Get-UUPFile {
    param (
        [Parameter(Mandatory = $True)]
        [string] $Id,

        [Parameter(Mandatory = $True)]
        [string] $FileName
    )

    if (-not $UUPFilesCacheById.ContainsKey($Id)) {
        Write-Host -ForegroundColor Yellow "Cache miss for Id $Id. Fetching UUP files..."
        $files = Get-UUPFiles -Id $Id
        $UUPFilesCacheById[$Id] = $files
    } else {
        Write-Host -ForegroundColor Green "Cache hit for Id $Id."
        $files = $UUPFilesCacheById[$Id]
    }

    return $files[$FileName]
}

function Get-UUPFileLink {
    param (
        [Parameter(Mandatory = $True)]
        [string] $Id,

        [Parameter(Mandatory = $True)]
        [string] $FileName
    )

    $file = Get-UUPFile -Id $Id -FileName $FileName
    if ($null -eq $file.url) {
        throw "File URL is null for Id $Id and FileName $FileName."
    }
    return $file.url
}

Export-ModuleMember -Function Invoke-UUPWebRequest, Invoke-UUPWebRequestLink, Request-Update, Get-UUPFiles, Get-UUPFile, Get-UUPFileLink, Invoke-UUPApiRequest
