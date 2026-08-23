@echo off
chcp 65001 >nul
setlocal
:: ============================================================
:: Copy File Path - Uninstaller (will request admin when needed)
:: 1) Elevate to clean up possible legacy HKLM entries
:: 2) Delete HKCU / HKLM / WOW6432Node context menu keys
:: 3) Delete persisted run file in %APPDATA%\CopyFilePath
:: 4) Restart Explorer to refresh context menu cache
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator permission for complete uninstall...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Current install (HKCU, can also be deleted by user)
reg delete "HKCU\Software\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1

:: Legacy HKLM entries (admin required, silent fail is fine)
reg delete "HKLM\Software\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1

:: Delete persisted run file
set "APP_DIR=%APPDATA%\CopyFilePath"
if exist "%APP_DIR%" (
    taskkill /f /im explorer.exe >nul 2>&1
    timeout /t 1 >nul
    rd /s /q "%APP_DIR%" >nul 2>&1
    start explorer.exe >nul 2>&1
)

echo.
echo [Copy File Path] Uninstalled. Context menu entries and run file removed.
echo If Explorer still shows the old menu, log off or restart to refresh.
echo.
pause
