# 🔒 Kebijakan Keamanan & Privasi Atlet (Security & Privacy Policy)

Keamanan data atlet dan privasi informasi lokasi merupakan prioritas tertinggi dalam pengembangan sistem **StrideSync**. Dokumen ini menjelaskan kebijakan keamanan, perlindungan data, dan prosedur pelaporan kerentanan.

---

## 🛡️ 1. Versi yang Didukung (Supported Versions)

Kami secara aktif memelihara dan memberikan pembaruan keamanan untuk versi-versi berikut:

| Versi | Status Dukungan | Catatan Keamanan |
| :--- | :--- | :--- |
| **2.0.x (Latest)** | :white_check_mark: **Didukung Penuh** | Swift 6 Concurrency, Keychain Encryption, Geofence Masking |
| **1.0.x** | :white_check_mark: Didukung (Security Patches Only) | SwiftData V1 persistence |
| **< 1.0** | :x: Tidak Didukung | Versi pengembangan awal |

---

## 🏛️ 2. Standar Perlindungan Data & Privasi

1. **Geofencing Coordinate Sanitization (`PrivacyZoneService`):**
   * Seluruh koordinat GPS dalam radius zona privasi atlet (rumah, sekolah, atau kantor) otomatis disamarkan (*masked*) sebelum rute diunggah ke linimasa publik atau diekspor ke file GPX/FIT.
2. **Enkripsi Kredensial di Apple Keychain (`KeychainManager`):**
   * Token autentikasi JWT, password, dan kunci privat disimpan secara terenkripsi di **Apple Keychain Services** (`kSecClassGenericPassword`) dengan isolasi hardware Secure Enclave.
3. **Local-First Data Isolation:**
   * Riwayat aktivitas dan rekaman sensor disimpan secara lokal di perangkat menggunakan basis data **SwiftData**. Data tidak akan dikirim ke server pihak ketiga tanpa persetujuan eksplisit atlet.
4. **Keamanan Komunikasi Bluetooth LE (`CoreBluetooth`):**
   * Paket data detak jantung dan power meter hanya diproses secara lokal di antrian sistem terisolasi tanpa menyimpan identifier permanen yang dapat melacak identitas perangkat di luar sesi latihan.

---

## 📬 3. Pelaporan Kerentanan Keamanan (Reporting a Vulnerability)

Jika Anda menemukan celah keamanan (*vulnerability*) atau potensi kebocoran data privasi dalam kode sumber StrideSync:

1. **Jangan membuat Issue publik di GitHub.**
2. Silakan gunakan fitur **[GitHub Private Vulnerability Reporting](https://github.com/Irs622/stridesync-ios/security/advisories/new)** atau kirimkan email langsung ke `security@stridesync.app`.
3. Sertakan informasi berikut dalam laporan Anda:
   * Deskripsi rinci mengenai celah keamanan.
   * Langkah-langkah untuk mereproduksi masalah (*proof-of-concept payload*).
   * Versi sistem operasi iOS / macOS dan commit hash yang terdampak.

### Komitmen Respon Kami:
* Kami akan mengonfirmasi penerimaan laporan Anda dalam kurun waktu **24–48 jam**.
* Tim pengembang akan menganalisis dampak dan merilis perbaikan (*hotfix*) sesegera mungkin.
* Anda akan dicantumkan dalam catatan rilis (*Security Hall of Fame*) sebagai bentuk apresiasi kami.

---
*Terima kasih telah membantu menjaga keamanan dan privasi komunitas atletik StrideSync!*
