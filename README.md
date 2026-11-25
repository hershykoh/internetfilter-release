# InternetFilter (`v2.1.0`)

Real-time AI modesty & content filter for Chrome with **4 encrypted on-device models** (`MobileCLIP2-S2`, `SigLIP-Base Q8`, `YOLOv11n`, `NudeNet 320n`) and an optional **macOS Apple Silicon Local Accelerator** (`97.4%` Gemini parity across `5,147` real browsing images at `13.6 ms/img`).

- **Content-Only Filtering**: No page is automatically blocked, and no page bypasses AI image & video screening.
- **2 Modes in 1 Click**:
  - **⚡ Fast Local**: 100% on-device (`~3.7 ms/img` with M4 Accelerator, `~8–12 ms/img` standalone WebGPU, `0` cloud calls).
  - **🛡️ Strict Hybrid**: Runs all 4 packed models + optional Gemini verification on borderline cases.

---

## 1. Install the Chrome Extension (Standalone — No Server Required)

1. Download **`internetfilter-chrome-v2.1.0.zip`** from the [Latest Release (`v2.1.0`)](https://github.com/hershykoh/internetfilter-release/releases/latest).
2. Unzip it to a permanent folder (e.g. `~/Applications/InternetFilter-Extension`).
3. Open `chrome://extensions` in Google Chrome.
4. Enable **Developer mode** (top right) → click **Load unpacked** → select the unzipped folder.

The extension works immediately **100% standalone inside Chrome** using WebGPU/WASM with all 4 models packed inside.

---

## 2. Optional: Install the Local Hardware Accelerator (10–15× Faster)

The Chrome extension automatically detects `http://127.0.0.1:11436` when running and falls back seamlessly to in-browser WebGPU/WASM when offline.

### macOS (Apple Silicon — Neural Engine + Metal, `13.6 ms/img`)
```bash
curl -fsSL https://raw.githubusercontent.com/hershykoh/internetfilter-release/main/install.sh | bash
```
Uninstall:
```bash
curl -fsSL https://raw.githubusercontent.com/hershykoh/internetfilter-release/main/uninstall.sh | bash
```

### Windows (Intel / AMD / NVIDIA — DirectML GPU + AVX2/AVX-512, ~45 MB install)
Open **PowerShell** and run:
```powershell
irm https://raw.githubusercontent.com/hershykoh/internetfilter-release/main/install.ps1 | iex
```
Uninstall:
```powershell
irm https://raw.githubusercontent.com/hershykoh/internetfilter-release/main/uninstall.ps1 | iex
```
