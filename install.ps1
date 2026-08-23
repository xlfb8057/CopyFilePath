# Copy File Path - Installer (PowerShell)
# 1) Copy CopyPath.exe to %APPDATA%\CopyFilePath\
# 2) Write per-folder/per-file context menu entries to HKCU (no admin needed)

$ErrorActionPreference = 'Stop'

$exe = Join-Path $env:APPDATA 'CopyFilePath\CopyPath.exe'

# Make sure the persisted run-file exists; if not, copy from the folder next to this script.
$appDir = Split-Path $exe -Parent
if (-not (Test-Path $appDir)) { New-Item -ItemType Directory -Force -Path $appDir | Out-Null }

$src = Join-Path $PSScriptRoot 'CopyPath.exe'
if (Test-Path $src) {
    Copy-Item -Path $src -Destination $exe -Force
}

if (-not (Test-Path $exe)) {
    Write-Host "[ERROR] CopyPath.exe not found. Please keep CopyPath.exe next to install.bat."
    exit 1
}

$icon = 'imageres.dll,-5302'
$title = 'Copy File Path'

# Three locations: * (file), Directory\Background (folder blank area), Directory (folder)
$locations = @(
    @{
        Menu   = 'HKCU:\Software\Classes\*\shell\CopyFilePath'
        Cmd    = 'HKCU:\Software\Classes\*\shell\CopyFilePath\command'
        Arg    = '"%1"'
    },
    @{
        Menu   = 'HKCU:\Software\Classes\Directory\Background\shell\CopyFilePath'
        Cmd    = 'HKCU:\Software\Classes\Directory\Background\shell\CopyFilePath\command'
        Arg    = '"%V"'
    },
    @{
        Menu   = 'HKCU:\Software\Classes\Directory\shell\CopyFilePath'
        Cmd    = 'HKCU:\Software\Classes\Directory\shell\CopyFilePath\command'
        Arg    = '"%1"'
    }
)

foreach ($loc in $locations) {
    if (-not (Test-Path $loc.Menu)) { New-Item -Path $loc.Menu -Force | Out-Null }
    Set-ItemProperty -Path $loc.Menu -Name '(default)' -Value $title
    Set-ItemProperty -Path $loc.Menu -Name 'Icon'      -Value $icon

    if (-not (Test-Path $loc.Cmd)) { New-Item -Path $loc.Cmd -Force | Out-Null }
    $cmdLine = '"' + $exe + '" ' + $loc.Arg
    Set-ItemProperty -Path $loc.Cmd -Name '(default)' -Value $cmdLine
}

# Refresh Explorer's cached menu (no-op if running elevated)
$signature = @'
[DllImport("user32.dll", SetLastError = true)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, int flags, int timeout, out IntPtr result);
'@
try {
    Add-Type -MemberDefinition $signature -Name 'Win32' -Namespace 'P' -ErrorAction Stop
    [P.Win32]::SendMessageTimeout([IntPtr]0xFFFF, 0x1A, [IntPtr]0, "Shell_TrayWnd", 2, 200, [ref][IntPtr]::Zero) | Out-Null
} catch {}

Write-Host "[Copy File Path] installed."
Write-Host "Run file: $exe"
Write-Host "Right-click any file / folder / folder blank area -> Copy File Path -> paste."
exit 0
