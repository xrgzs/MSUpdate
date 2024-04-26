$ErrorActionPreference = 'Stop'
if ($makeversion -eq "w1164") {
    # make 11 23h2 64
    $ospath = "/系统/MSDN/NT10.0_Win11/22631_23H2/2428_RTM/zh-cn_windows_11_business_editions_version_23h2_x64_dvd_2a79e0f1.iso"
    $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_22621_x64.meta4"
    $Miracast = "https://file.uhsea.com/2404/9dee091435ee149c1f6207f70fb46a6a7U.cab"
    $MiracastLP = "https://file.uhsea.com/2404/9f8486cf6b5fe60d7f0fff1777715b8cW0.cab"
    $iexplorer = "https://file.uhsea.com/2404/0d0a81d87b97263a9745229c715b849bKF.cab"
    $msstore = $true
    $SelectEdition = "Professional"
} if ($makeversion -eq "w1164uup") {
    # make 11 23h2 64 (updates from uupdump)
    $ospath = "/系统/MSDN/NT10.0_Win11/22631_23H2/2428_RTM/zh-cn_windows_11_business_editions_version_23h2_x64_dvd_2a79e0f1.iso"
    $uupid = ((Invoke-WebRequest -Uri "https://uupdump.net/known.php?q=category:w11-23h2").Links.href | Where-Object {$_ -like "selectlang.php?id=*"})[0].replace("selectlang.php?id=","")
    $UUPScript = "https://uupdump.net/get.php?id=$uupid&pack=0&edition=updateOnly&aria2=2"
    $Miracast = "https://file.uhsea.com/2404/9dee091435ee149c1f6207f70fb46a6a7U.cab"
    $MiracastLP = "https://file.uhsea.com/2404/9f8486cf6b5fe60d7f0fff1777715b8cW0.cab"
    $iexplorer = "https://file.uhsea.com/2404/0d0a81d87b97263a9745229c715b849bKF.cab"
    $msstore = $true
    $SelectEdition = "Professional"
} elseif ($makeversion -eq "w1064") {
    # make 10 22h2 64
    $ospath = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/zh-cn_windows_10_business_editions_version_22h2_x64_dvd_037e269d.iso"
    $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"
    $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
    $Miracast = "https://file.uhsea.com/2404/fa949c449de5880ea5e0648e16aa802a43.cab"
    $MiracastLP = "https://file.uhsea.com/2404/907cdd078f41d9b8ca0615b5c1557790S1.cab"
    $msstore = $true
    $SelectEdition = "Professional"
} elseif ($makeversion -eq "w1064uup") {
    # make 10 22h2 64 (updates from uupdump)
    $ospath = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/zh-cn_windows_10_business_editions_version_22h2_x64_dvd_037e269d.iso"
    $uupid = ((Invoke-WebRequest -Uri "https://uupdump.net/known.php?q=category:w10-22h2").Links | Where-Object {$_.href -like "selectlang.php?id=*"} | Where-Object {$_.outerHTML -like "*amd64*"})[0].href.replace("selectlang.php?id=","")
    $UUPScript = "https://uupdump.net/get.php?id=$uupid&pack=0&edition=updateOnly&aria2=2"
    $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
    $Miracast = "https://file.uhsea.com/2404/fa949c449de5880ea5e0648e16aa802a43.cab"
    $MiracastLP = "https://file.uhsea.com/2404/907cdd078f41d9b8ca0615b5c1557790S1.cab"
    $msstore = $true
    $SelectEdition = "Professional"
} elseif ($makeversion -eq "w10lt2164") {
    # make 10 ltsc2021 64
    $ospath = "/系统/MSDN/NT10.0_Win10/19044_LTSC2021/zh-cn_windows_10_enterprise_ltsc_2021_x64_dvd_033b7312.iso"
    $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"
    $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
} elseif ($makeversion -eq "w10lt1964") {
    # make 10 ltsc2019 64
    $ospath = "/系统/MSDN/NT10.0_Win10/17763_LTSC2019/cn_windows_10_enterprise_ltsc_2019_x64_dvd_9c09ff24.iso"
    $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_17763_x64.meta4"
    $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_17763_x64.meta4"
} elseif ($makeversion -eq "w10lt1664") {
    # make 10 ltsb2016 64
    $ospath = "/系统/MSDN/NT10.0_Win10/14393_LTSB2016/cn_windows_10_enterprise_2016_ltsb_x64_dvd_9060409.iso"
    $WUScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_14393_x64.meta4"
    $NETScript = "https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8/script_netfx4.8_14393_x64.meta4"
} else {
    Write-Error "Not defined or Unsupported OS version"
}

# remove temporaty files
Remove-Item -Path ".\temp\" -Recurse -ErrorAction Ignore
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction Ignore

# Installing dependencies
if (-not (Test-Path -Path ".\bin\rclone.conf")) {
    Write-Error "rclone conf not found"
}
if (-not (Test-Path -Path ".\bin\rclone.exe")) {
    Write-Host "rclone not found, downloading..."
    Invoke-WebRequest -Uri 'https://downloads.rclone.org/rclone-current-windows-amd64.zip' -outfile .\temp\rclone.zip
    Expand-Archive -Path .\temp\rclone.zip -DestinationPath .\temp\ -Force
    Copy-Item -Path .\temp\rclone-*-windows-amd64\rclone.exe -Destination .\bin\rclone.exe
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
    Write-Host "wimlib-imagex not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/Secant1006/PSFExtractor/releases/download/v3.07/PSFExtractor-v3.07-x64.zip' -outfile .\temp\PSFExtractor.zip
    Expand-Archive -Path .\temp\PSFExtractor.zip -DestinationPath .\bin -Force
}

# get wupatch
if ($null -ne $UUPScript) {
    Invoke-WebRequest -Uri $UUPScript -OutFile ".\UUPScript.txt"
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -j5 -c -R -d ".\patch" -i ".\UUPScript.txt"
    if (!$?) {Write-Error "UUPScript Download Failed!"}
} elseif ($null -ne $WUScript) {
    Invoke-WebRequest -Uri $WUScript -OutFile ".\WUScript.meta4"
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -j5 -c -R -d ".\patch" -M ".\WUScript.meta4"
    if (!$?) {Write-Error "WUScript Download Failed!"}
} else {
    Write-Error "No Windows Update Scripts Found!"
}
if ($null -ne $NETScript) {
    Invoke-WebRequest -Uri $NETScript -OutFile ".\NETScript.meta4"
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -j5 -c -R -d ".\patch" -M ".\NETScript.meta4" --metalink-language="neutral"
    if (!$?) {Write-Error "NETScript Download Failed!"}
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -j5 -c -R -d ".\patch" -M ".\NETScript.meta4" --metalink-language="zh-CN"
    if (!$?) {Write-Error "NETScript Download Failed!"}
}

# get fod
if ($null -ne $Miracast) {
    # Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~~.cab
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -d ".\fod\Miracast\" -o "update.cab" "$Miracast"
    if (!$?) {Write-Error "Miracast Download Failed!"}
    expand -f:* ".\fod\Miracast\update.cab" ".\fod\Miracast\"
    # Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~zh-CN~.cab
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -d ".\fod\MiracastLP\" -o "update.cab" "$MiracastLP"
    if (!$?) {Write-Error "MiracastLP Download Failed!"}
    expand -f:* ".\fod\Miracast\update.cab" ".\fod\MiracastLP\"
}
if ($null -ne $iexplorer) {
    # microsoft-windows-internetexplorer-optional-package~31bf3856ad364e35~amd64~~.cab
    .\bin\aria2c.exe --check-certificate=false -x16 -s16 -d ".\fod\iexplorer\" -o "update.cab" "$iexplorer"
    if (!$?) {Write-Error "iexplorer Download Failed!"}
    expand -f:* ".\fod\iexplorer\update.cab" ".\fod\iexplorer\"
}

if ($true -eq $msstore) {
    # get msstore
    .\getappx.ps1
    $MSStoreScript = "
    for %%a in (%~dp0msstore\Microsoft.UI.Xaml.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
    for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00.UWPDesktop_14.0.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
    for %%a in (%~dp0msstore\Microsoft.VCLibs.140.00_14.0.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
    for %%a in (%~dp0msstore\Microsoft.NET.Native.Runtime.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
    for %%a in (%~dp0msstore\Microsoft.NET.Native.Framework.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
    for %%a in (%~dp0msstore\Microsoft.WindowsStore_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage `"%%a`"
    for %%a in (%~dp0msstore\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage `"%%a`"
    "
}


# abbodi1406/W10UI, auto inject hook after resetbase
(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abbodi1406/BatUtil/master/W10UI/W10UI.cmd").Content.Replace("if %AddDrivers%==1 call :doDrv","call %~dp0hook.cmd") | Out-File -FilePath ".\W10UI.cmd"

# get osimage
# get original system direct link
$obj = (Invoke-WebRequest -UseBasicParsing -Uri "https://alist.xrgzs.top/api/fs/get" `
-Method "POST" `
-ContentType "application/json;charset=UTF-8" `
-Body (@{
    path = $ospath
    password = ""
} | Convertto-Json)).Content | ConvertFrom-Json
$osurl = $obj.data.raw_url
$osfile = $obj.data.name
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d ".\temp" -o "$osfile" "$osurl"
if ($?) {Write-Host "System Image Download Successfully!"} else {Write-Error "System Image Download Failed!"}

# $isopath = Resolve-Path -Path ".\temp\$osfile"
# $isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter
# Target        =${isomount}:
."C:\Program Files\7-Zip\7z.exe" x ".\temp\$osfile" -o".\ISO" -r

# select 1 edition only
if ($null -ne $SelectEdition) {
    .\bin\wimlib-imagex.exe info ".\ISO\sources\install.wim" --extract-xml ".\temp\WIMInfo.xml"
    $WIMInfo = [xml](Get-Content ".\temp\WIMInfo.xml")
    $WIMIndex = $WIMInfo.WIM.IMAGE | Where-Object {$_.WINDOWS.EDITIONID -eq "$SelectEdition"} | Select-Object -ExpandProperty INDEX
    $WIMIndexs = $WIMInfo.WIM.IMAGE.Index | Measure-Object | Select-Object -ExpandProperty Count
    for ($i = $WIMIndexs; $i -gt $WIMIndex; $i--) {
        # .\bin\wimlib-imagex.exe delete ".\ISO\sources\install.wim" $i --soft
        Remove-WindowsImage -ImagePath ".\ISO\sources\install.wim" -Index $i
    }
    for ($i = 1; $i -lt $WIMIndex; $i++) {
        Remove-WindowsImage -ImagePath ".\ISO\sources\install.wim" -Index 1
    }
}

.\bin\wimlib-imagex.exe info ".\ISO\sources\install.wim" --extract-xml ".\temp\WIMInfo2.xml"
Get-Content ".\temp\WIMInfo2.xml"

# write W10UI conf
"[W10UI-Configuration]
Target        =%cd%\ISO
Repo          =%cd%\patch
DismRoot      =dism.exe

Net35         =1
Net35Source   =
Cleanup       =1
ResetBase     =1
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
" | Out-File -FilePath ".\W10UI.ini"

# write hook script
"
if exist `"!mountdir!\Windows\Servicing\Packages\*WinPE-LanguagePack*.mum`" exit /b

echo.
echo ============================================================
echo Enable Features...
echo ============================================================

%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature:LegacyComponents /All
%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature:SMB1Protocol
%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature:TFTP
%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature:TelnetClient

echo.
echo ============================================================
echo Adding Features on Demands...
echo ============================================================

echo current dir: %cd%

if exist `"%~dp0fod\Miracast\update.mum`" (
    %_dism2%:`"!_cabdir!`" %dismtarget% /Add-Package /PackagePath:`"%~dp0fod\Miracast\update.mum`" 
    %_dism2%:`"!_cabdir!`" %dismtarget% /Add-Package /PackagePath:`"%~dp0fod\MiracastLP\update.mum`"
)
if exist `"%~dp0fod\iexplorer\update.mum`" (
    %_dism2%:`"!_cabdir!`" %dismtarget% /Add-Package /PackagePath:`"%~dp0fod\iexplorer\update.mum`" 
)

echo.
echo ============================================================
echo Updating Microsoft Store...
echo ============================================================

$MSStoreScript

exit /b

:Add-ProvisionedAppxPackage
echo installing - %~n1
%_dism2%:`"!_cabdir!`" %dismtarget% /Add-ProvisionedAppxPackage /PackagePath:`"%~1`" /SkipLicense /Region:all
goto :EOF
" | Out-File -FilePath ".\hook.cmd"

# execute W10UI script
.\W10UI.cmd

# upload to cloud
Get-ChildItem -Path "./*.iso" -File | ForEach-Object {
    .\bin\rclone.exe copy $_.FullName "odb:/Share/Xiaoran Studio/System/Nightly" --progress
}
