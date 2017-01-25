::
set BUNDLE_VERSION=1.2
set CORE_VERSION=2.0.2
set OPERATOR_VERSION=2.0.4

:: Cleanup
rmdir /s /q _build
mkdir _build

:: Build installer bundle
set ressources=%USERPROFILE%\SYSMO_NMS_RESSOURCES
if not exist %ressources% mkdir %ressources%

if not DEFINED PLATFORM set PLATFORM=x64

if "%PLATFORM%" == "Win32" (
    set WIX_ARCH=x86
    set COMMON_ARCH=i586
    set VCREDIST_INSTALLER_2010=%ressources%\2015_vcredist_x86.exe
    set VCREDIST_INSTALLER_2015=%ressources%\2010_vcredist_x86.exe
    set JAVA_INSTALLER=%ressources%\jre8_586.exe
    set vcredist_location_2010="https://github.com/sysmo-nms/bundle/releases/download/RESSOURCES/msvc2010_vc_redist.x86.exe"
    set vcredist_location_2015="https://github.com/sysmo-nms/bundle/releases/download/RESSOURCES/msvc2015_vc_redist.x86.exe"
    set java_location="https://github.com/sysmo-nms/bundle/releases/download/RESSOURCES/jre-8u111-windows-i586.exe"
) else (
    set WIX_ARCH=x64
    set COMMON_ARCH=x64
    set VCREDIST_INSTALLER_2010=%ressources%\2015_vcredist_x64.exe
    set VCREDIST_INSTALLER_2015=%ressources%\2010_vcredist_x64.exe
    set JAVA_INSTALLER=%ressources%\jre8_64.exe
    set vcredist_location_2010="https://github.com/sysmo-nms/bundle/releases/download/RESSOURCES/msvc2010_vc_redist.x64.exe"
    set vcredist_location_2015="https://github.com/sysmo-nms/bundle/releases/download/RESSOURCES/msvc2015_vc_redist.x64.exe"
    set java_location="https://github.com/sysmo-nms/bundle/releases/download/RESSOURCES/jre-8u111-windows-x64.exe"
)

set core_msi_location="https://github.com/sysmo-nms/sysmo-core/releases/download/%CORE_VERSION%/__installer-%COMMON_ARCH%.msi"
set operator_msi_location="https://github.com/sysmo-nms/sysmo-operator/releases/download/%OPERATOR_VERSION%/__installer-%COMMON_ARCH%.msi"

if not exist "%VCREDIST_INSTALLER_2010%" curl -fSL -o "%VCREDIST_INSTALLER_2010%" %vcredist_location_2010%
copy /y %VCREDIST_INSTALLER_2010% _build\vcredist_2010.exe
if not exist "%VCREDIST_INSTALLER_2015%" curl -fSL -o "%VCREDIST_INSTALLER_2015%" %vcredist_location_2015%
copy /y %VCREDIST_INSTALLER_2015% _build\vcredist_2015.exe

if not exist "%JAVA_INSTALLER%" curl -fSL -o "%JAVA_INSTALLER%"     %java_location%
copy /y %JAVA_INSTALLER% _build\jre.exe

set OPERATOR_INSTALLER=_build\__operator_installer.msi
set CORE_INSTALLER=_build\__core_installer.msi

curl -fSL -o %CORE_INSTALLER% %core_msi_location%
curl -fSL -o %OPERATOR_INSTALLER% %operator_msi_location%

:: Wix bundle
set PATH=C:\Program Files (x86)\Wix Toolset v3.10\bin;%PATH%
set wix_opts= -v -nologo -ext WixNetFxExtension -ext WixBalExtension -ext WixUtilExtension -ext WixFirewallExtension -ext WixUIExtension

@echo "Run candle.exe"
candle.exe %wix_opts% -arch %WIX_ARCH% -o _build\bundle.wixobj bundle.wxs
@echo "Run light.exe"
light.exe %wix_opts% -o _build\Sysmo-NMS-%BUNDLE_VERSION%-%COMMON_ARCH%.exe _build\bundle.wixobj
@echo "End of installer build"
