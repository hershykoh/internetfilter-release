# InternetFilter (`v2.0.0`)

Real-time AI modesty & content filter for Chrome with **4 packed on-device models** (`MobileCLIP2-S2`, `SigLIP-Base Q8`, `YOLOv11n`, `NudeNet 320n`) and an optional **macOS Apple Silicon Local Accelerator** (`3.7 ms/img` on Apple Neural Engine).

- **Content-Only Filtering**: No page is automatically blocked, and no page bypasses AI image & video screening.
- **2 Modes in 1 Click**:
  - **⚡ Fast Local**: 100% on-device (`~3.7 ms/img` with M4 Accelerator, `~8–12 ms/img` standalone WebGPU, `0` cloud calls).
  - **🛡️ Strict Hybrid**: Runs all 4 packed models + optional Gemini verification on borderline cases.

---

## 1. Install the Chrome Extension (Standalone — No Server Required)

1. Download **`internetfilter-chrome-v2.0.0.zip`** from the [Latest Release (`v2.0.0`)](https://github.com/hershykoh/internetfilter-release/releases/latest).
2. Unzip it to a permanent folder (e.g. `~/Applications/InternetFilter-Extension`).
3. Open `chrome://extensions` in Google Chrome.
4. Enable **Developer mode** (top right) → click **Load unpacked** → select the unzipped folder.

The extension works immediately **100% standalone inside Chrome** using WebGPU/WASM with all 4 models packed inside.

---

## 2. Optional: Install the Local Apple Silicon Accelerator (3.7 ms/img)

For **3–4× faster** filtering on Apple Silicon Macs (M1/M2/M3/M4) using the Apple Neural Engine + Metal GPU, run:

```bash
curl -fsSL https://raw.githubusercontent.com/hershykoh/internetfilter-release/main/install.sh | bash
```

What this installer does:
- Downloads the pre-compiled Apple Neural Engine & Metal models (`m4-accelerator-v2.0.0.tar.gz`) into `~/.internetfilter-accelerator`.
- Creates an isolated Python virtual environment inside `~/.internetfilter-accelerator/.venv`.
- Installs a macOS LaunchAgent (`com.internetfilter.accelerator`) that runs silently on `http://127.0.0.1:11436` and auto-starts on login.
- The Chrome extension automatically detects `http://127.0.0.1:11436` and switches to Neural Engine acceleration (and falls back seamlessly to in-browser WebGPU if stopped).

### Uninstall Local Accelerator

```bash
curl -fsSL https://raw.githubusercontent.com/hershykoh/internetfilter-release/main/uninstall.sh | bash
```
