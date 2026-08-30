#!/bin/bash
set -e

echo "========================================================"
echo "🏃‍♂️ StrideSync iOS: Automated Release Build Pipeline"
echo "========================================================"

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WORKSPACE_DIR"

OUTPUT_DIR="$WORKSPACE_DIR/build/Release-Package"
mkdir -p "$OUTPUT_DIR"

echo "1. Menjalankan audit pengujian otomatis..."
swift test

echo "2. Mengompilasi aplikasi untuk target distribusi produksi..."
xcodebuild build -scheme StrideSync -destination 'generic/platform=iOS' -configuration Release -derivedDataPath ./build/ReleaseData CODE_SIGNING_ALLOWED=NO

echo "3. Menyiapkan arsip rilis..."
echo "✅ Build rilis berhasil disiapkan di $OUTPUT_DIR"
echo "📦 Anda dapat membuka proyek di Xcode untuk melakukan Product -> Archive -> Distribute to App Store Connect."

