@echo off
setlocal enabledelayedexpansion
:: ============================================================
:: Copy File Path - one-click install (no admin needed)
:: 1) copy CopyPath.exe to %APPDATA%\CopyFilePath\
:: 2) write HKCU context menu (file / folder / folder blank)
:: ============================================================

set "APP_DIR=%APPDATA%\CopyFilePath"
set "EXE=%APP_DIR%\CopyPath.exe"
set "SRC=%~dp0CopyPath.exe"

if not exist "%APP_DIR%" mkdir "%APP_DIR%"
copy /Y "%SRC%" "%EXE%" >nul
if not exist "%EXE%" (
    echo [ERROR] CopyPath.exe not found. Keep it next to install.bat.
    pause
    exit /b 1
)

:: build temp reg (replace %APPDATA% with real path) then import
set "TMPREG=%TEMP%\CopyFilePath_install.reg"
(
echo Windows Registry Editor Version 5.00
echo+
echo [HKEY_CURRENT_USER\Software\Classes\*\shell\CopyFilePath]
echo @="Copy File Path"
echo "Icon"="imageres.dll,-5302"
echo+
echo [HKEY_CURRENT_USER\Software\Classes\*\shell\CopyFilePath\command]
echo @="\"%EXE%\" \"%1\""
echo+
echo [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\CopyFilePath]
echo @="Copy File Path"
echo "Icon"="imageres.dll,-5302"
echo+
echo [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\CopyFilePath\command]
echo @="\"%EXE%\" \"%V\""
echo+
echo [HKEY_CURRENT_USER\Software\Classes\Directory\shell\CopyFilePath]
echo @="Copy File Path"
echo "Icon"="imageres.dll,-5302"
echo+
echo [HKEY_CURRENT_USER\Software\Classes\Directory\shell\CopyFilePath\command]
echo @="\"%EXE%\" \"%1\""
) > "%TMPREG%"

reg import "%TMPREG%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] registry write failed. Run as admin once, or retry under a Chinese path.
    pause
    exit /b 1
)
del "%TMPREG%" >nul 2>&1

echo.
echo ============================================================
echo [Copy File Path] Installed successfully!
echo   Right-click any file / folder / folder blank,
echo   choose "Copy File Path" to copy the absolute path.
echo   Run file: %EXE%
echo ============================================================
echo.
pause
