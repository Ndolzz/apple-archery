# Apple Archery — Traceability Matrix

Versi: 0.1.7 (diperbarui setelah T-1.7: ADR-011 penetrasi; TP-1.23/TP-1.24; run CI #12 commit 74cded1 lulus — 24/24 kelompok TP)

| Requirement | Tugas (03-BACKLOG) | Pengujian (04-TEST-PLAN) | Fase | Status |
|---|---|---|---|---|
| FR-GF-001 Tarikan busur | T-1.3, T-1.7 | TP-1.7..TP-1.11, TP-1.24, Manual P1 | 1 | Terverifikasi di CI (8ae4286; run CI #8 lulus; indikator daya HUD 74cded1 run CI #12 lulus; uji manual menyusul) |
| FR-GF-002 Fisika realistis | T-1.2, T-1.7 | TP-1.1, TP-1.2, TP-1.3, TP-1.24 | 1 | Terverifikasi di CI (10f5042; run CI #8 lulus; indikator angin HUD konsisten dengan vektor angin BallisticsModel — 74cded1 run CI #12 lulus) |
| FR-GF-003 Collision | T-1.4 | TP-1.12..TP-1.16, Manual P1 | 1 | Terverifikasi di CI (31596a7; run CI #8 lulus; uji manual menyusul) |
| FR-GF-004 Prediksi lintasan | T-1.2, T-1.6 | TP-1.4, TP-1.22, Manual P1 | 1 | Terverifikasi di CI (10f5042, 52094d; run CI #8 lulus) |
| FR-GF-005 Skoring/Perfect/combo | T-1.5, T-1.7 | TP-1.5, TP-1.6, TP-1.17, TP-1.23, Manual P1 | 1 | Terverifikasi di CI (d5d68ca, 23cc967, 13bac49; run CI #8 dan #12 lulus); R-11 teratasi via ADR-011 (titik skor dari penetrasi; uji manual menyusul) |
| FR-GF-006 Soft camera zoom (v0.2) | T-1.6 | TP-1.20, Manual P1 | 1 | Terverifikasi di CI (9e07151; run CI #8 lulus; uji manual menyusul) |
| FR-LV-001 Level bertahap (dasar) | T-1.6, T-2.6 | TP-1.18, TP-1.19, TP-2.1 | 1-2 | Dasar terverifikasi di CI: 3 level dari data (9e07151; run CI #8 lulus) |
| FR-LV-002 Peta dunia | T-2.1 | Manual P2 | 2 | Belum |
| FR-LV-003 Target bergerak | T-2.2 | Manual P2 | 2 | Belum |
| FR-LV-004 Rintangan/puzzle | T-2.3 | Manual P2 | 2 | Belum |
| FR-LV-005 Golden Apple | T-2.4 | TP-2.2 | 2 | Belum |
| FR-LV-006 Boss Challenge | T-2.5 | TP-2.2, Manual P2 | 2 | Belum |
| FR-CH-001 Karakter/skill | T-3.1 | Manual P3 | 3 | Belum |
| FR-CH-002 Busur/panah | T-3.2 | Manual P3 | 3 | Belum |
| FR-CH-003 Koin | T-3.3 | TP-3.1 | 3 | Belum |
| FR-CH-004 Toko | T-3.4 | TP-3.1 | 3 | Belum |
| FR-CH-005 Upgrade/kosmetik | T-3.4, T-3.5 | TP-3.1 | 3 | Belum |
| FR-MD-001 Campaign | T-1.6, T-2.x | TP-2.1 | 1-2 | Belum (dasar arena ada; alur kampanye menyusul) |
| FR-MD-002 Time Attack | T-4.1 | TP-4.2, Manual P4 | 4 | Belum |
| FR-MD-003 Daily Challenge | T-4.2 | TP-4.1 | 4 | Belum |
| FR-MD-004 Rank/medali | T-4.3 | TP-4.2 | 4 | Belum |
| FR-MD-005 Statistik/pencapaian | T-4.4 | Manual P4 | 4 | Belum |
| FR-MD-006 Ghost Replay | T-5.1 | TP-5.2 | 5 | Belum |
| FR-MD-007 Challenge Code | T-5.2 | TP-5.1 | 5 | Belum |
| FR-MD-008 Local Multiplayer | T-5.3 | Manual P5 | 5 | Belum |
| FR-MD-009 Berbagi hasil | T-5.4 | Manual P5 | 5 | Belum |
| FR-AV-001 Animasi | T-6.1 | Manual P6 | 6 | Belum |
| FR-AV-002 Efek visual | T-6.1 | Manual P6 | 6 | Belum |
| FR-AV-003 Musik/SFX | T-6.2 | Manual P6 | 6 | Belum |
| FR-AV-004 Photo Mode | T-6.3 | Manual P6 | 6 | Belum |
| FR-AV-005 Tutorial | T-6.4 | Manual P6 | 6 | Belum |
| FR-AV-006 Aksesibilitas | T-6.5 | Manual P6 | 6 | Belum |
| FR-AV-007 Cartoon wind VFX (v0.2) | T-1.6 | TP-1.21, Manual P1 | 1 | Terverifikasi di CI (9e07151; run CI #8 lulus; uji manual menyusul) |
| FR-SY-001 Save offline | T-6.6 | TP-6.1 | 6 | Belum |
| FR-SY-002 Autosave/backup | T-6.6 | TP-6.1 | 6 | Belum |
| FR-SY-003 Performa rendah | T-6.7 | Manual P6/P7 (FPS) | 6-7 | Belum (low_effects dasar tersedia di T-1.6; T-1.7 menambahkannya pada HUD) |
| FR-DV-001 Identitas Naze | T-6.8 | Manual P6 | 6 | Belum |
| FR-DV-002 About/Credits | T-6.8 | Manual P6 | 6 | Belum |
| FR-DV-003 Changelog | T-6.8 | Manual P6 | 6 | Belum |
| FR-DV-004 Developer Console | T-6.9 | Manual P6 | 6 | Belum |
| FR-DV-005 Physics Lab | T-6.9 | Manual P6 | 6 | Belum |
| FR-DV-006 Debug Overlay | T-6.9 | Manual P6 | 6 | Belum |
| FR-QA-001 Tes otomatis | T-1.8, T-1.9 | Log CI | 1 | Terealisasikan: workflow ci.yml Godot 4.3-stable (8109893..1b954a0); run CI #8 lulus (TP-1.1..1.22, 111 lulus/0 gagal); T-1.7 memperluas ke TP-1.1..TP-1.24 — run CI #12 (74cded1) lulus, 24/24 kelompok, 0 gagal; T-1.9 penyempurnaan cakupan lanjutan menyusul |
| FR-QA-002 Regresi | T-7.1 | Log CI | 7 | Belum (dasar: CI berjalan pada setiap push sejak T-1.8) |
| FR-QA-003 Build APK | T-7.3 | Artefak workflow | 7 | Belum |
| FR-QA-004 Verifikasi APK | T-7.4 | Catatan manual | 7 | Belum |
