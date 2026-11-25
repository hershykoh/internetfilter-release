$ErrorActionPreference = "SilentlyContinue"

$InstallDir = Join-Path $env:USERPROFILE ".internetfilter-accelerator"
$StartupVbs = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\InternetFilterAccelerator.vbs"

Write-Host "Stopping InternetFilter Windows Accelerator..."
Get-CimInstance Win32_Process -Filter "Name like 'python%.exe'" |
    Where-Object { $_.CommandLine -like "*\.internetfilter-accelerator*server.py*" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

Remove-Item -Force $StartupVbs
Remove-Item -Recurse -Force $InstallDir
Write-Host "Uninstalled. Chrome extension will continue running standalone via WebGPU/WASM." -ForegroundColor Green
