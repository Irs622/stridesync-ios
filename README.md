# 🏃‍♂️⚡️ StrideSync iOS

<div align="center">

[![Swift 6](https://img.shields.io/badge/Swift-6.0-FC5200.svg?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Version: v0.5.0-beta](https://img.shields.io/badge/Version-v0.5.0--beta-orange.svg?style=for-the-badge&logo=github)](https://github.com/Irs622/stridesync-ios/releases/tag/v0.5.0-beta)
[![iOS 17+](https://img.shields.io/badge/iOS-17.0%2B-007AFF.svg?style=for-the-badge&logo=apple&logoColor=white)](https://apple.com)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF.svg?style=for-the-badge)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-2ECC71.svg?style=for-the-badge)](https://developer.apple.com/documentation/swiftdata)
[![Live Web Preview](https://img.shields.io/badge/Web_Live-Vercel-000000.svg?style=for-the-badge&logo=vercel&logoColor=white)](https://stridesync-web.vercel.app)
[![Tests](https://img.shields.io/badge/Tests-81%2F81%20Passing%20(100%25)-2ECC71.svg?style=for-the-badge)]()
[![Zero Cost](https://img.shields.io/badge/Cost-100%25%20Free-success.svg?style=for-the-badge)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

**A high-performance, modern athletic intelligence and GPS running platform built with Swift 6, SwiftUI, SwiftData, CoreLocation Actors, MapKit, ActivityKit (Dynamic Island), HealthKit, Supabase PostgreSQL, and Garmin FIT 2.0.**

🌐 **Live Web Preview:** [https://stridesync-web.vercel.app](https://stridesync-web.vercel.app)  
💻 **Web Repository:** [https://github.com/Irs622/stridesync-web](https://github.com/Irs622/stridesync-web)  
📥 **Direct .IPA Download:** [StrideSync.ipa (v0.5.0-beta)](https://stridesync-web.vercel.app/downloads/StrideSync.ipa)  
🏷️ **GitHub Pre-Release:** [v0.5.0-beta Release Notes](https://github.com/Irs622/stridesync-ios/releases/tag/v0.5.0-beta)

[Visual Showcase](#-visual-showcase) • [Core Features](#-core-features) • [Tech Stack](#-tech-stack) • [Setup & Installation](#-getting-started--installation) • [Directory Structure](#-project-directory-structure) • [Documentation](#-documentation-index)

</div>

---

## 📱 Visual Showcase

<div align="center">
<table>
  <tr>
    <td align="center" width="33%">
      <img src="assets/screenshots/01_community_feed.png" alt="Community Feed" width="100%" style="border-radius: 14px;" />
      <br />
      <b>📰 1. Community Feed</b>
      <br />
      <sub>Social timeline, sport filters & Kudos</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/03_record_hud.png" alt="Record HUD" width="100%" style="border-radius: 14px;" />
      <br />
      <b>⏱️ 2. Pro HUD Recording</b>
      <br />
      <sub>OLED dark theme, live GPS & bold metrics</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/02_explore_maps.png" alt="Explore Maps" width="100%" style="border-radius: 14px;" />
      <br />
      <b>🗺️ 3. Explore & Segments</b>
      <br />
      <sub>Interactive map & popular climb routes</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img src="assets/screenshots/04_challenges.png" alt="Challenges" width="100%" style="border-radius: 14px;" />
      <br />
      <b>🏆 4. Monthly Challenges</b>
      <br />
      <sub>100K progress bar & virtual trophies</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/05_profile.png" alt="Profile & Gear" width="100%" style="border-radius: 14px;" />
      <br />
      <b>👤 5. Profile & Gear Tracker</b>
      <br />
      <sub>Athlete statistics & shoe/bike mileage</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/06_global_search.png" alt="Global Search" width="100%" style="border-radius: 14px;" />
      <br />
      <b>🔍 6. Global Search</b>
      <br />
      <sub>Smart search for athletes, workouts & clubs</sub>
    </td>
  </tr>
</table>
</div>

---

## 🌟 About StrideSync

**StrideSync** is an outdoor endurance athletic tracking platform (running, cycling, hiking, and walking) for iOS that combines telemetry-grade **GPS Engine reliability** with a **modern community social ecosystem**.

Engineered from the ground up on **Local-First, Zero-Cost Resilience, Security-First, and Privacy-First Architecture**:
* 💸 **100% Free & Zero Server Overhead:** Operates *Local-First* using **SwiftData** and seamlessly connects to **Supabase Cloud (PostgreSQL Free Tier)** with zero recurring server costs.
* 🛡️ **Guaranteed Athlete Privacy & Encryption:** Sensitive location data near home/office is sanitized via geofence masking, Row Level Security (RLS) on cloud database, and session tokens stored securely in **Apple Keychain Security Framework**.
* ⚡️ **Swift 6 Strict Concurrency:** Eliminates data races during high-frequency GPS coordinate calculations by isolating state on `actor LocationEngine`.
* 🎧 **Background Modes & Audio Ducking:** Tracks GPS routes accurately in your pocket when locked, automatically ducking Spotify / Apple Music audio during tactical coach voice cues.
* 🎨 **Native App Icon & Asset Catalog:** Includes official 1024x1024 px app icon asset package located in `Resources/Assets.xcassets/AppIcon.appiconset`.
* 📦 **Dual Export Engine:** Import and export workout routes in **GPX 1.1 XML** format and binary Garmin **FIT 2.0** protocol.

---

## 🛠️ Tech Stack

| Category | Technology / Framework | Description & Usage |
| :--- | :--- | :--- |
| **Language** | **Swift 6.0** | Strict Concurrency Checking (`-swift-version 6`), Actor isolation, Sendable models |
| **UI Framework** | **SwiftUI & MapKit** | Declarative UI, `MapPolyline` gradient styling, custom markers, haptic feedback |
| **Persistence** | **SwiftData** | `@Model` relational local-first storage with zero memory leakage |
| **Project Setup** | **StrideSync.xcodeproj** | Native iOS target with bundle ID `irsalteam.stridesync` & shared scheme |
| **Cloud Backend** | **Supabase (PostgreSQL 15+)** | Cloud Database, Row Level Security (RLS), Multi-user Social Feed & Segments |
| **Auth & Security** | **Sign in with Apple & Keychain** | Apple ID 1-tap authentication, Email auth & `SecItem` API Keychain encryption |
| **Background Modes**| **CoreLocation & AVFoundation** | `UIBackgroundModes: location, audio` with Spotify / Apple Music audio ducking |
| **Live Tracking** | **ActivityKit & WidgetKit** | Dynamic Island, Lock Screen Live Activities & Home Screen widgets |
| **Health Sync** | **HealthKit** | Native authorization & workout synchronization via `HKWorkoutBuilder` |
| **Export Engines**| **GPX 1.1 & Garmin FIT 2.0** | GPX 1.1 XML generator & Garmin FIT 2.0 binary encoder/decoder |
| **P2P Radar** | **CoreBluetooth (BLE)** | Bluetooth GATT heart rate chest straps, cycling power meters & Buddy Radar |
| **Testing** | **Swift Testing Framework** | **81 Unit Tests** 100% passing across 37 Test Suites |

---

## 🚀 Core Features

### 1. 🛰️ Pro-Grade GPS & Telemetry Engine
- **Actor-Isolated Location Tracking (`LocationEngine`)**: Isolates GPS coordinate processing on a dedicated background actor to eliminate race conditions and main-thread blocking.
- **GPS Noise & Drift Rejection**: Filters out low horizontal accuracy coordinates (`> 25 meters`) and rejects velocity anomaly spikes.
- **Smart Auto-Pause & Resume**: Automatically pauses recording when stopping at traffic lights (`speed < 0.8 m/s`) and resumes when moving.
- **Kilometer Splits Calculator**: Computes precise pacing splits and elevation gains per kilometer.

### 2. 👻 Virtual Ghost Runner
- Compete against your personal record (PR) shadow or target pace with real-time distance delta (+/- meters) displayed on screen.

### 3. ⛰️ Climb Classifier & UCI Grade Analysis
- Automatic climb category detection adhering to UCI / Strava standards (*Cat 4, 3, 2, 1, and Hors Catégorie / HC*) with Climb Score and Grade Adjusted Pace (GAP).

### 4. 🫁 VO2 Max & Race Predictor
- Aerobic capacity VO2 Max estimation and race completion predictor for **5K, 10K, Half Marathon (21.1 km), and Full Marathon (42.2 km)** based on *Jack Daniels VDOT* and *Riegel* physiological models.

### 5. 📊 Training Load (Banister TRIMP) & Recovery Gauge
- Physiological training load calculation using **Banister TRIMP** mathematical formula, fatigue modeling (*Acute Load ATL* 7 days), fitness modeling (*Chronic Load CTL* 28 days), and muscle recovery hours.

### 6. 👑 Virtual Segments & KOM/QOM Leaderboard
- **Spatial Segment Matcher**: Polyline route matching algorithm against street segments with a 40m gate tolerance radius.
- **Crown & Personal Record (PR)**: Automatic **King/Queen of the Mountain (KOM/QOM)** title detection and personal record tracking.

### 7. 🎯 Live Audio Pacing Coach & Audio Ducking
- Set target race finish times (*Sub-20m 5K, Sub-50m 10K, Sub-4h Marathon*) with real-time time delta evaluation and tactical voice announcements via `AVSpeechSynthesizer`.

### 8. 📶 External Bluetooth BLE Sensors (CoreBluetooth)
- Scan and decode standard Bluetooth SIG GATT binary packets for heart rate chest straps (`0x180D`/`0x2A37`) and cycling power meters (`0x1818`/`0x2A63`).

### 9. 📡 Live Group Run Radar & Safety Beacon
- Scan nearby community runners within a 1.5 km radius anonymously, hard fall detection system (*Fall Detection G > 3.5g*), and emergency live tracking beacon links.

### 10. 🚁 3D Aerial Flyover Replay & AI Workout Story
- 3D helicopter satellite replay of recorded routes with a 60° pitch camera angle and AI-generated motivational summaries.

---

## 💻 Getting Started & Installation

### Option 1: Open in Xcode (macOS)
```bash
# 1. Clone repository
git clone https://github.com/Irs622/stridesync-ios.git
cd stridesync-ios

# 2. Open native Xcode project
open StrideSync.xcodeproj
```

### Option 2: Run via Terminal
```bash
# Build for iOS Simulator or Physical Device
xcodebuild build -project StrideSync.xcodeproj -scheme StrideSync -destination 'generic/platform=iOS'
```

### Option 3: Install to Physical iPhone (100% Free / Zero Cost)
1. Connect your iPhone to Mac via USB cable.
2. In Xcode: Select target **StrideSync** → **Signing & Capabilities** tab.
3. Select your **Personal Team (Free Apple ID)** (`PU23ZB2X47`).
4. Select your connected iPhone at the top device selector, then click **▶️ Play (Run)**.
5. On your iPhone: Open **Settings** → **General** → **VPN & Device Management** → tap **Trust Developer**.

### Option 4: Download Direct .IPA File (Sideloading)
Download [StrideSync.ipa (v0.5.0-beta)](https://stridesync-web.vercel.app/downloads/StrideSync.ipa) and install using **AltStore**, **Sideloadly**, **TrollStore**, or **Scarlet**.

---

## 📁 Project Directory Structure

```text
stridesync-ios/
├── StrideSync.xcodeproj/            # Native Xcode Project Configuration (iOS App)
│   ├── project.pbxproj              # Targets, Build Settings, & Permissions
│   └── xcshareddata/xcschemes/      # StrideSync Shared Schemes
├── Package.swift                    # Swift Package Manager Manifest (Swift 6)
├── Resources/
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/      # Official iOS App Icon Asset Pack (1024x1024)
├── Sources/
│   └── StrideSync/
│       ├── AppMain.swift            # SwiftUI App Entrypoint (@main)
│       ├── Models/                  # SwiftData Models & Codable DTOs
│       ├── Services/                # GPS Actor, Audio, BLE, Supabase, SyncEngine
│       ├── ViewModels/              # Observable MVVM State Managers
│       └── Views/                   # SwiftUI Screens (HUD, Onboarding, Social, Profile)
├── database/
│   └── schema.sql                   # Supabase PostgreSQL Cloud Schema + RLS Policies
├── docs/
│   ├── APP_STORE_GUIDE.md           # App Store Review & TestFlight Deployment Guide
│   └── FREE_DEPLOYMENT_GUIDE.md     # Zero-Cost Physical iPhone Installation Guide
└── Tests/
    └── StrideSyncTests/             # 81 Unit Tests across 37 Test Suites (100% PASS)
```

---

## 📄 License & Credits

- **Developer**: [Irsal Shydiq](https://github.com/Irs622)
- **Web App**: [https://stridesync-web.vercel.app](https://stridesync-web.vercel.app)
- **Web Repository**: [https://github.com/Irs622/stridesync-web](https://github.com/Irs622/stridesync-web)
- Built with dedication for runners and athletic endurance communities 🏃‍♂️⚡️

Distributed under the official **[MIT License](LICENSE)**.
