#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/.internetfilter-accelerator"
PLIST_PATH="${HOME}/Library/LaunchAgents/com.internetfilter.accelerator.plist"

echo "Stopping InternetFilter Local Accelerator..."
launchctl bootout "gui/$(id -u)" "${PLIST_PATH}" 2>/dev/null || true
rm -f "${PLIST_PATH}"
rm -rf "${INSTALL_DIR}"
echo "✓ Uninstalled. Chrome extension will continue running standalone via WebGPU/WASM."
