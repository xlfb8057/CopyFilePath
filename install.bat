@echo off
setlocal
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

:: write registry entries directly to avoid .reg quoting issues
reg add "HKCU\Software\Classes\*\shell\CopyFilePath" /ve /d "Copy File Path" /f >nul 2>&1
if errorlevel 1 goto :reg_error
reg add "HKCU\Software\Classes\*\shell\CopyFilePath" /v "Icon" /d "imageres.dll,-5302" /f >nul 2>&1
if errorlevel 1 goto :reg_error
reg add "HKCU\Software\Classes\*\shell\CopyFilePath\command" /ve /d "\"%EXE%\" \"%%1\"" /f >nul 2>&1
if errorlevel 1 goto :reg_error

reg add "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /ve /d "Copy File Path" /f >nul 2>&1
if errorlevel 1 goto :reg_error
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath" /v "Icon" /d "imageres.dll,-5302" /f >nul 2>&1
if errorlevel 1 goto :reg_error
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyFilePath\command" /ve /d "\"%EXE%\" \"%%V\"" /f >nul 2>&1
if errorlevel 1 goto :reg_error

reg add "HKCU\Software\Classes\Directory\shell\CopyFilePath" /ve /d "Copy File Path" /f >nul 2>&1
if errorlevel 1 goto :reg_error
reg add "HKCU\Software\Classes\Directory\shell\CopyFilePath" /v "Icon" /d "imageres.dll,-5302" /f >nul 2>&1
if errorlevel 1 goto :reg_error
reg add "HKCU\Software\Classes\Directory\shell\CopyFilePath\command" /ve /d "\"%EXE%\" \"%%1\"" /f >nul 2>&1
if errorlevel 1 goto :reg_error

goto :install_ok

:reg_error
    echo [ERROR] registry write failed. Run as admin once, or retry under a Chinese path.
    pause
    exit /b 1

:install_ok

echo.
echo ============================================================
echo [Copy File Path] Installed successfully!
echo   Right-click any file / folder / folder blank,
echo   choose "Copy File Path" to copy the absolute path.
echo   Run file: %EXE%
echo ============================================================
echo.
pause
