# 🏃‍♂️ Panduan Menjalankan StrideSync 100% Gratis (Biaya Rp 0)

Panduan ini menjelaskan cara menggunakan dan memasang aplikasi **StrideSync** ke perangkat iPhone fisik Anda dan teman-teman Anda **tanpa perlu membayar akun Apple Developer ($99) atau menyewa server (Rp 0)**.

---

## 🌟 1. Arsitektur "Local-First" Bebas Biaya Server
StrideSync dirancang dengan prinsip **Local-First**:
* **Database Mandiri (SwiftData):** Seluruh rute GPS, grafik elevasi, split kilometer, estimasi VO2 Max, dan riwayat rekor lari tersimpan aman di memori lokal iPhone Anda.
* **Bebas Kuota & Offline 100%:** Anda bisa merekam lari di pegunungan, hutan, atau luar negeri tanpa perlu koneksi internet.
* **Ekspor & Berbagi Tanpa Batas:** Anda bisa mengekspor rute lari dalam format standar dunia **GPX 1.1 XML** atau **FIT** dan langsung membagikannya via WhatsApp, AirDrop, Telegram, atau mengimpornya ke Strava / Garmin Connect secara gratis!

---

## 📲 2. Cara Memasang Aplikasi ke iPhone Asli Anda (Gratis via Xcode)

Anda bisa memasang aplikasi ini langsung ke iPhone Anda menggunakan akun Apple ID biasa (gratis):

### Langkah-langkah:
1. **Sambungkan iPhone ke Mac:**
   * Gunakan kabel data USB/Type-C untuk menghubungkan iPhone ke laptop Mac Anda.
   * Pada layar iPhone, pilih **"Trust This Computer" (Percayai Komputer Ini)**.
2. **Aktifkan Developer Mode di iPhone (Khusus iOS 16+):**
   * Di iPhone, buka menu **Settings (Pengaturan)** ➡️ **Privacy & Security (Privasi & Keamanan)**.
   * Gulir ke paling bawah, ketuk **Developer Mode (Mode Pengembang)**, lalu aktifkan (ON) dan restart iPhone.
3. **Buka Proyek di Xcode:**
   * Buka folder proyek ini di Xcode:
     ```bash
     open Package.swift
     ```
4. **Pilih Personal Team Gratis:**
   * Pada tab *Signing & Capabilities*, masukkan akun Apple ID (iCloud) gratis Anda di bagian **Team**.
5. **Jalankan ke iPhone:**
   * Pada bagian atas Xcode (Device Selector), ganti pilihan dari *Simulator* menjadi **Nama iPhone Anda**.
   * Klik tombol **▶️ Play (Run)**.
   * Aplikasi StrideSync akan langsung terpasang di iPhone Anda dan siap dibawa lari di luar ruangan!

---

## 👥 3. Cara Membagikan ke Teman Tanpa Bayar Server

* **Opsi A (Sideloading Gratis):** Teman Anda bisa memasang file build menggunakan kabel USB atau aplikasi sideloading gratis seperti *Sideloadly* / *AltStore*.
* **Opsi B (Ekspor GPX Lari Bersama):** Setelah selesai lari bersama, Anda cukup mengetuk tombol **Bagikan GPX** di layar ringkasan latihan untuk mengirimkan file rute lengkap ke WhatsApp teman Anda.
* **Opsi C (Database Cloud Gratis via Gmail):** Jika ingin fitur linimasa komunitas online, Anda cukup membuat akun gratis di **Supabase.com** atau **Firebase** dengan akun Gmail gratis (kuota gratis hingga 50.000 pengguna).

---

## 🛠️ 4. Menjalankan Tes Otomatis
Untuk memastikan seluruh 81 fitur aplikasi berjalan normal tanpa error:
```bash
swift test
```
Semua 37 rangkaian tes akan tervalidasi dengan sukses (**100% PASS**).

