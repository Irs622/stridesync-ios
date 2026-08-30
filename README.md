# 🏃‍♂️ StrideSync iOS

<div align="center">

[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat-square&logo=swift)](https://swift.org)
[![iOS 17+](https://img.shields.io/badge/iOS-17.0%2B-blue.svg?style=flat-square&logo=apple)](https://apple.com)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF.svg?style=flat-square)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-green.svg?style=flat-square)](https://developer.apple.com/documentation/swiftdata)
[![Cloud Database](https://img.shields.io/badge/Backend-Supabase%20PostgreSQL-3ECF8E.svg?style=flat-square&logo=supabase)](https://supabase.com)
[![Tests](https://img.shields.io/badge/Tests-81%2F81%20Passing%20(100%25)-brightgreen.svg?style=flat-square)]()
[![Zero Cost](https://img.shields.io/badge/Cost-100%25%20Free%20(Rp%200)-success.svg?style=flat-square)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

**A high-performance, modern Strava-like fitness tracking and social networking iOS platform built with Swift 6, SwiftUI, SwiftData, CoreLocation Actors, MapKit, ActivityKit (Dynamic Island), HealthKit, Supabase PostgreSQL, and Garmin FIT 2.0.**

[Tampilan Aplikasi](#-tampilan-antarmuka-aplikasi-visual-showcase) • [Fitur Utama](#-fitur-utama-core-features) • [Arsitektur Cloud & Keamanan](#-arsitektur-cloud--database-gratis-rp-0) • [Panduan Menjalankan Rp 0](#-cara-menjalankan-aplikasi-100-gratis-rp-0) • [Struktur Proyek](#-struktur-direktori-proyek) • [Dokumentasi Lengkap](#-dokumentasi-lengkap)

</div>

---

## 📱 Tampilan Antarmuka Aplikasi (Visual Showcase)

<div align="center">
<table>
  <tr>
    <td align="center" width="33%">
      <img src="assets/screenshots/01_community_feed.png" alt="Community Feed" width="100%" style="border-radius: 14px;" />
      <br />
      <b>📰 1. Community Feed</b>
      <br />
      <sub>Linimasa sosial, filter olahraga & Kudos</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/03_record_hud.png" alt="Record HUD" width="100%" style="border-radius: 14px;" />
      <br />
      <b>⏱️ 2. Pro HUD Recording</b>
      <br />
      <sub>OLED dark theme, live GPS & metrik besar</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/02_explore_maps.png" alt="Explore Maps" width="100%" style="border-radius: 14px;" />
      <br />
      <b>🗺️ 3. Explore & Segmen</b>
      <br />
      <sub>Peta interaktif & rute tanjakan populer</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img src="assets/screenshots/04_challenges.png" alt="Challenges" width="100%" style="border-radius: 14px;" />
      <br />
      <b>🏆 4. Tantangan Bulanan</b>
      <br />
      <sub>Progress bar 100K & piala virtual</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/05_profile.png" alt="Profile & Gear" width="100%" style="border-radius: 14px;" />
      <br />
      <b>👤 5. Profil & Gear Tracker</b>
      <br />
      <sub>Statistik atlet & umur pakai sepatu/sepeda</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/screenshots/06_global_search.png" alt="Global Search" width="100%" style="border-radius: 14px;" />
      <br />
      <b>🔍 6. Pencarian Global</b>
      <br />
      <sub>Pencarian cerdas atlet, aktivitas & klub</sub>
    </td>
  </tr>
</table>
</div>

---

## 🌟 Tentang Proyek (About StrideSync)

**StrideSync** adalah platform pelacak aktivitas atletik luar ruangan (lari, bersepeda, hiking, dan jalan santai) berbasis iOS yang memadukan keandalan **GPS Engine kelas telemetri** dengan **ekosistem sosial komunitas olahraga modern**.

Proyek ini dirancang dari awal dengan prinsip **Local-First, Zero-Cost Resilience, Security-First & Privacy-First Architecture**:
* 💸 **100% Gratis & Bebas Biaya Server (Rp 0):** Berjalan secara *Local-First* menggunakan **SwiftData** dan terhubung ke **Supabase Cloud (PostgreSQL Free Tier)** tanpa perlu biaya server bulanan sepeser pun.
* 🛡️ **Privasi & Enkripsi Atlet Terjamin:** Data lokasi di sekitar rumah disanitasi dengan geofence masking, Row Level Security (RLS) di database cloud, serta token sesi tersimpan aman di **Apple Keychain Security Framework**.
* ⚡️ **Swift 6 Strict Concurrency:** Mengeliminasi seluruh potensi *data race* pada pemrosesan koordinat GPS dengan mengisolasi perhitungan pada `actor LocationEngine`.
* 🎧 **Background Modes & Audio Ducking:** GPS tetap melacak rute di saku celana saat layar terkunci dan suara pelatih (*Audio Cues*) otomatis mengecilkan lagu Spotify / Apple Music.
* ✨ **Onboarding Pengguna Baru:** Alur pembuka 3-langkah modern yang ramah untuk permohonan izin GPS dan Apple Health.
* 📦 **Dual Export Engine:** Ekspor dan impor data rute dalam format **GPX 1.1 XML** dan format biner Garmin **FIT 2.0**.

---

## 🛠️ Tumpukan Teknologi (Tech Stack)

| Kategori | Teknologi / Framework | Deskripsi Penggunaan |
| :--- | :--- | :--- |
| **Language** | **Swift 6.0** | Strict Concurrency Checking (`-swift-version 6`), Actor isolation, Sendable models |
| **UI Framework** | **SwiftUI & MapKit** | Declarative modern UI, `MapPolyline` gradient styling, custom markers, haptics |
| **Persistence** | **SwiftData** | `@Model` relational local-first storage dengan zero memory leakage |
| **Cloud Backend** | **Supabase (PostgreSQL 15+)** | Cloud Database, Row Level Security (RLS), Multi-user Social Feed & Segments |
| **Auth & Security** | **Sign in with Apple & Keychain** | Apple ID 1-tap auth, Email auth & `SecItem` API Keychain encryption |
| **Background Modes**| **CoreLocation & AVFoundation** | `UIBackgroundModes: location, audio` dengan audio ducking Spotify/Apple Music |
| **Live Tracking** | **ActivityKit & WidgetKit** | Dynamic Island, Lock Screen Live Activities & Home Screen widgets |
| **Health Sync** | **HealthKit** | Otorisasi dan sinkronisasi workout native via `HKWorkoutBuilder` |
| **Export Engines**| **GPX 1.1 & Garmin FIT 2.0** | Generator XML GPX 1.1 dan Encoder/Decoder biner Garmin FIT 2.0 |
| **P2P Radar** | **CoreBluetooth (BLE)** | Pemindaian detak jantung, cycling power GATT & direct mesh Buddy Radar |
| **Testing** | **Swift Testing Framework** | **81 Unit Tests** lulus 100% pada 37 Test Suites |

---

## 🚀 Fitur Utama (Core Features)

### 1. 🛰️ Pro-Grade GPS & Telemetry Engine
- **Actor-Isolated Location Tracking (`LocationEngine`)**: Mengisolasi proses penerimaan koordinat GPS pada background actor terpisah untuk mencegah *race condition* dan *main-thread blocking*.
- **GPS Noise & Drift Rejection**: Menolak koordinat dengan akurasi horizontal rendah (`> 25 meter`) dan menyaring anomali lonjakan kecepatan.
- **Smart Auto-Pause & Resume**: Otomatis menjeda perekaman saat atlet berhenti di lampu merah (`speed < 0.8 m/s`) dan melanjutkan kembali saat bergerak.
- **Kilometer Splits Calculator**: Menghitung *pacing split* dan akumulasi elevasi secara presisi per kilometer.

### 2. 🌐 Cloud Database Multi-User & Offline Sync (Supabase)
- **Supabase Cloud REST Client (`CloudAPIService`)**: Linimasa komunitas global, interaksi Kudos/Likes, kolom komentar, dan profil pengguna.
- **Offline-First Sync Engine (`CloudSyncEngine`)**: Lari tanpa sinyal tetap tersimpan rapi di SwiftData dan otomatis diunggah ke cloud saat terkoneksi internet.
- **Row Level Security (RLS)**: Proteksi data tingkat baris di PostgreSQL sehingga atlet lain tidak dapat mengubah data latihan Anda.

### 3. ✨ Layar Onboarding Pengguna Baru (`OnboardingView`)
- Alur pengenalan 3-langkah interaktif dengan permohonan izin hardware GPS dan Apple HealthKit secara transparan.

### 4. 👑 Virtual Segments & KOM/QOM Leaderboard
- **Spatial Segment Matcher**: Algoritma pencocokan polylines rute terhadap segmen virtual jalanan dengan radius toleransi pintu masuk/keluar (*gate radius* 40m).
- **Crown & Personal Record (PR)**: Penentuan gelar **King/Queen of the Mountain (KOM/QOM)** tercepat dan pemecahan rekor pribadi.

### 5. 🎯 Live Audio Pacing Coach & Audio Ducking
- Mengatur target waktu tempuh balapan (*Sub-20m 5K, Sub-50m 10K, Sub-4h Marathon*) dengan evaluasi delta waktu real-time (*ahead/behind status*) dan panduan suara taktis bilingual via `AVSpeechSynthesizer` yang otomatis mengecilkan musik.

### 6. 🧭 GPX Turn-by-Turn Navigation & Vector Steering
- Panduan rute interaktif dari file GPX dengan deteksi sudut belokan (*bearing delta*), estimasi jarak manuver, dan peringatan getar haptik otomatis saat atlet keluar jalur (*cross-track error > 30m*).

### 7. 📊 Training Load (Banister TRIMP) & Recovery Gauge
- Kalkulasi beban fisiologis latihan berbasis formula matematis **Banister TRIMP**, pemodelan kelelahan sesaat (*Acute Load ATL* 7 hari), kebugaran dasar (*Chronic Load CTL* 28 hari), dan estimasi jam pemulihan otot.

### 8. 📶 External Bluetooth BLE Sensors (CoreBluetooth)
- Pemindaian dan pembacaan paket biner standar Bluetooth SIG GATT untuk sensor dada detak jantung (`0x180D`/`0x2A37`) dan sensor daya kayuh sepeda (*Cycling Power* `0x1818`/`0x2A63`).

### 9. ⛰️ Climb Classifier & UCI Grade Analysis
- Deteksi otomatis tanjakan kategori UCI (*Cat 4, 3, 2, 1, dan Hors Catégorie / HC*) dengan perhitungan Climb Score dan Grade Adjusted Pace (GAP).

### 10. 🗺️ Personal Global Heatmap & 3D Flyover Replay
- Representasi jejak petualangan lari seumur hidup dengan pemetaan *Slippy Map Tile* (Zoom 14) serta simulasi kamera satelit 3D flyover.

---

## 💻 Cara Menjalankan Aplikasi (100% Gratis / Rp 0)

### 1. Menjalankan di Simulator (macOS)
```bash
# Clone repositori
git clone https://github.com/Irs622/stridesync-ios.git
cd stridesync-ios

# Jalankan pengujian otomatis (81/81 Passed)
swift test

# Buka proyek di Xcode
open Package.swift
```

### 2. Memasang ke iPhone Fisik Anda Tanpa Biaya ($0)
1. Sambungkan iPhone ke Mac dengan kabel data USB.
2. Pada menu **Signing & Capabilities** di Xcode, pilih **Personal Team (Apple ID gratis)** Anda.
3. Pilih perangkat iPhone Anda di device selector atas, lalu klik **▶️ Play (Run)**.
4. Panduan lengkap: [`docs/FREE_DEPLOYMENT_GUIDE.md`](docs/FREE_DEPLOYMENT_GUIDE.md).

---

## 📁 Struktur Direktori Proyek

```
stridesync-ios/
├── Package.swift                    # Konfigurasi Swift Package Manager (Swift 6)
├── database/
│   └── schema.sql                   # Skema PostgreSQL Cloud + RLS Policies
├── docs/
│   ├── APP_STORE_GUIDE.md           # Panduan Lengkap App Store Review & TestFlight
│   └── FREE_DEPLOYMENT_GUIDE.md     # Panduan Instalasi Fisik Tanpa Bayar (Rp 0)
├── scripts/
│   ├── build_release_ipa.sh         # Skrip build distribusi produksi
│   └── generate_app_store_icon.py   # Generator ikon 1024x1024 px resmi
├── assets/
│   └── AppIcon-1024.png             # Ikon App Store resmi
├── Sources/
│   └── StrideSync/
│       ├── Models/                  # SwiftData Models & Codable DTOs
│       ├── Services/                # GPS Actor, Audio, Ble, Supabase, SyncEngine
│       ├── ViewModels/              # Observable MVVM State Managers
│       └── Views/                   # SwiftUI Screens (HUD, Onboarding, Social, Profile)
└── Tests/
    └── StrideSyncTests/             # 81 Unit Tests across 37 Test Suites (100% PASS)
```

---

## 📚 Dokumentasi Lengkap

* 📋 [Product Requirement Document (PRD.md)](PRD.md)
* 🏛️ [Arsitektur & Deep Dive Teknis (ARCHITECTURE.md)](ARCHITECTURE.md)
* 🛣️ [Peta Jalan Pengembangan (ROADMAP.md)](ROADMAP.md)
* 🔒 [Kebijakan Keamanan & Privasi (SECURITY.md)](SECURITY.md)
* 🤝 [Panduan Kontribusi (CONTRIBUTING.md)](CONTRIBUTING.md)

---

<div align="center">
<sub>Dibangun dengan dedikasi untuk komunitas pelari dan pegiat olahraga Indonesia 🇮🇩</sub>
</div>
