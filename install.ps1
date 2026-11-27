$ErrorActionPreference = "Stop"

$Repo = "hershykoh/internetfilter-release"
$Version = "v2.4.2"
$AssetName = "windows-accelerator-$Version.zip"
$DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$AssetName"
$InstallDir = Join-Path $env:USERPROFILE ".internetfilter-accelerator"
$Port = if ($env:IFILTER_PORT) { $env:IFILTER_PORT } else { "11436" }
$Device = if ($env:IFILTER_DEVICE) { $env:IFILTER_DEVICE } else { "auto" }
$StartupVbs = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\InternetFilterAccelerator.vbs"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  InternetFilter Safe Windows Accelerator Installer ($Version)" -ForegroundColor Cyan
Write-Host "  (OpenVINO Intel GPU + GPU SigLIP Gate | Single-Thread Safe)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Locate Python 3.10-3.12 (fallback to any Python 3)
$PyCmd = $null
$PyArgs = @()
foreach ($cand in @(@("py", "-3.12"), @("py", "-3.11"), @("py", "-3.10"), @("py", "-3"), @("python", ""), @("python3", ""))) {
    try {
        $exe = $cand[0]
        $arg = $cand[1]
        $ver = if ($arg) { & $exe $arg --version 2>&1 } else { & $exe --version 2>&1 }
        if ($LASTEXITCODE -eq 0 -and $ver -match "Python 3\.") {
            $PyCmd = $exe
            if ($arg) { $PyArgs = @($arg) }
            Write-Host "[1/5] Using $ver ($exe $arg)"
            break
        }
    } catch {}
}

if (-not $PyCmd) {
    Write-Host "Python 3 not found. Installing Python 3.12 via winget..." -ForegroundColor Yellow
    winget install --id Python.Python.3.12 -e --source winget --accept-package-agreements --accept-source-agreements
    Write-Host "Python 3.12 installed! Please open a NEW PowerShell window and re-run this installer." -ForegroundColor Green
    exit 0
}

# Stop any previously running accelerator on this port
Get-CimInstance Win32_Process -Filter "Name like 'python%.exe'" |
    Where-Object { $_.CommandLine -like "*\.internetfilter-accelerator*server.py*" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# 2. Download & extract encrypted accelerator bundle
Write-Host "[2/5] Downloading $AssetName..."
$TmpZip = Join-Path $env:TEMP "ifilter-win-$Version.zip"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $TmpZip -UseBasicParsing
Expand-Archive -Path $TmpZip -DestinationPath $InstallDir -Force
Remove-Item -Force $TmpZip -ErrorAction SilentlyContinue

# 3. Create isolated venv & install lightweight ONNX Runtime DirectML (~45 MB, no PyTorch!)
$VenvDir = Join-Path $InstallDir ".venv"
$VenvPy = Join-Path $VenvDir "Scripts\python.exe"
$VenvPyw = Join-Path $VenvDir "Scripts\pythonw.exe"
$VenvPip = Join-Path $VenvDir "Scripts\pip.exe"

Write-Host "[3/5] Setting up isolated Python environment in $VenvDir..."
if (-not (Test-Path $VenvPy)) {
    & $PyCmd @PyArgs -m venv $VenvDir
}
& $VenvPy -m pip install --upgrade -q pip
& $VenvPip install -q -r (Join-Path $InstallDir "requirements.txt")

# 4. Install silent Startup launcher (no console window) and start now
Write-Host "[4/5] Installing Windows auto-start background service on http://127.0.0.1:$Port (device=$Device)..."
$ServerPy = Join-Path $InstallDir "server.py"
$RunnerExe = if (Test-Path $VenvPyw) { $VenvPyw } else { $VenvPy }
$VbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "$InstallDir"
WshShell.Run """$RunnerExe"" -I ""$ServerPy"" --port $Port --device $Device", 0, False
"@
Set-Content -Path $StartupVbs -Value $VbsContent -Encoding ASCII

Start-Process -FilePath $RunnerExe -ArgumentList "-I `"$ServerPy`" --port $Port --device $Device" -WorkingDirectory $InstallDir -WindowStyle Hidden

# 5. Verify /health (first run compiles & caches OpenVINO GPU kernels into ov_cache/)
Write-Host "[5/5] Waiting for accelerator to warm up (first launch caches GPU kernels)..."
for ($i = 0; $i -lt 180; $i++) {
    try {
        $resp = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/health" -TimeoutSec 2
        Write-Host ""
        Write-Host "OK! InternetFilter Safe Windows Accelerator is running on http://127.0.0.1:$Port" -ForegroundColor Green
        Write-Host ($resp | ConvertTo-Json -Compress)
        Write-Host "Your Chrome extension will automatically accelerate with it (zero config needed)." -ForegroundColor Cyan
        exit 0
    } catch {
        Start-Sleep -Milliseconds 500
    }
}

Write-Host "Warning: Accelerator started but /health did not respond within 90s." -ForegroundColor Yellow
Write-Host "Check logs in: $InstallDir\accelerator.log"
exit 1
