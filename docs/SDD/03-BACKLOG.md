# Apple Archery — Backlog dan Task Breakdown

Versi: 0.2. Seluruh ID requirement merujuk pada 00-SPEC.md.

## Phase 0 — Baseline SDD (SELESAI)

- [x] T-0.1 Audit repositori (hasil: kosong, tanpa branch/commit).
- [x] T-0.2 Membuat spesifikasi (00-SPEC).
- [x] T-0.3 Membuat arsitektur (01-ARCHITECTURE).
- [x] T-0.4 Membuat decision records (02-DECISIONS).
- [x] T-0.5 Membuat backlog ini (03-BACKLOG).
- [x] T-0.6 Membuat test plan (04-TEST-PLAN).
- [x] T-0.7 Membuat traceability matrix (05-TRACEABILITY).
- [x] T-0.8 Membuat register risiko (06-RISKS).
- [x] T-0.9 Laporan Phase 0 (PHASE0_REPORT).

## Phase 1 — Vertical Slice (FR-GF-001..006, FR-LV-001 dasar, FR-AV-007)

- [x] T-1.1 Inisialisasi proyek Godot 4.x (commit 7c5fdb8).
- [x] T-1.2 BallisticsModel murni: gravitasi, drag, angin, prediksi lintasan (commit 10f5042).
- [x] T-1.3 AimController: input tarikan untuk sentuh (commit 8ae4286).
- [x] T-1.4 Arrow node + collision (commit 31596a7).
- [x] T-1.5 Target statis dengan zona skoring (commit d5d68ca, 23cc967; ADR-009 disetujui sementara).
- [x] T-1.6 Arena scene tunggal + 3 level dari data + soft camera zoom + wind VFX + trajectory preview (commit 9e07151, 45a03c5, 52094d).
- [ ] T-1.7 HUD minimal: skor, angin, tombol prediksi (dasar sudah ada di arena; menyusul penyempurnaan UI).
- [ ] T-1.8 Workflow GitHub Actions: pengujian headless Godot (FR-QA-001).
- [ ] T-1.9 Pengujian otomatis fisika dan skoring — dijalankan di CI setelah T-1.8.
- [ ] T-1.10 Gerbang persetujuan: demonstrasi vertikal slice.

Catatan T-1.6 (commit 9e07151, 45a03c5, 52094d): LevelData murni (ADR-003) + assets/levels/levels.json — 3 level percobaan sepenuhnya dari data (id, wind, drag, arrow_count, targets; zone_points dapat dioverride per target sesuai ADR-009), loader fail-fast; arena.gd/arena.tscn — scene tunggal orkestrasi (input sentuh/mouse → AimController; tembak → Arrow; hit → ScoringService; HUD minimal), main scene di project.godot; arena_camera.gd — soft zoom saat membidik (smoothing eksponensial, clamp, tanpa lompatan; kembali normal setelah tembakan/batal); wind_vfx.gd — goresan angin kartun prosedural yang arah/intensitasnya dari wind Vector2 level aktif (bukan sistem angin terpisah), z_index di bawah gameplay; trajectory_preview.gd — titik prediksi dari BallisticsModel.predict_trajectory (tanpa fisika duplikat), toggle enabled, low_effects mengurangi titik. Kamera dan VFX hanya presentasi (ADR-010) — tidak menyentuh kecepatan, arah, skor, collision, atau hasil simulasi. Kebutuhan visual baru dicatat sebagai perubahan spesifikasi v0.2: FR-GF-006 (soft camera zoom) dan FR-AV-007 (cartoon wind VFX). Bukti verifikasi: pemeriksaan numerik eksternal logika zoom (konvergensi 2 detik tanpa lompatan; kembali normal; clamp) dan pemetaan angin (0/4/8/20 m/s; arah ikut tanda). Pengujian GDScript TP-1.18..TP-1.22 tertulis namun belum dijalankan di Godot (menunggu T-1.8); tidak ada klaim runtime berhasil.

Catatan T-1.5 (commit d5d68ca, 23cc967): scripts/gameplay/target.gd — Target murni dengan zona lingkaran konsentris (fraksi radius, validasi ketat); scripts/gameplay/scoring_service.gd — ScoringService murni: classify dari titik impact aktual (titik masuk pertama collision, bukan kedekatan visual), score_hit dengan pencocokan id target, combo (register_shot, best combo, multiplier). Nilai zona dan aturan combo dicatat sebagai ADR-009 — disetujui sementara pengguna (50/20/10; Perfect = zona pusat; batas inklusif; rumus combo konfigurabel per level). Kasus diatur: panah STUCK tanpa skor baru, target terkena lebih dari sekali tidak mungkin pada T-1.5, beberapa target satu langkah: t terkecil yang dinilai. Bukti verifikasi: pemeriksaan numerik eksternal klasifikasi zona. Pengujian GDScript TP-1.5, TP-1.6, TP-1.17 tertulis; tidak ada klaim lulus runtime.

Catatan T-1.4 (commit 31596a7): CollisionService murni swept segment-vs-circle (persamaan kuadrat, titik masuk pertama); Arrow node dengan akumulator timestep tetap 1/120 s, status IDLE/FLYING/STUCK, validasi peluncuran, sinyal hit_target. Kondisi "panah berhenti" = status STUCK (terdokumentasi di header). Pemeriksaan numerik eksternal menemukan cacat titik-terdekat (titik terdalam vs titik masuk) dan diganti persamaan kuadrat terverifikasi. TP-1.12..TP-1.16 tertulis; tidak ada klaim lulus runtime.

Catatan T-1.3 (commit 8ae4286): AimController murni, terpisah dari InputEvent dan fisika; tarik-balik dengan clamp power/kecepatan; validasi area main, pembatalan, release tanpa aim. Pemeriksaan numerik eksternal menemukan dan memperbaiki cacat normalisasi (53.03 vs 30.0 m/s). TP-1.7..TP-1.11 tertulis; tidak ada klaim lulus runtime.

Catatan T-1.1 (commit 7c5fdb8): proyek Godot 4.3 diinisialisasi; struktur folder sesuai 01-ARCHITECTURE.md; .gitignore mengecualikan .godot/, artefak build, kredensial. Verifikasi terbatas tinjauan isi berkas (R-01).

Catatan T-1.2 (commit 10f5042): BallisticsModel murni (ADR-002), satuan SI, semi-implicit Euler timestep tetap, validasi input. Pemeriksaan silang numerik seluruh properti TP-1.1..TP-1.4 terpenuhi; eksekusi riil menunggu CI (T-1.8).

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
