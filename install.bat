@echo off
setlocal
:: ============================================================
::  Copy File Path —— 一键安装（无需管理员）
::  1) 复制 CopyPath.exe 到 %APPDATA%\CopyFilePath\
::  2) 调用 install.ps1 写入 HKCU 右键菜单
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
