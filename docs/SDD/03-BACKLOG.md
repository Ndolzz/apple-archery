# Apple Archery — Backlog dan Task Breakdown

Versi: 0.1. Seluruh ID requirement merujuk pada 00-SPEC.md.

## Phase 0 — Baseline SDD (SELESAI, menunggu persetujuan)

- [x] T-0.1 Audit repositori (hasil: kosong, tanpa branch/commit).
- [x] T-0.2 Membuat spesifikasi (00-SPEC).
- [x] T-0.3 Membuat arsitektur (01-ARCHITECTURE).
- [x] T-0.4 Membuat decision records (02-DECISIONS).
- [x] T-0.5 Membuat backlog ini (03-BACKLOG).
- [x] T-0.6 Membuat test plan (04-TEST-PLAN).
- [x] T-0.7 Membuat traceability matrix (05-TRACEABILITY).
- [x] T-0.8 Membuat register risiko (06-RISKS).
- [x] T-0.9 Laporan Phase 0 (PHASE0_REPORT).

## Phase 1 — Vertical Slice (FR-GF-001..005, FR-LV-001 parsial)

- [x] T-1.1 Inisialisasi proyek Godot 4.x (project.godot, struktur folder, .gitignore, .gdlintrc bila tersedia).
- [ ] T-1.2 BallisticsModel murni: gravitasi, drag, angin, prediksi lintasan (FR-GF-002, FR-GF-004).
- [ ] T-1.3 AimController: input tarikan untuk sentuh (FR-GF-001).
- [ ] T-1.4 Arrow node + collision (FR-GF-003).
- [ ] T-1.5 Target statis dengan zona skoring (FR-GF-005 dasar).
- [ ] T-1.6 Arena scene tunggal + 3 level percobaan dari data (FR-LV-001 dasar).
- [ ] T-1.7 HUD minimal: skor, angin, tombol prediksi.
- [ ] T-1.8 Workflow GitHub Actions: pengujian headless Godot (FR-QA-001).
- [ ] T-1.9 Pengujian otomatis fisika dan skoring.
- [ ] T-1.10 Gerbang persetujuan: demonstrasi vertikal slice.

Catatan T-1.1 (commit 7c5fdb8): proyek Godot 4.3 diinisialisasi — project.godot (orientasi portrait, renderer gl_compatibility, emulasi sentuh dari mouse untuk pengujian desktop), struktur folder lengkap sesuai 01-ARCHITECTURE.md, .gitignore (mengecualikan .godot/, artefak build, dan kredensial keystore), dan ikon placeholder. Verifikasi terbatas pada tinjauan isi berkas; Godot tidak dapat dijalankan lokal (risiko R-01).

## Phase 2 — Kampanye dan Level (FR-LV-002..006)

- [ ] T-2.1 Peta dunia dan 4 tema visual.
- [ ] T-2.2 Target bergerak (pola gerak dari data).
- [ ] T-2.3 Rintangan dan puzzle.
- [ ] T-2.4 Golden Apple tiap 10 level.
- [ ] T-2.5 Boss Challenge tiap 50 level (skrip boss sederhana).
- [ ] T-2.6 Generator dan pengatur kesulitan level.

## Phase 3 — Karakter dan Ekonomi (FR-CH-001..005)

- [ ] T-3.1 Data karakter dan skill unik.
- [ ] T-3.2 Katalog busur dan panah.
- [ ] T-3.3 Koin dan hadiah skoring.
- [ ] T-3.4 Toko (pembelian, upgrade, kosmetik).
- [ ] T-3.5 Keseimbangan ekonomi awal.

## Phase 4 — Mode Permainan (FR-MD-001..005)

- [ ] T-4.1 Time Attack.
- [ ] T-4.2 Daily Challenge offline (seed tanggal).
- [ ] T-4.3 Rank, medali, papan hasil.
- [ ] T-4.4 Statistik dan pencapaian.

## Phase 5 — Fitur Sosial dan Berbagi (FR-MD-006..009)

- [ ] T-5.1 Ghost Replay (rekaman input, pemutaran).
- [ ] T-5.2 Challenge Code (enkode/dekode, validasi).
- [ ] T-5.3 Local Multiplayer dua pemain satu perangkat.
- [ ] T-5.4 Berbagi hasil ke aplikasi lain.

## Phase 6 — Audio, Visual, dan Sistem (FR-AV-001..006, FR-SY-001..003, FR-DV-001..006)

- [ ] T-6.1 Animasi dan efek visual.
- [ ] T-6.2 Musik dan sound effect.
- [ ] T-6.3 Photo Mode.
- [ ] T-6.4 Tutorial interaktif.
- [ ] T-6.5 Aksesibilitas.
- [ ] T-6.6 Save offline, autosave, backup.
- [ ] T-6.7 Pengaturan performa perangkat rendah.
- [ ] T-6.8 About, Credits, Changelog, identitas Naze.
- [ ] T-6.9 Developer Console, Physics Lab, Debug Overlay.

## Phase 7 — Regresi, Optimasi, Build (FR-QA-001..004)

- [ ] T-7.1 Pengujian regresi menyeluruh.
- [ ] T-7.2 Optimasi performa.
- [ ] T-7.3 Workflow build APK (debug lalu signed via Secrets).
- [ ] T-7.4 Verifikasi APK (install dan smoke test manual terdokumentasi).
- [ ] T-7.5 Rilis kandidat.

Aturan: setiap tugas diselesaikan bertahap dalam commit kecil; tidak ada perubahan besar tunggal. Setiap selesai tugas, perbarui BACKLOG dan TRACEABILITY.
