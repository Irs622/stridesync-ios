# 🤝 Panduan Kontribusi Resmi StrideSync (Contributing Guidelines)

Selamat datang di proyek **StrideSync iOS**! Untuk menjaga keandalan kelas telemetri, keamanan data atlet, dan integritas arsitektur **Swift 6**, seluruh kontributor diwajibkan mematuhi aturan dan standar rekayasa perangkat lunak ketat yang tercantum dalam dokumen ini.

---

## 🏛️ 1. Prinsip Utama Rekayasa (Engineering Principles)

1. ⚡️ **Swift 6 Data-Race Safety:** Seluruh kode baru harus lolos kompilasi Swift 6 Strict Concurrency tanpa peringatan (*zero warnings*).
2. 🛡️ **Privacy & Security First:** Lokasi sensitif pengguna (rumah/kantor) wajib disanitasi dengan geofencing masking, dan kredensial/token wajib tersimpan di **Apple Keychain**.
3. 💾 **Local-First & Schema Integrity:** Aplikasi harus 100% fungsional saat offline. Seluruh perubahan struktur data `@Model` wajib menyertakan migrasi skema terversi (`StrideSyncSchema` / `SchemaMigrationPlan`).
4. 🧪 **100% Passing Test Gate:** Pull Request (PR) tidak akan diterima jika ada satu pun tes unit yang gagal (*broken build*).

---

## 🌿 2. Alur Kerja Git & Standar Penamaan Branch

### 2.1 Format Nama Branch
Gunakan awalan jenis pekerjaan diikuti dengan nama modul/fitur secara spesifik dalam huruf kecil (*kebab-case*):

| Jenis | Pola Penamaan | Contoh |
| :--- | :--- | :--- |
| **Fitur Baru** | `feature/<nama-fitur>` | `feature/live-safety-beacon`, `feature/pacing-coach` |
| **Perbaikan Bug** | `bugfix/<deskripsi-bug>` | `bugfix/fix-gpx-elevation-overflow`, `bugfix/split-pause-drift` |
| **Performa & Optimasi**| `perf/<target-optimasi>`| `perf/kalman-filter-memory`, `perf/mapkit-overlay-fps` |
| **Refaktorisasi** | `refactor/<nama-modul>` | `refactor/location-engine-actors`, `refactor/ble-manager` |
| **Dokumentasi** | `docs/<nama-dokumen>` | `docs/update-architecture-v2`, `docs/api-reference` |

### 2.2 Alur Kerja (Step-by-Step Workflow)
1. **Fork & Clone** repository ke mesin lokal Anda:
   ```bash
   git clone https://github.com/Irs622/stridesync-ios.git
   cd stridesync-ios
   ```
2. **Sinkronkan dengan branch `main` terbaru:**
   ```bash
   git checkout main
   git pull origin main
   ```
3. **Buat branch baru:**
   ```bash
   git checkout -b feature/nama-fitur-anda
   ```
4. **Tulis kode, dokumentasi, dan unit test.**
5. **Jalankan test suite lokal:**
   ```bash
   swift test
   ```
6. **Kirimkan commit terstruktur dan buat Pull Request.**

---

## 📝 3. Standar Pesan Commit (Conventional Commits v1.0)

Pesan commit harus mengikuti spesifikasi **[Conventional Commits](https://www.conventionalcommits.org/)**:

```text
<type>(<optional scope>): <deskripsi singkat dalam bahasa imperatif>

[opsional body penjelasan alasan perubahan dan trade-off]
[opsional footer referensi issue / breaking change]
```

### Jenis Prefix yang Diizinkan:
* `feat:` Penambahan fitur baru untuk pengguna.
* `fix:` Perbaikan bug pada sistem atau algoritma.
* `refactor:` Perubahan kode tanpa mengubah fungsionalitas eksternal.
* `perf:` Peningkatan efisiensi komputasi, memori, atau daya baterai.
* `test:` Penambahan atau pembaruan suite pengujian unit.
* `docs:` Perubahan pada dokumen `.md` (PRD, README, ARCHITECTURE, dll).
* `security:` Peningkatan enkripsi, sanitasi data geofence, atau penanganan Keychain.
* `chore:` Pemeliharaan dependensi, konfigurasi build CI/CD, atau skrip automasi.

### Contoh Pesan Commit yang Baik:
```bash
feat(pacing): implement dynamic audio cue feedback for target splits
fix(navigation): resolve cross-track error threshold on sharp hairpin turns
test(training-load): add Banister TRIMP exponential decay unit tests
security(privacy): enforce 200m geofence masking before exporting GPX files
```

---

## 🛡️ 4. Aturan Rekayasa & Kualitas Kode yang Ketat

### 4.1 Swift 6 Concurrency & Actor Isolation
* **Actor Boundary Safety:** Jangan mengirimkan tipe data non-`Sendable` melintasi batas Actor. Selalu buat struct snapshot (misal: `TelemetrySnapshot`, `SplitSnapshot`, `PacingTarget`).
* **Isolasi Hardware & Komputasi Berat:** Seluruh kalkulasi GPS kontinu wajib berada dalam `actor LocationEngine`, sedangkan pembaruan UI wajib diisolasi pada `@MainActor`.
* **Zero Force Unwrapping:** Dilarang keras menggunakan force unwrap `!` pada kode produksi kecuali pada data konstan mock pengujian statis. Gunakan `guard let`, `if let`, atau fallback default `??`.
* **Non-Blocking Execution:** Dilarang memanggil `Thread.sleep(...)` pada alur kerja async. Selalu gunakan `Task.sleep(nanoseconds:)`.

### 4.2 Persistensi Basis Data & SwiftData Schema Migration
* Dilarang mengubah properti `@Model` secara langsung tanpa mendaftarkannya pada skema terversi (`StrideSyncSchema.swift`).
* Setiap migrasi struktur tabel (menambah, menghapus, atau mengubah relasi) wajib menyertakan `SchemaMigrationPlan` yang teruji agar pengguna lama tidak mengalami *app crash* saat pembaruan versi.

### 4.3 Privasi Data Geospasial & Keamanan
* Setiap fungsi ekspor file publik (`GPXService`, `FITService`, Web Live Beacon) **wajib** melewati filter sanitasi titik koordinat di sekitar rumah/kantor pengguna via `PrivacyZoneService`.
* Kredensial sensitif, token autentikasi, dan kunci enkripsi **wajib** disimpan di Apple Keychain Security Framework via `KeychainManager`, dilarang disimpan dalam bentuk *plain-text* di `UserDefaults`.

### 4.4 Kompatibilitas Multiplatform (iOS 18+, watchOS 11+, macOS)
* Kode harus aman dikompilasi lintas platform. Gunakan compiler directives yang tepat:
  ```swift
  #if os(iOS)
  .navigationBarTitleDisplayMode(.inline)
  #endif
  ```
* Hindari memanggil API eksklusif iOS di target modul bersama tanpa pembungkus `#if os(iOS)` / `#if !os(watchOS)`.

### 4.5 Desain Antarmuka & Design System
* Wajib menggunakan token warna semantik resmi dari `StrideTheme` (`StrideTheme.primaryOrange`, `StrideTheme.athleticGreen`, `StrideTheme.cardBackground`, `StrideTheme.hudDark`).
* Jangan menggunakan nilai warna heksadesimal acak (*hardcoded*) di dalam komponen tampilan.
* Seluruh sudut elemen kartu (*card corners*) wajib menggunakan gaya kontinyu (`style: .continuous`).

---

## 🧪 5. Standar Pengujian Unit (Unit Testing Standards)

1. **Wajib Menyertakan Unit Test Baru:** Setiap penambahan modul `Service`, `Engine`, atau `Calculator` baru wajib menyertakan test suite pengujian mandiri di direktori `Tests/StrideSyncTests/`.
2. **Gunakan Swift Testing Framework Modern:** Manfaatkan `@Suite`, `@Test`, dan makro `#expect(...)` daripada `XCTest` warisan lama.
3. **Pengujian Nilai Ekstrem (*Edge Cases*):**
   * Uji penolakan koordinat noise / GPS drift (`accuracy > 25m`).
   * Uji kondisi tanpa sinyal detak jantung (fallback ke RPE).
   * Uji toleransi deviasi belokan rute navigasi ($> 30\text{m}$ off-course).
4. **Verifikasi Keberhasilan 100%:**
   ```bash
   swift test
   ```
   *Seluruh 48+ test suites harus lulus dengan status hijau (100% Passing).*

---

## ✅ 6. Daftar Periksa Pra-Pull Request (Pre-PR Checklist)

Sebelum menekan tombol **Create Pull Request**, pastikan Anda telah mencentang seluruh poin berikut:

- [ ] Kode baru lolos kompilasi tanpa peringatan di bawah **Swift 6 Strict Concurrency**.
- [ ] Menjalankan `swift test` dan **100% tes unit lulus**.
- [ ] Menambahkan unit test baru untuk setiap logika kalkulasi / parsing data yang baru dibuat.
- [ ] Format pesan commit mengikuti standar **Conventional Commits** (`feat:`, `fix:`, dll).
- [ ] Perubahan skema basis data `@Model` telah disertai versi `StrideSyncSchema` dan `SchemaMigrationPlan`.
- [ ] Seluruh data lokasi eksternal telah disanitasi dengan `PrivacyZoneService`.
- [ ] Tidak ada token atau kunci sensitif yang disimpan sembarangan di luar `KeychainManager`.
- [ ] Dokumentasi terkait ([`PRD.md`](PRD.md), [`README.md`](README.md), atau [`ROADMAP.md`](ROADMAP.md)) telah diperbarui bila ada perubahan alur.

---

## 🔍 7. Kebijakan Review & Penggabungan Kode (Review & Merge)

1. **Code Review:** Setiap Pull Request akan ditinjau oleh tim pengembang utama untuk memastikan kesesuaian arsitektur Clean MVVM-C dan efisiensi memori.
2. **Automated CI/CD:** GitHub Actions akan secara otomatis mengompilasi proyek dan menjalankan seluruh pengujian unit.
3. **Squash and Merge:** Setelah disetujui, PR akan digabungkan ke branch `main` menggunakan metode *Squash and Merge* dengan pesan deskripsi yang rapi.

---
*Terima kasih telah membantu membangun platform pelacak kebugaran dan sosial atletik generasi masa depan bersama StrideSync!*
