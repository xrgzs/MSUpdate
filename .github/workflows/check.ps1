param (
    [switch]$DatabaseOnly
)
$ErrorActionPreference = 'Stop'

function Request-Update {
    param (
        [string]
        $Category
    )

    $match = ((Invoke-WebRequest -Uri "https://uupdump.net/known.php?q=category:$Category").Links | 
              Where-Object { $_.href -like "selectlang.php?id=*" } | 
              Where-Object { $_.outerHTML -like "*amd64*" })[0].outerHTML -match '\((\d+\.\d+)\)'

    if ($match) {
        $LatestVersion = $Matches[1]
        Write-Host -ForegroundColor Green "The latest version of $Category is $LatestVersion"
        return $LatestVersion
    } else {
        Write-Host -ForegroundColor Red "Failed to get the latest version"
    }
}

if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "Installing PowerShell module powershell-yaml..."
    Install-Module -Name powershell-yaml -Force -ErrorAction Stop
} else {
    Write-Host "PowerShell module powershell-yaml is already installed."
}

$StatePath = Join-Path '.' 'State.yml' -Resolve

$CurrentState = Get-Content -Path $StatePath | ConvertFrom-Yaml -Ordered

foreach ($Category in $CurrentState.Keys) {
    $CurrentVersion = $CurrentState.$Category.Version
    Write-Host -ForegroundColor Yellow "Current version of $Category is $CurrentVersion"
    $LatestVersion = Request-Update -Category $Category

    if ($LatestVersion -ne $CurrentVersion) {
        Write-Host -ForegroundColor Green "New version of $Category is available: $LatestVersion"
        $CurrentState.$Category.Version = $LatestVersion

        $scriptBlock = [scriptblock]::Create($CurrentState.$Category.Commands -join "`n")

        if (!$DatabaseOnly) {
            Write-Host -ForegroundColor Green "Executing commands for $Category ..."
            Write-Host -ForegroundColor Yellow $scriptBlock
            . $scriptBlock
        }
    } else {
        Write-Host -ForegroundColor Yellow "No new version of $Category is available"
    }
}

$CurrentState | ConvertTo-Yaml | Set-Content -Path $StatePath