@echo off
chcp 65001 >nul
setlocal
:: ============================================================
:: Copy File Path - One-click installer (no admin required)
:: 1) Copy CopyPath.exe to %APPDATA%\CopyFilePath\
:: 2) Run install.ps1 to write HKCU context menu entries
:: ============================================================

set "APP_DIR=%APPDATA%\CopyFilePath"
set "EXE=%APP_DIR%\CopyPath.exe"
set "SRC=%~dp0CopyPath.exe"

if not exist "%APP_DIR%" mkdir "%APP_DIR%"
copy /Y "%SRC%" "%EXE%" >nul

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set "ERR=%ERRORLEVEL%"

echo.
echo ============================================================
echo [Copy File Path] Installation finished (exit code: %ERR%).
echo   Right-click any file / folder / folder blank area,
echo   choose "Copy File Path" to copy the absolute path.
echo   Run file: %EXE%
echo ============================================================
echo.
pause
