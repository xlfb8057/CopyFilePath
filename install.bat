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

reg add "HKCU\Software\Classes\*\shell\CopyFilePath" /ve /t REG_SZ /d "Copy File Path" /f >nul
reg add "HKCU\Software\Classes\*\shell\CopyFilePath" /v Icon /t REG_SZ /d "imageres.dll,-5302" /f >nul
reg add "HKCU\Software\Classes\*\shell\CopyFilePath\command" /ve /t REG_SZ /d "\"%EXE%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /ve /t REG_SZ /d "Copy File Path" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /v Icon /t REG_SZ /d "imageres.dll,-5302" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath\command" /ve /t REG_SZ /d "\"%EXE%\" \"%%V\"" /f >nul

reg add "HKCU\Software\Classes\Directory\shell\CopyFilePath" /ve /t REG_SZ /d "Copy File Path" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\CopyFilePath" /v Icon /t REG_SZ /d "imageres.dll,-5302" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\CopyFilePath\command" /ve /t REG_SZ /d "\"%EXE%\" \"%%1\"" /f >nul

echo.
echo [Copy File Path] 安装完成。
echo 现在在资源管理器里右键 文件 / 文件夹 / 文件夹空白处，
echo 选择 "Copy File Path" 即可把绝对路径复制到剪贴板。
echo （运行文件已复制到：%EXE%）
echo.
pause
