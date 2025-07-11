
function Invoke-Aria2Download {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Uri,

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

Export-ModuleMember -Function Invoke-Aria2Download