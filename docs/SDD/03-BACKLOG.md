# Apple Archery — Backlog dan Task Breakdown

Versi: 0.3. Seluruh ID requirement merujuk pada 00-SPEC.md.

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
- [x] T-1.8 Workflow GitHub Actions: pengujian headless Godot (FR-QA-001) — commit 8109893, be97d89, 2146fe5, 00a61fe, f2d555b, 185f4e4, 1778160, 1b954a0; bukti run CI #8 (commit 1b954a0) LULUS.
- [ ] T-1.9 Pengujian otomatis fisika dan skoring — kini tereksekusi di CI pada setiap push (TP-1.1..TP-1.22); penyempurnaan cakupan menyusul (lihat catatan T-1.8).
- [ ] T-1.10 Gerbang persetujuan: demonstrasi vertikal slice.

Catatan T-1.8 (commit 8109893, be97d89, 2146fe5, 00a61fe, f2d555b, 185f4e4, 1778160, 1b954a0): .github/workflows/ci.yml — job tunggal ubuntu-24.04 dengan Godot 4.3-stable eksplisit (alasan: project.godot menargetkan 4.3, config/features="4.3"; bukan "latest"), empat langkah berurutan: (1) import resource headless — gagal bila log memuat galat skrip/parse/load; (2) parse check seluruh berkas .gd via --check-only; (3) runner tests/run_tests.gd headless (exit code runner 0/1 dipropagasikan); (4) gerbang keterlacakan — memastikan seluruh 22 kelompok TP-1.x tereksekusi (PASS atau FAIL) dan nol kegagalan; kegagalan individual dipancarkan sebagai anotasi dan ringkasan hasil ditulis ke job summary publik; log diunggah sebagai artefak. Pemicu push/PR/dispatch. Bukti eksekusi aktual: run CI #8 pada commit 1b954a0 (13 detik, succeeded) — seluruh langkah lulus, 22/22 kelompok TP, 111 pemeriksaan lulus, 0 gagal. Riwayat iterasi: run CI #1 (8109893) gagal — ditemukan galat parse implementasi arena_camera.gd (identifier SMOOTH tidak dideklarasikan; konstanta seharusnya SMOOTHING) yang merambat ke arena.gd; diperbaiki pada 2146fe5. Run #3-#6 memperbaiki koreksi pengujian berbasis bukti anotasi CI: TP-1.1 margin toleransi metode diperlebar 1e-6 menjadi 0.001 (akumulasi float32 Vector2 Godot melebihi margin lama; batas metode 0.049 dipertahankan); TP-1.14/TP-1.15 diubah memakai advance per frame (kontrak MAX_FRAME_DELTA 0.25 s — panggilan tunggal advance(0.5) hanya mensimulasikan 0.25 s) dan geometri TP-1.15 dibuat deterministik (lintasan lurus; target versi lama tidak dilewati lintasan melengkung — panah turun ~1.2 m); TP-1.15: lambda GDScript menangkap variabel secara nilai sehingga penetapan ulang tidak terlihat (diganti mutasi Array); TP-1.17: titik "just outside middle boundary" dikoreksi (2.0 bukan 2/3), ekspektasi skor titik masuk pertama diselaraskan dengan ADR-009 (titik masuk lingkaran selalu di tepi, d = radius, sehingga zona terluar 10 poin — bukan 50/perfect), dan score_hit membutuhkan "id" sehingga memakai segment_targets_first_hit seperti jalur gameplay (segment_circle_first_hit tunggal tidak menyertakan id). Run #7 (1778160): 111 lulus, 0 gagal, namun langkah verifikasi workflow gagal karena pipefail: grep tanpa kecocokan mengembalikan 1 (false-negative); diperbaiki pada 1b954a0 → run CI #8 hijau. Temuan desain (bukan cacat implementasi, dicatat sebagai R-11): dengan collision lingkaran dan skor dari titik masuk pertama (ADR-009), titik impact gameplay aktual selalu berada tepat di tepi target sehingga zona tengah/pusat tidak tercapai dari tembakan nyata — memerlukan keputusan desain pengguna (mis. radius collision lebih kecil dari radius skor, atau skor dari kedalaman penetrasi) sebelum Phase 2. Tidak ada tes yang dinonaktifkan atau dilemahkan untuk memperoleh status hijau; seluruh koreksi dijustifikasi pada 04-TEST-PLAN v0.1.5.

Catatan T-1.6 (commit 9e07151, 45a03c5, 52094d): LevelData murni (ADR-003) + assets/levels/levels.json — 3 level percobaan sepenuhnya dari data (id, wind, drag, arrow_count, targets; zone_points dapat dioverride per target sesuai ADR-009), loader fail-fast; arena.gd/arena.tscn — scene tunggal orkestrasi (input sentuh/mouse → AimController; tembak → Arrow; hit → ScoringService; HUD minimal), main scene di project.godot; arena_camera.gd — soft zoom saat membidik (smoothing eksponensial, clamp, tanpa lompatan; kembali normal setelah tembakan/batal); wind_vfx.gd — goresan angin kartun prosedural yang arah/intensitasnya dari wind Vector2 level aktif (bukan sistem angin terpisah), z_index di bawah gameplay; trajectory_preview.gd — titik prediksi dari BallisticsModel.predict_trajectory (tanpa fisika duplikat), toggle enabled, low_effects mengurangi titik. Kamera dan VFX hanya presentasi (ADR-010) — tidak menyentuh kecepatan, arah, skor, collision, atau hasil simulasi. Kebutuhan visual baru dicatat sebagai perubahan spesifikasi v0.2: FR-GF-006 (soft camera zoom) dan FR-AV-007 (cartoon wind VFX). Bukti verifikasi awal: pemeriksaan numerik eksternal; seluruh TP-1.18..TP-1.22 kini LULUS di CI run CI #8 (T-1.8).

Catatan T-1.5 (commit d5d68ca, 23cc967): scripts/gameplay/target.gd — Target murni dengan zona lingkaran konsentris (fraksi radius, validasi ketat); scripts/gameplay/scoring_service.gd — ScoringService murni: classify dari titik impact aktual (titik masuk pertama collision, bukan kedekatan visual), score_hit dengan pencocokan id target, combo (register_shot, best combo, multiplier). Nilai zona dan aturan combo dicatat sebagai ADR-009 — disetujui sementara pengguna (50/20/10; Perfect = zona pusat; batas inklusif; rumus combo konfigurabel per level). Kasus diatur: panah STUCK tanpa skor baru, target terkena lebih dari sekali tidak mungkin pada T-1.5, beberapa target satu langkah: t terkecil yang dinilai. TP-1.5, TP-1.6, TP-1.17 kini LULUS di CI run CI #8 (T-1.8; koreksi ekspektasi TP-1.17 diselaraskan dengan ADR-009).

Catatan T-1.4 (commit 31596a7): CollisionService murni swept segment-vs-circle (persamaan kuadrat, titik masuk pertama); Arrow node dengan akumulator timestep tetap 1/120 s, status IDLE/FLYING/STUCK, validasi peluncuran, sinyal hit_target. Kondisi "panah berhenti" = status STUCK (terdokumentasi di header). Pemeriksaan numerik eksternal menemukan cacat titik-terdekat (titik terdalam vs titik masuk) dan diganti persamaan kuadrat terverifikasi. TP-1.12..TP-1.16 kini LULUS di CI run CI #8 (T-1.8).

Catatan T-1.3 (commit 8ae4286): AimController murni, terpisah dari InputEvent dan fisika; tarik-balik dengan clamp power/kecepatan; validasi area main, pembatalan, release tanpa aim. Pemeriksaan numerik eksternal menemukan dan memperbaiki cacat normalisasi (53.03 vs 30.0 m/s). TP-1.7..TP-1.11 kini LULUS di CI run CI #8 (T-1.8).

Catatan T-1.1 (commit 7c5fdb8): proyek Godot 4.3 diinisialisasi; struktur folder sesuai 01-ARCHITECTURE.md; .gitignore mengecualikan .godot/, artefak build, kredensial. Verifikasi awal terbatas tinjauan isi berkas (R-01); verifikasi kini tersedia via CI (T-1.8).

Catatan T-1.2 (commit 10f5042): BallisticsModel murni (ADR-002), satuan SI, semi-implicit Euler timestep tetap, validasi input. TP-1.1..TP-1.4 kini LULUS di CI run CI #8 (T-1.8).

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
