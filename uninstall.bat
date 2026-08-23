@echo off
setlocal
:: ============================================================
:: Copy File Path - uninstall (no admin; cleans HKCU install)
:: If you used an old HKLM version, right-click -> Run as admin.
:: ============================================================

reg delete "HKCU\Software\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\*\shell\CopyFilePath_TestZh" /f >nul 2>&1

set "APP_DIR=%APPDATA%\CopyFilePath"
if exist "%APP_DIR%" rd /s /q "%APP_DIR%" >nul 2>&1

echo.
echo [Copy File Path] Uninstalled. Menu entries and run file removed.
echo If Explorer still shows the old menu, sign out or reboot to refresh.
echo.
pause
