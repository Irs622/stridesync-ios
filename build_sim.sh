#!/bin/bash
set -e

SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
APP_DIR="build/StrideSync.app"

rm -rf build
mkdir -p "$APP_DIR"

SWIFT_FILES=$(find Sources/StrideSync -name "*.swift")

echo "Compiling StrideSync for iOS Simulator (arm64)..."
swiftc \
    -target arm64-apple-ios18.0-simulator \
    -sdk "$SDK_PATH" \
    -module-name StrideSync \
    -swift-version 6 \
    -parse-as-library \
    -wmo \
    -Onone \
    -o "$APP_DIR/StrideSync" \
    $SWIFT_FILES

cat << 'EOF' > "$APP_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>StrideSync</string>
    <key>CFBundleIdentifier</key>
    <string>com.stridesync.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>StrideSync</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>StrideSync membutuhkan akses lokasi untuk melacak rute dan kecepatan lari Anda.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>StrideSync membutuhkan akses lokasi background untuk merekam aktivitas saat layar terkunci.</string>
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>audio</string>
    </array>
</dict>
</plist>
EOF

echo "Installing StrideSync.app to iOS Simulator..."
xcrun simctl install booted "$APP_DIR"

echo "Launching StrideSync on iOS Simulator..."
xcrun simctl launch booted com.stridesync.app

echo "SUCCESS: StrideSync is now running on the iOS Simulator!"

