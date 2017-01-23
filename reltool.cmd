:: Cleanup
mkdir _build

:: Build installer bundle
@set ressources=%USERPROFILE%\SYSMO_NMS_RESSOURCES
@set CORE_VERSION="2.0.1"
@set OPERATOR_VERSION="2.0.3"
@set BUNDLE_VERSION="2.0"
@if not exist %ressources% mkdir %ressources%

@if not DEFINED PLATFORM set PLATFORM="x64"

@if "%PLATFORM%" == "Win32" (
    @set WIX_ARCH="x86"
    @set VCREDIST_INSTALLER=%ressources%\vcredist_x86.exe
    @set JAVA_INSTALLER=%ressources%\jre8_586.exe
    @set vcredist_location="http://www.sysmo.io/runtime/msvc2015/vc_redist.x86.exe"
    @set java_location="http://www.sysmo.io/runtime/jre/jre-8u111-windows-i586.exe"
    @set core_msi_location="https://github.com/sysmo-nms/sysmo-core/releases/download/%CORE_VERSION%/__installer-%WIX_ARCH%.msi"
    @set operator_msi_location="https://github.com/sysmo-nms/sysmo-operator/releases/download/%OPERATOR_VERSION%/__installer-%WIX_ARCH%.msi"
) else (
    @set WIX_ARCH="x64"
    @set VCREDIST_INSTALLER=%ressources%\vcredist_x64.exe
    @set JAVA_INSTALLER=%ressources%\jre8_64.exe
    @set vcredist_location="http://www.sysmo.io/runtime/msvc2015/vc_redist.x64.exe"
    @set java_location="http://www.sysmo.io/runtime/jre/jre-8u111-windows-x64.exe"
)

if not exist "%VCREDIST_INSTALLER%" curl -fSL -o "%VCREDIST_INSTALLER%" %vcredist_location%
copy /y %VCREDIST_INSTALLER% _build\vcredist.exe

if not exist "%JAVA_INSTALLER%" curl -fSL -o "%JAVA_INSTALLER%"     %java_location%
copy /y %JAVA_INSTALLER% _build\jre.exe

set OPERATOR_INSTALLER="_build\__operator_installer.msi"
set CORE_INSTALLER="_build\__core_installer.msi"
set core_msi_location="https://github.com/sysmo-nms/sysmo-core/releases/download/%CORE_VERSION%/__installer-%WIX_ARCH%.msi"
set operator_msi_location="https://github.com/sysmo-nms/sysmo-operator/releases/download/%OPERATOR_VERSION%/__installer-%WIX_ARCH%.msi"

curl -fSL -o "%OPERATOR_INSTALLER%" %core_msi_location%
curl -fSL -o "%CORE_INSTALLER%" %operator_msi_location%

:: Wix bundle
@set PATH=C:\Program Files (x86)\Wix Toolset v3.10\bin;%PATH%
@set wix_opts= -v -nologo -ext WixNetFxExtension -ext WixBalExtension -ext WixUtilExtension -ext WixFirewallExtension -ext WixUIExtension

@echo "Run candle.exe"
candle.exe %wix_opts% -arch %WIX_ARCH% -o _build\bundle.wixobj bundle.wxs
@echo "Run light.exe"
light.exe %wix_opts% -o _build\Sysmo-NMS-%BUNDLE_VERSION%-%PLATFORM%.exe _build\bundle.wixobj
@echo "End of installer build"
