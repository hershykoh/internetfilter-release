# InternetFilter (`v2.3.0`)

Real-time AI modesty & content filter for Chrome with **5 encrypted on-device models** (`MobileCLIP2-S0 128×128 FastGate`, `MobileCLIP2-S2`, `SigLIP-Base Q8`, `YOLOv11n`, `NudeNet 320n`), **zero-Base64 direct binary fetch**, **WebGPU Batch-4 micro-batching**, **zero-GC tensor pooling**, and **persistent IndexedDB perceptual-hash caching**, plus optional local hardware accelerators.

- **Content-Only Filtering**: No page is automatically blocked, and no page bypasses AI image & video screening.
- **2 Modes in 1 Click**:
  - **⚡ Fast Local**: 100% on-device (`~3.7 ms/img` with M4 Accelerator, ultra-fast batched WebGPU standalone, `0` cloud calls).
  - **🛡️ Strict Hybrid**: Runs all packed models + optional Gemini verification on borderline cases.

---

## 1. Install the Chrome Extension (Standalone — No Server Required)

1. Download **`internetfilter-chrome-v2.3.0.zip`** from the [Latest Release (`v2.3.0`)](https://github.com/hershykoh/internetfilter-release/releases/latest).
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
