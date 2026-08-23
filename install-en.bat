@echo off
setlocal
:: ============================================================
:: Copy File Path - one-click install (English menu text)
:: Use this if your system shows the Chinese menu text incorrectly.
:: ============================================================

set "LANGUAGE=en"
set "DISPLAY_NAME=Copy File Path"
set "APP_DIR=%APPDATA%\CopyFilePath"
set "EXE=%APP_DIR%\CopyPath.exe"
set "SRC=%~dp0CopyPath.exe"
set "WIN11=0"
set "DOTNET_OK=0"
set "WIN_BUILD=0"
set "DOTNET_FULL="
set "DOTNET_CLIENT="

for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul ^| find /i "CurrentBuildNumber"') do set "WIN_BUILD=%%A"
if %WIN_BUILD% GEQ 22000 set "WIN11=1"

for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Install 2^>nul ^| find /i "Install"') do set "DOTNET_FULL=%%A"
if /i "%DOTNET_FULL%"=="0x1" set "DOTNET_OK=1"
if "%DOTNET_OK%"=="0" (
    for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client" /v Install 2^>nul ^| find /i "Install"') do set "DOTNET_CLIENT=%%A"
    if /i "%DOTNET_CLIENT%"=="0x1" set "DOTNET_OK=1"
)

if "%DOTNET_OK%"=="0" (
    echo.
    echo [ERROR] .NET Framework 4.x was not detected on this PC.
    echo   This tool needs .NET Framework 4.x to run.
    echo   Install .NET Framework 4.8 Runtime first, then run install-en.bat again:
    echo   https://dotnet.microsoft.com/download/dotnet-framework/net48
    echo.
    pause
    exit /b 1
)

reg delete "HKCU\Software\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\*\shell\CopyFilePath_TestZh" /f >nul 2>&1

if not exist "%APP_DIR%" mkdir "%APP_DIR%"
copy /Y "%SRC%" "%EXE%" >nul
if not exist "%EXE%" (
    echo [ERROR] CopyPath.exe not found. Keep it next to install-en.bat.
    pause
    exit /b 1
)

"%EXE%" --install "%EXE%" %LANGUAGE%
if errorlevel 1 (
    echo [ERROR] context menu install failed.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo [Copy File Path] Installed successfully!
echo   Right-click any file / folder / folder blank,
echo   choose "%DISPLAY_NAME%" to copy the absolute path.
echo   Run file: %EXE%
echo ============================================================
if "%WIN11%"=="1" (
echo.
echo [NOTE] Windows 11 detected.
echo   This tool works on Windows 11, but the menu item may appear under:
echo   "Show more options"  ^(or press Shift+F10^)
)
echo.
pause
