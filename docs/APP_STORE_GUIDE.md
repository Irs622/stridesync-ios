# 🍎 Panduan Lengkap Publikasi App Store & TestFlight (StrideSync iOS)

Dokumen ini adalah panduan resmi langkah-demi-langkah untuk mendaftarkan, menguji (*TestFlight*), dan merilis aplikasi **StrideSync** ke **Apple App Store**.

---

## 1. 📋 Persiapan Akun & App Store Connect
1. **Daftar Apple Developer Program:**
   * Buka [developer.apple.com/programs](https://developer.apple.com/programs/) ($99 USD/tahun).
2. **Buat App ID & Provisioning Profile:**
   * **Bundle Identifier:** `com.stridesync.ios`
   * **Capabilities yang Diaktifkan:**
     * `Sign in with Apple`
     * `HealthKit`
     * `Push Notifications`
     * `Background Modes` (Location updates, Audio, Background fetch)
3. **Buat Aplikasi di App Store Connect:**
   * Masuk ke [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
   * Klik `+` -> **New App**.
   * **Name:** `StrideSync: Running & GPS Tracker`
   * **Primary Language:** `Indonesian (id)` / `English (U.S.)`
   * **Primary Category:** `Health & Fitness`
   * **Secondary Category:** `Sports`

---

## 2. 📝 Metadata & Deskripsi Pemasaran (ASO)

### **Judul (App Title):**
`StrideSync – GPS Run & Social Fitness`

### **Subtitle (30 Karakter):**
`Lari, Rute GPS & Komunitas`

### **Kata Kunci (Keywords SEO - 100 Karakter):**
`lari,running,strava,gps,maraton,jogging,rute,metronome,vo2max,sepeda,healthkit,komunitas,radar,speedometer`

### **Deskripsi Lengkap (Description):**
```
Tingkatkan performa olahraga dan lari harianmu dengan StrideSync – aplikasi pelacak GPS, biomekanik cerdas, dan komunitas atlet modern.

FITUR UNGGULAN:
• 📍 Presisi Pelacak GPS: Rekam jarak, pace, split 1-km, dan elevasi tanjakan dengan akurasi tinggi.
• 🎙️ Pelatih Suara (Audio Cues): Dapatkan pengumuman waktu dan kecepatan langsung di earphone saat berlari tanpa perlu melihat layar.
• 🗺️ 3D Flyover Replay: Putar ulang rute larimu dalam simulasi kamera 3D satelit yang menakjubkan.
• 🔋 Metronom Kadens & Biomekanik: Sinkronisasikan langkah kaki ke irama 170-190 SPM untuk efisiensi energi.
• 📡 Live Buddy Radar & Safety Beacon: Pantau posisi teman lari dan bagikan link live tracking darurat via SMS.
• 🥇 Segmen & All-Time PRs: Taklukkan rute segmen kota terdekat dan kumpulkan lencana piala rekor pribadimu.
• ⌚ Sinkronisasi Apple Health & Apple Watch.

Siap melangkah lebih jauh? Unduh StrideSync hari ini dan mulailah berlari!
```

---

## 3. 🔒 Jawaban Kuisioner Privasi Apple (App Store Review)
Saat mengisi bagian **App Privacy** di App Store Connect:
* **Location (Lokasi):**
  * *Collected:* Yes.
  * *Purpose:* App Functionality (Melacak rute lari & segmen).
  * *Linked to User:* Yes.
* **Health & Fitness (HealthKit):**
  * *Collected:* Yes (Detak jantung & kalori).
  * *Purpose:* Analytics & App Functionality.
  * *Used for Advertising:* **NO** (Penting: Jangan pernah pilih iklan untuk HealthKit).
* **Contact Info (Email/Nama):**
  * *Collected:* Yes (Untuk autentikasi Sign in with Apple).

---

## 4. 🚀 Kompilasi & Unggah ke TestFlight (Otomatis)

Jalankan skrip build rilis yang telah disediakan di terminal:
```bash
chmod +x scripts/build_release_ipa.sh
./scripts/build_release_ipa.sh
```

Arsip `.ipa` atau `.xcarchive` akan otomatis siap diunggah menggunakan **Xcode Organizer** atau alat **Transporter App** di macOS!

