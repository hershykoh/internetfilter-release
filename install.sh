#!/usr/bin/env bash
set -euo pipefail

REPO="hershykoh/internetfilter-release"
VERSION="v2.0.0"
ASSET_NAME="m4-accelerator-${VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET_NAME}"
INSTALL_DIR="${HOME}/.internetfilter-accelerator"
PLIST_PATH="${HOME}/Library/LaunchAgents/com.internetfilter.accelerator.plist"
PORT="${IFILTER_PORT:-11436}"

echo "============================================================"
echo "  InternetFilter Local Accelerator Installer (${VERSION})"
echo "============================================================"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: This local Neural Engine accelerator is for macOS (Apple Silicon)."
  echo "On Windows/Linux, the Chrome extension runs standalone via WebGPU/WASM."
  exit 1
fi

# Find Python 3.10–3.12 (preferred for coremltools + torch)
PYTHON_BIN=""
for cand in python3.12 python3.11 python3.10 /opt/homebrew/bin/python3.12 /opt/homebrew/bin/python3.11 /opt/homebrew/bin/python3 python3; do
  if command -v "$cand" >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v "$cand")"
    break
  fi
done

if [[ -z "$PYTHON_BIN" ]]; then
  echo "Error: Python 3 not found. Install it with: brew install python@3.12"
  exit 1
fi

echo "[1/5] Using Python: $($PYTHON_BIN --version) (${PYTHON_BIN})"
mkdir -p "${INSTALL_DIR}"

echo "[2/5] Downloading pre-compiled Apple Neural Engine & Metal models (${ASSET_NAME})..."
TMP_TAR="$(mktemp /tmp/ifilter-accel.XXXXXX.tar.gz)"
trap 'rm -f "${TMP_TAR}"' EXIT
curl -fL --progress-bar "${DOWNLOAD_URL}" -o "${TMP_TAR}"
tar -xzf "${TMP_TAR}" -C "${INSTALL_DIR}"

echo "[3/5] Setting up isolated Python environment in ${INSTALL_DIR}/.venv..."
if [[ ! -d "${INSTALL_DIR}/.venv" ]]; then
  "${PYTHON_BIN}" -m venv "${INSTALL_DIR}/.venv"
fi
"${INSTALL_DIR}/.venv/bin/pip" install --upgrade -q pip
"${INSTALL_DIR}/.venv/bin/pip" install -q -r "${INSTALL_DIR}/requirements.txt"

echo "[4/5] Installing macOS auto-start LaunchAgent on http://127.0.0.1:${PORT}..."
mkdir -p "${HOME}/Library/LaunchAgents"
launchctl bootout "gui/$(id -u)" "${PLIST_PATH}" 2>/dev/null || true

cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.internetfilter.accelerator</string>
  <key>ProgramArguments</key>
  <array>
    <string>${INSTALL_DIR}/.venv/bin/python</string>
    <string>${INSTALL_DIR}/server.py</string>
    <string>--port</string>
    <string>${PORT}</string>
  </array>
  <key>WorkingDirectory</key>
  <string>${INSTALL_DIR}</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${INSTALL_DIR}/accelerator.log</string>
  <key>StandardErrorPath</key>
  <string>${INSTALL_DIR}/accelerator.log</string>
</dict>
</plist>
EOF

launchctl bootstrap "gui/$(id -u)" "${PLIST_PATH}"

echo "[5/5] Waiting for accelerator to warm up..."
for i in $(seq 1 40); do
  if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
    echo ""
    echo "✓ InternetFilter Local Accelerator is running on http://127.0.0.1:${PORT}"
    curl -fsS "http://127.0.0.1:${PORT}/health"
    echo ""
    echo "Your Chrome extension will automatically use it (~3.7 ms/img)."
    exit 0
  fi
  sleep 0.5
done

echo "Warning: Service started but /health did not respond within 20s."
echo "Check logs: tail -n 40 ${INSTALL_DIR}/accelerator.log"
exit 1
