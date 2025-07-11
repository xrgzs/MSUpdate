param (
    [switch]$DatabaseOnly
)
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\..\..\Modules\compare.psm1"
Import-Module "$PSScriptRoot\..\..\Modules\request.psm1"

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

    if ($LatestVersion) {
        $IsNewerVersion = Compare-Version -CurrentVersion $CurrentVersion -LatestVersion $LatestVersion
        
        if ($IsNewerVersion) {
            Write-Host -ForegroundColor Green "New version of $Category is available: $LatestVersion (current: $CurrentVersion)"
            $CurrentState.$Category.Version = $LatestVersion

            $scriptBlock = [scriptblock]::Create($CurrentState.$Category.Commands -join "`n")

            if (!$DatabaseOnly) {
                Write-Host -ForegroundColor Green "Executing commands for $Category ..."
                Write-Host -ForegroundColor Yellow $scriptBlock
                . $scriptBlock
            }
        } else {
            Write-Host -ForegroundColor Yellow "Current version of $Category is up to date ($CurrentVersion), skipping ($LatestVersion)..."
        }
    } else {
        Write-Host -ForegroundColor Red "Failed to get latest version for $Category, skipping..."
    }
}

$CurrentState | ConvertTo-Yaml | Set-Content -Path $StatePath