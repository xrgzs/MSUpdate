# MSUpdate 原版集成更新系统制作

MSUpdate is a tool to make updated copies of the original Windows system images.

It can be used to make a copy of the original Windows system images and then update the original Windows system images. It can also automatically convert multi-edition Windows system images from a single edition.

Details：https://sys.xrgzs.top/get/msupdate.html

MSUpdate now supports building with Github Actions's Windows Runner, which mains you can get the latest version of Windows system images continuously.

Dependencies:

- PowerShell 7
- 7-Zip installed on the default path
- Windows ADK (latest better, at least 10.0.10240.16384)

The above dependencies need to be installed manually, and other dependencies will be downloaded and installed automatically. Therefore, you need to have an Internet connection.