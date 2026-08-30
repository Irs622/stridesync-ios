# 🏛️ StrideSync Architecture & Engineering Deep Dive

Dokumen ini menjelaskan secara rinci keputusan desain arsitektur, pola konkurensi **Swift 6**, manajemen memori, protokol komunikasi nirkabel, integrasi database cloud, dan algoritma matematis yang digunakan dalam pembangunan **StrideSync**.

---

## 1. Concurrency Model & Swift 6 Sendable Boundaries

Salah satu tantangan utama dalam aplikasi pelacak GPS modern adalah memastikan pengolahan koordinat berkecepatan tinggi tidak memblokir antarmuka pengguna (Main Thread) serta bebas dari *data race*.

```
┌─────────────────────────────────────────────────────────────┐
│                    @MainActor (UI Layer)                    │
│   RecordViewModel, FeedViewModel, SwiftUI Views & Charts    │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Sends Commands / Receives Snapshots)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│             actor LocationEngine (Worker Thread)            │
│  - Raw GPS Ingestion                                        │
│  - Distance Accumulation (WGS 84 Geodesic)                  │
│  - Auto-Pause State Machine                                 │
│  - Elevation Gain Accumulator                               │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Pure Sendable Value Types)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│          TelemetrySnapshot / ActivitySummarySnapshot        │
│          (Non-mutating Sendable Structs across Actors)      │
└─────────────────────────────────────────────────────────────┘
```

### Mengapa SwiftData `@Model` Tidak Dikirim Lintas Actor?
Dalam SwiftData, kelas yang dianotasi `@Model` bersifat non-Sendable dan terikat pada `ModelContext` tertentu. Oleh karena itu:
1. `LocationEngine` (sebuah `actor`) mengumpulkan data mentah dalam bentuk `struct TelemetrySnapshot: Sendable`.
2. Saat workout selesai (`finish()`), `LocationEngine` mengembalikan `(ActivitySummarySnapshot, [TelemetrySnapshot])`.
3. `@MainActor` atau ViewModel yang memiliki `ModelContext` aktif kemudian menginstansiasi entitas `@Model ActivityRecord` untuk disimpan ke database lokal.

---

## 2. GPS Telemetry Processing Pipeline

Setiap titik koordinat yang diterima dari `CLLocationManager` melalui delegasi dievaluasi dalam 4 tahapan filter sebelum dimasukkan ke dalam metrik latihan:

```mermaid
flowchart LR
    A[Raw CLLocation] --> B{Akurasi < 25m?}
    B -- Tidak (Noise) --> X[Drop Point]
    B -- Ya --> C{Moving Speed Check}
    C -- Kecepatan < 0.8 m/s --> D[Trigger Auto-Pause State]
    C -- Kecepatan >= 0.8 m/s --> E[State: Recording]
    E --> F[Calculate Delta Distance & Altitude]
    F --> G[Append to TelemetryBuffer]
    G --> H[Emit TrackingMetrics]
```

### 1. Accuracy Threshold Filter
Sinyal satelit yang memantul di antara gedung tinggi (*urban canyon effect*) sering menghasilkan lonjakan koordinat palsu. Titik dengan `horizontalAccuracy > 25.0 meter` atau bernilai negatif otomatis dieliminasi.

### 2. Auto-Pause Detection
Kondisi berhenti (misal di persimpangan lampu lalu lintas) dideteksi jika kecepatan sesaat berada di bawah ambang batas `0.8 m/s` (sekitar `2.88 km/jam`). Pada kondisi ini, timer waktu bergerak (*moving time*) dihentikan sementara sehingga nilai *average pace* atlet tetap akurat.

---

## 3. Algoritma Pencocokan Segmen (Virtual Segment Matching)

Segmen adalah potongan rute jalanan tertentu yang memiliki titik awal (*start coordinate*), titik akhir (*end coordinate*), dan daftar *waypoints*.

```
   [Start Gate (R=40m)]                     [End Gate (R=40m)]
          ●                                         ●
         / \                                       / \
        /   \                                     /   \
───────(  A  )───────────────────────────────────(  B  )────────▶ (Activity Path)
        \   /                                     \   /
         \ /                                       \ /
       t_start                                   t_finish
```

### Tahapan Algoritma:
1. **Entry Gate Detection**: Mencari titik dalam riwayat aktivitas yang jarak geodesiknya ke titik start segmen $\le 40\text{ meter}$.
2. **Sequential Verification**: Memastikan titik koordinat bergerak searah dengan segmen (bukan arah berlawanan).
3. **Exit Gate Detection**: Menemukan titik rute yang mencapai gerbang finish segmen $\le 40\text{ meter}$.
4. **Effort Elapsed Time**: Menghitung selisih waktu:
   $$\Delta t = t_{\text{finish}} - t_{\text{start}}$$
5. **KOM / PR Evaluation**: Membandingkan $\Delta t$ dengan rekor waktu sebelumnya untuk menentukan pemegang mahkota baru (*King of the Mountain*).

---

## 4. Geofencing Privacy Zone Algorithm

Untuk melindungi privasi alamat atlet, fungsi sanitasi memotong titik-titik koordinat yang berada dalam radius lingkaran privasi:

$$\text{isInsideZone}(P) \iff \text{distance}(P, C_{\text{zone}}) \le R_{\text{zone}}$$

Titik-titik yang memenuhi kondisi di atas akan disamarkan atau dihilangkan dari representasi rute visual publik, sementara kalkulasi total jarak tempuh tetap dipertahankan secara utuh.

---

## 5. Standar Ekspor/Impor GPX 1.1 XML & Garmin FIT 2.0
* **GPX 1.1:** Serialisasi rute ke XML standar ISO 8601 dengan tag `<trk>`, `<trkseg>`, `<trkpt lat="..." lon="...">`, `<ele>`, `<time>`.
* **FIT 2.0:** Serialisasi biner efisien tinggi untuk jam tangan Garmin dengan header 14-byte dan CRC checksum.

---

## 6. Cloud Database, Supabase & Row Level Security (RLS)

```
┌─────────────────────────────────────────────────────────────┐
│             StrideSync iOS (SwiftData Local-First)          │
│            Runs offline without cellular connection         │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Two-Way Sync when Online)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 CloudSyncEngine & CloudAPIService           │
│                 REST PostgREST API + Keychain JWT           │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Secure TLS over HTTPS)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                Supabase Cloud (PostgreSQL 15+)              │
│  - Row Level Security (RLS) policies                        │
│  - Realtime Kudos & Comment Triggers                        │
│  - Zero Cost / Free Tier (Rp 0)                             │
└─────────────────────────────────────────────────────────────┘
```

### Row Level Security (RLS) Proteksi:
Setiap tabel di database PostgreSQL dilindungi oleh aturan RLS:
```sql
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Activities are publicly readable" ON activities FOR SELECT USING (true);
CREATE POLICY "Users can insert activities" ON activities FOR INSERT WITH CHECK (true);
```
Dengan RLS, pengguna hanya bisa memodifikasi atau menghapus data mereka sendiri, menjamin keamanan data atlet secara global.

---

## 7. Background Execution Modes & Audio Ducking

* **`UIBackgroundModes: location, audio`:** `LiveLocationManager` mengaktifkan `allowsBackgroundLocationUpdates = true` dan `showsBackgroundLocationIndicator = true` sehingga GPS tetap merekam tanpa terputus saat iPhone dimasukkan ke kantong.
* **Audio Ducking:** `AudioCueService` mengonfigurasi `AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])`. Saat pengumuman split 1-km diucapkan oleh pelatih suara, volume lagu di Spotify atau Apple Music otomatis dikecilkan sesaat dan kembali normal setelah selesai bicara.

---

## 8. Onboarding Interaktif (`OnboardingView.swift`)

Alur pembuka 3-langkah menggunakan komponen modern SwiftUI:
* **Slide 1:** Presisi GPS & 3D Flyover (Permohonan izin `CLLocationManager`).
* **Slide 2:** Pelatih Suara & Apple Health (Permohonan izin `HKHealthStore`).
* **Slide 3:** Komunitas Global & Live Buddy Radar.
* **Persistensi:** Disimpan di `@AppStorage("hasCompletedOnboarding")`.
