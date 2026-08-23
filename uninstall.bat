@echo off
setlocal
:: ============================================================
::  Copy File Path —— 卸载（会请求管理员权限）
::  1) 自提权（清理可能残留的 HKLM 旧项需要管理员）
::  2) 删除注册表右键菜单（HKCU 本机安装 + HKLM/32位 旧版残留）
::  3) 删除持久化的运行文件 %APPDATA%\CopyFilePath
::  4) 重启资源管理器，刷新右键菜单
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
  echo 正在请求管理员权限以彻底卸载...
  powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

:: 本机安装（HKCU，普通用户也可删）
reg delete "HKCU\Software\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1

:: 旧版可能残留的 HKLM 项（需管理员，静默失败不影响）
reg delete "HKLM\Software\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Classes\*\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Classes\Directory\Background\shell\CopyFilePath" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Classes\Directory\shell\CopyFilePath" /f >nul 2>&1

:: 删除持久化运行文件
set "APP_DIR=%APPDATA%\CopyFilePath"
if exist "%APP_DIR%" (
  taskkill /f /im explorer.exe >nul 2>&1
  timeout /t 1 >nul
  rd /s /q "%APP_DIR%" >nul 2>&1
  start explorer.exe >nul 2>&1
)

echo.
echo [Copy File Path] 已卸载，右键菜单项与运行文件均已移除。
echo 如资源管理器仍显示旧菜单，请注销或重启电脑刷新。
echo.
pause
