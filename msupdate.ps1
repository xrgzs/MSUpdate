$ErrorActionPreference = 'Stop'

# remove temporaty files
Remove-Item -Path ".\temp\" -Recurse -ErrorAction Ignore
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction Ignore

# Installing dependencies
if (-not (Test-Path -Path ".\bin\rclone.conf")) {
    Write-Error "rclone conf not found"
}
if (-not (Test-Path -Path ".\bin\wimlib\rclone.exe")) {
    Write-Host "rclone not found, downloading..."
    Invoke-WebRequest -Uri 'https://downloads.rclone.org/rclone-current-windows-amd64.zip' -outfile .\temp\rclone.zip
    Expand-Archive -Path .\temp\rclone.zip -DestinationPath .\temp\ -Force
    Copy-Item -Path .\temp\rclone-*-windows-amd64\rclone.exe -Destination .\bin\rclone.exe
}

$WUScript = "https://mirror.ghproxy.com/https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/netfx4.8.1/script_netfx4.8.1_19041_x64.meta4"
$NETScript = "https://mirror.ghproxy.com/https://raw.githubusercontent.com/adavak/Win_ISO_Patching_Scripts/master/Scripts/script_19041_x64.meta4"

# get wupatch
Invoke-WebRequest -Uri "$WUScript" -OutFile ".\WUScript.meta4"
Invoke-WebRequest -Uri "$NETScript" -OutFile ".\NETScript.meta4"
.\bin\aria2c.exe --no-conf --check-certificate=false -x16 -s16 -j5 -c -R -d ".\patch" -M ".\WUScript.meta4"
.\bin\aria2c.exe --no-conf --check-certificate=false -x16 -s16 -j5 -c -R -d ".\patch" -M ".\NETScript.meta4"

# get fod
# Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~~.cab
.\bin\aria2c.exe --no-conf --check-certificate=false -x16 -s16 -d ".\fod\Miracast\" -o "update.cab" "https://file.uhsea.com/2404/fa949c449de5880ea5e0648e16aa802a43.cab"
expand -f:* ".\fod\Miracast\update.cab" ".\fod\Miracast\"
# Microsoft-Windows-WirelessDisplay-FOD-Package~31bf3856ad364e35~amd64~zh-CN~.cab
.\bin\aria2c.exe --no-conf --check-certificate=false -x16 -s16 -d ".\fod\MiracastLP\" -o "update.cab" "https://file.uhsea.com/2404/907cdd078f41d9b8ca0615b5c1557790S1.cab"
expand -f:* ".\fod\Miracast\update.cab" ".\fod\MiracastLP\"

# abbodi1406/W10UI auto inject hook after resetbase
(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abbodi1406/BatUtil/master/W10UI/W10UI.cmd").Content.Replace("if %AddDrivers%==1 call :doDrv","call hook.cmd") | Out-File -FilePath ".\W10UI.cmd"

# get osimage
# get original system direct link
$obj = (Invoke-WebRequest -UseBasicParsing -Uri "$server/api/fs/get" `
-Method "POST" `
-ContentType "application/json;charset=UTF-8" `
-Body (@{
    path = "/系统/MSDN/NT10.0_Win10/19045_22H2/2006_RTM/zh-cn_windows_10_business_editions_version_22h2_x64_dvd_037e269d.iso"
    password = ""
} | Convertto-Json)).Content | ConvertFrom-Json
$osurl = $obj.data.raw_url
$osfile = $obj.data.name
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d ".\temp" -o "$osfile" "$osurl"
if ($?) {Write-Host "System Image Download Successfully!"} else {Write-Error "System Image Download Failed!"}

$isopath = Resolve-Path -Path ".\temp\$osfile"
$isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter

# write W10UI conf
"[W10UI-Configuration]
Target        =$isomount
Repo          =%cd%\patch
DismRoot      =dism.exe

Net35         =1
Net35Source   =
Cleanup       =1
ResetBase     =1
LCUwinre      =1
WinRE         =1
UpdtBootFiles =0
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
"echo.
echo ============================================================
echo Enable Features...
echo ============================================================

%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature LegacyComponents
%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature SMB1Protocol
%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature TFTP
%_dism2%:`"!_cabdir!`" %dismtarget% /Enable-Feature TelnetClient

echo ============================================================
echo Adding Features on Demands...
echo ============================================================

%_dism2%:`"!_cabdir!`" /Add-Package /PackagePath:`"fod\Miracast\update.mum`"
%_dism2%:`"!_cabdir!`" /Add-Package /PackagePath:`"fod\MiracastLP\update.mum`"

echo.
echo ============================================================
echo Updating Microsoft Store...
echo ============================================================

for %%a in (msstore\Microsoft.UI.Xaml.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
for %%a in (msstore\Microsoft.VCLibs.140.00.UWPDesktop_14.0.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
for %%a in (msstore\Microsoft.VCLibs.140.00_14.0.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
for %%a in (msstore\Microsoft.NET.Native.Runtime.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
for %%a in (msstore\Microsoft.NET.Native.Framework.2.*_8wekyb3d8bbwe.Appx) do call :Add-ProvisionedAppxPackage `"%%a`"
for %%a in (msstore\Microsoft.WindowsStore_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage `"%%a`"
for %%a in (msstore\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe.Msixbundle) do call :Add-ProvisionedAppxPackage `"%%a`"

exit /b

:Add-ProvisionedAppxPackage
echo installing - %~n1
%_dism2%:`"!_cabdir!`" %dismtarget% /Add-ProvisionedAppxPackage /PackagePath:`"%~1`" /SkipLicense /Region:all
goto :EOF
" | Out-File -FilePath ".\hook.cmd"

# execute script
.\W10UI.cmd

# upload to cloud
.\bin\rclone.exe copy "*.iso" "odb:/Share/Xiaoran Studio/System/Nightly" --progress
if ($?) {Write-Host "Upload Successfully!"} else {Write-Error "Upload Failed!"}
