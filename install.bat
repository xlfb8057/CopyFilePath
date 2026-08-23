@echo off
setlocal
:: ============================================================
::  Copy File Path —— 一键安装（无需管理员）
::  1) 把 CopyPath.exe 复制到 %APPDATA%\CopyFilePath\（长期运行文件）
::  2) 向 HKCU 写入右键菜单（文件 / 文件夹 / 文件夹空白处）
:: ============================================================
set "APP_DIR=%APPDATA%\CopyFilePath"
set "EXE=%APP_DIR%\CopyPath.exe"
set "SRC=%~dp0CopyPath.exe"

if not exist "%APP_DIR%" mkdir "%APP_DIR%"
copy /Y "%SRC%" "%EXE%" >nul

:: 用 PowerShell 生成 UTF-16 LE 临时 .reg 并导入（避开 cmd 引号地狱）
set "PS1=%TEMP%\cfp_install.ps1"
set "REG=%TEMP%\cfp_install.reg"
(
echo $exe = '%EXE%'
echo $esc = $exe.Replace('\', '\\')
echo $nl  = [Environment]::NewLine
echo $reg = 'Windows Registry Editor Version 5.00' + $nl + $nl + ^
'[HKEY_CURRENT_USER\Software\Classes\*\shell\CopyFilePath]' + $nl + ^
'@="Copy File Path"' + $nl + ^
'"Icon"="imageres.dll,-5302"' + $nl + $nl + ^
'[HKEY_CURRENT_USER\Software\Classes\*\shell\CopyFilePath\command]' + $nl + ^
'@="' + $esc + '" "%%1"' + $nl + $nl + ^
'[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\CopyFilePath]' + $nl + ^
'@="Copy File Path"' + $nl + ^
'"Icon"="imageres.dll,-5302"' + $nl + $nl + ^
'[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\CopyFilePath\command]' + $nl + ^
'@="' + $esc + '" "%%V"' + $nl + $nl + ^
'[HKEY_CURRENT_USER\Software\Classes\Directory\shell\CopyFilePath]' + $nl + ^
'@="Copy File Path"' + $nl + ^
'"Icon"="imageres.dll,-5302"' + $nl + $nl + ^
'[HKEY_CURRENT_USER\Software\Classes\Directory\shell\CopyFilePath\command]' + $nl + ^
'@="' + $esc + '" "%%1"' + $nl
echo [System.IO.File]::WriteAllText('%REG%', $reg, [System.Text.Encoding]::Unicode)
) > "%PS1%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
regedit /s "%REG%"
del "%PS1%" "%REG%" >nul 2>&1

echo.
echo [Copy File Path] 安装完成。
echo 现在在资源管理器里右键 文件 / 文件夹 / 文件夹空白处，
echo 选择 "Copy File Path" 即可把绝对路径复制到剪贴板。
echo （运行文件已复制到：%EXE%）
echo.
pause
