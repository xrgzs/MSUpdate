function Compare-Version {
    [OutputType([bool])]
    param (
        [string]$CurrentVersion,
        [string]$LatestVersion
    )
    
    if ([string]::IsNullOrEmpty($CurrentVersion) -or [string]::IsNullOrEmpty($LatestVersion)) {
        return $false
    }
    
    try {
        $current = [version]$CurrentVersion
        $latest = [version]$LatestVersion
        
        return $latest -gt $current
    } catch {
        Write-Host -ForegroundColor Red "Failed to parse version: Current=$CurrentVersion, Latest=$LatestVersion"
        return $false
    }
}

Export-ModuleMember -Function "Compare-Version"