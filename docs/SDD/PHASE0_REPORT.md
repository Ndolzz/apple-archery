# Laporan Phase 0 — Audit dan Baseline SDD

Tanggal: 2026-10-10
Repository: Ndolzz/apple-archery
Status: Menunggu persetujuan untuk Phase 1.

## 1. Hasil Audit Repositori

- Repositori ada dan dapat diakses, tetapi sepenuhnya kosong: tidak ada branch, tidak ada commit, tidak ada file.
- Tidak ada kode, konfigurasi, CI, atau keputusan sebelumnya yang perlu dipertahankan atau diaudit.
- Tidak ada risiko penimpaan pekerjaan yang sudah ada karena tidak ada pekerjaan sebelumnya (ADR-008).

## 2. Dokumen yang Dibuat

- docs/SDD/00-SPEC.md — spesifikasi dengan ID requirement dan acceptance criteria (GF, LV, CH, MD, AV, SY, DV, QA, NFR).
- docs/SDD/01-ARCHITECTURE.md — arsitektur dan struktur proyek.
- docs/SDD/02-DECISIONS.md — delapan decision records.
- docs/SDD/03-BACKLOG.md — task breakdown Phase 0-7, seluruh fitur tercatat.
- docs/SDD/04-TEST-PLAN.md — pengujian otomatis dan manual per fase.
- docs/SDD/05-TRACEABILITY.md — matrix requirement -> tugas -> pengujian.
- docs/SDD/06-RISKS.md — register risiko beserta mitigasi.
- docs/SDD/PHASE0_REPORT.md — laporan ini.
- README.md — ringkasan proyek.

## 3. Keterbatasan Lingkungan

- Pengembangan dilakukan melalui HP: Godot tidak dapat dijalankan secara lokal pada lingkungan ini. Tidak ada pengujian runtime yang dijalankan pada Phase 0. Verifikasi build dan pengujian dijalankan melalui GitHub Actions mulai Phase 1.
- Tidak ada pengujian yang dilakukan pada Phase 0 karena belum ada kode; ini adalah fase dokumentasi saja.

## 4. Risiko Utama

- R-01 dan R-02: verifikasi sepenuhnya bergantung CI; build APK Godot di Actions kompleks.
- R-04: lingkup fitur sangat besar; mitigasi utama adalah disiplin fase dan vertical slice.

## 5. Rencana Tugas Pertama (Phase 1 — Vertical Slice)

1. T-1.1 Inisialisasi proyek Godot 4.x beserta struktur folder.
2. T-1.2 BallisticsModel murni (gravitasi, drag, angin, prediksi lintasan) dengan pengujian TP-1.1 sampai TP-1.4.
3. T-1.3 sampai T-1.7: input tarikan, panah dan collision, target dengan zona skor, arena dengan 3 level data-driven, HUD minimal.
4. T-1.8 Workflow GitHub Actions pengujian headless.
5. Gerbang: demonstrasi vertical slice sebelum lanjut ke Phase 2.

## 6. Persetujuan

Tidak ada implementasi Phase 1 yang dimulai. Menunggu persetujuan pengguna sebelum eksekusi.
