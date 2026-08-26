# 🤝 Contributing to StrideSync

Terima kasih atas ketertarikan Anda untuk berkontribusi pada pengembangan **StrideSync**! Kami menyambut baik kontribusi berupa perbaikan bug, penambahan fitur baru, perbaikan dokumentasi, maupun optimasi performa.

---

## 📋 Alur Kontribusi (Contribution Workflow)

1. **Fork Repository**
   Fork repository ini ke akun GitHub Anda:
   ```bash
   git clone https://github.com/Irs622/stridesync-ios.git
   ```

2. **Buat Branch Baru**
   Gunakan format penamaan branch yang jelas:
   - `feature/nama-fitur` (untuk fitur baru)
   - `bugfix/nama-bug` (untuk perbaikan bug)
   - `docs/nama-dokumentasi` (untuk penambahan dokumentasi)
   - `refactor/nama-modul` (untuk refaktorisasi kode)

   ```bash
   git checkout -b feature/apple-watch-sync
   ```

3. **Standar Penulisan Pesan Commit (Conventional Commits)**
   Gunakan konvensi commit yang terstruktur:
   - `feat: add live heart rate graph in post-workout summary`
   - `fix: correct split pacing calculation when workout is paused`
   - `test: add unit test for GPX 1.1 elevation parser`
   - `docs: update system architecture diagram in ARCHITECTURE.md`
   - `refactor: extract color palette to StrideTheme design system`

4. **Jalankan Pengujian Unit & Pastikan 100% Lulus**
   Sebelum membuat Pull Request, pastikan seluruh test suite lulus:
   ```bash
   swift test
   ```

5. **Kirimkan Pull Request (PR)**
   Buka Pull Request ke branch `main` di repository utama `https://github.com/Irs622/stridesync-ios`.

---

## 🎨 Panduan Gaya Kode (Code Style Guidelines)

- **Swift 6 Concurrency**: Pastikan kode baru mematuhi aturan *data race safety*. Jangan mengirimkan kelas non-Sendable melintasi batas Actor.
- **SwiftUI & HIG**: Gunakan semantic colors (`Color.primary`, `Color.secondary`, atau `StrideTheme.cardBackground`) dan continuous corner radius.
- **Documentation**: Berikan docstrings ringkas pada fungsi `public` dan entitas model utama.

---

## 📬 Pertanyaan & Dukungan

Jika Anda memiliki pertanyaan mengenai arsitektur atau ide fitur baru, silakan buka **Issue** di GitHub atau hubungi tim pengembang via GitHub repository.
