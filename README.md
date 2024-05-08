# makeMSUpdate：制作原版集成更新的系统镜像

基于原版镜像，集成系统更新，创建多版本的系统镜像。

## 特性：

- 集成系统更新至最新 Release 版本

- 母盘为初始发布版镜像，避免使用 UUP 构建系统，组件完整

- 不使用 ResetBase 清理镜像，不会出现奇奇怪怪的问题

- 集成.NET3.5 - 4.8.1 运行库

- 更新内置 UWP：Microsoft Store、 WinGet 及 运行库 到最新版本

- 所有文件均来自微软服务器，未集成任何第三方程序，纯净安全可靠

- 未对系统进行任何优化调整，保证原滋原味

- 集成 无线显示器（Miracast 投屏）、.NET 3.5、IE 11 及中文语言包等 Features On Demand 组件

- 开启 Telnet 客户端、Direct Play 等功能

- 由 家庭中文版 集成更新并转换为 9 个版本：

  - 家庭中文版 CoreCountrySpecific
  - 家庭版 Core
  - 家庭单语言版 CoreSingleLanguage
  - 专业版 Professional
  - 专业工作站版 ProfessionalWorkstation
  - 教育版 Education
  - 企业版 Enterprise
  - IoT企业版 IoTEnterprise
  - 企业版G EnterpriseG
- ESD 打包，效率更高，方便快速装机

**了解更多：**
https://sys.xrgzs.top/get/msupdate.html

## 持续集成

MSUpdate 现在使用 GitHub Actions 的 Windows Runner 进行自动构建，能持续获取到最新的Windows系统映像。

Github Cli 一键执行所有构建：

```shell
gh workflow run make.yml -f makeversion=w1124h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1124h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=true
gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1123h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=true

gh workflow run make.yml -f makeversion=w1022h264 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1022h264 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false

gh workflow run make.yml -f makeversion=w1022h232 -f UpdateFromUUP=true -f MultiEdition=true -f SkipCheck=false
gh workflow run make.yml -f makeversion=w1022h232 -f UpdateFromUUP=false -f MultiEdition=true -f SkipCheck=false

gh workflow run make.yml -f makeversion=w11lt2464 -f UpdateFromUUP=true -f MultiEdition=false -f SkipCheck=false
gh workflow run make.yml -f makeversion=w11lt2464 -f UpdateFromUUP=true -f MultiEdition=false -f SkipCheck=true

gh workflow run make.yml -f makeversion=w10lt2164 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
gh workflow run make.yml -f makeversion=w10lt2132 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false

gh workflow run make.yml -f makeversion=w10lt1964 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
gh workflow run make.yml -f makeversion=w10lt1932 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false

gh workflow run make.yml -f makeversion=w10lt1664 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
gh workflow run make.yml -f makeversion=w10lt1632 -f UpdateFromUUP=false -f MultiEdition=false -f SkipCheck=false
```

手动构建方法：

```powershell
$MakeVersion   = [string] "w1164"
$UpdateFromUUP = [bool]   $True
$MultiEdition  = [bool]   $True
$SkipCheck     = [bool]   $True
.\msupdate.ps1
```

目前支持的参数有：

- MakeVersion：选择制作的系统版本
  - w1124h264
  - w1123h264
  - w1022h264
  - w1022h232
  - w11lt2464
  - w10lt2164
  - w10lt2132
  - w10lt1964
  - w10lt1932
  - w10lt1664
  - w10lt1632
- UpdateFromUUP：从UUPDUMP获取更新(1809+)
- MultiEdition：转换多版本(LTSC勿选)
- SkipCheck：跳过硬件检测(Win11)

构建完成后会生成 BuildLabEx 样式的 .iso 文件和 .iso.json 的校验信息文件

## 构建依赖

本项目需要使用到大量工具进行构建，包括但不限于：

- [PowerShell 7](https://github.com/PowerShell/powershell)：执行脚本
  - Windows PowerShell 5.1（Windows 10 以上已具备）

- [7-Zip](https://www.7-zip.org)：解压 ISO 等文件
- [Windows ADK](https://learn.microsoft.com/zh-cn/windows-hardware/get-started/adk-install)：可选安装，建议安装
  - DISM：镜像处理
  - Oscdimg：ISO打包

如果您在国内使用，还得再加一个依赖：

- [Watt Toolkit](https://github.com/BeyondDimension/SteamTools)：使用Hosts加速模式，配置好「加速 GitHub」（免费）
- 不推荐使用系统代理，程序可能无法正常调用

上述依赖必须提前手动安装到默认路径，其它依赖会自动下载到 bin 文件夹内。因此，请确保有稳定的互联网连接，毕竟如果没有网络无法下载所需的更新包。

其它使用到的依赖：

- [aria2c](https://github.com/aria2/aria2)：多线程高速下载
- [rclone](https://github.com/rclone/rclone)：网盘自动发布
- [abbodi1406/BatUtil/W10UI](https://github.com/abbodi1406/BatUtil/tree/master/W10UI)：集成系统更新
- [wimlib-imagex](https://wimlib.net/)：镜像信息编辑、ESD 格式转换
- [M2TeamArchived/NSudo](https://github.com/M2TeamArchived/NSudo)：管理员权限提升
- [Secant1006/PSFExtractor](https://github.com/Secant1006/PSFExtractor)：系统补丁格式转换

系统更新列表来自：

- [adavak/Win_ISO_Patching_Scripts](https://github.com/adavak/Win_ISO_Patching_Scripts)
- [UUPDUMP.net](https://uupdump.net/)