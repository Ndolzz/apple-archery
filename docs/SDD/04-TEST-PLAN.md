# Apple Archery — Test Plan

Versi: 0.1 (Baseline)

## 1. Strategi

1. Pengujian otomatis dijalankan GitHub Actions pada setiap push dan pull request.
2. Prioritas pengujian otomatis pada modul murni (fisika, skoring, save, ekonomi) karena runner CI tidak memiliki GPU.
3. Pengujian visual dan gameplay dilakukan manual pada perangkat dan dicatat dalam laporan fase.
4. APK diverifikasi secara manual (install, smoke test) dengan temuan tercatat.

## 2. Pengujian Otomatis (direncanakan per Phase)

### Phase 1 (fisika dan skoring)
- TP-1.1 BallisticsModel: lintasan tanpa angin cocok dengan solusi analitik parabola (toleransi).
- TP-1.2 BallisticsModel: drag mengurangi jangkauan dibanding tanpa drag.
- TP-1.3 BallisticsModel: angin arah positif/negatif menggeser titik impact sesuai tanda.
- TP-1.4 Prediksi lintasan: titik pertama sama dengan posisi awal; jumlah titik sesuai konfigurasi.
- TP-1.5 Skoring: zona pusat > zona tepi; Perfect Shot terdeteksi pada pusat.
- TP-1.6 Combo: bertambah pada hit berturut-turut; reset saat meleset.

### Phase 2-6
- TP-2.1 Pemuatan data level: semua level valid (target ada, parameter dalam rentang).
- TP-2.2 Golden Apple dan Boss terpilih pada level yang benar.
- TP-3.1 Ekonomi: pembelian mengurangi koin; item tidak dapat dibeli dua kali.
- TP-4.1 Daily Challenge: seed sama menghasilkan level sama.
- TP-4.2 Rank dan medali dihitung benar dari skor.
- TP-5.1 Challenge Code: enkode-dekode round-trip identik.
- TP-5.2 Ghost Replay: replay menghasilkan lintasan yang sama (deterministik).
- TP-6.1 Save: simpan-muat round-trip; migrasi versi; restore backup.

## 3. Pengujian Manual (checklist per fase)

- Tarikan busur responsif pada layar sentuh.
- FPS stabil pada perangkat target (dicatat angka).
- Audio tidak terpotong; volume pengaturan berfungsi.
- Multiplayer lokal: input dua pemain tidak bertukar.
- Aksesibilitas: pengaturan diterapkan tanpa restart bila mungkin.

## 4. Gerbang Mutu

- Setiap fase lulus pengujian otomatis dan checklist manual sebelum lanjut.
- Setiap klaim keberhasilan harus disertai bukti: log CI, nomor eksekusi workflow, atau catatan manual.

## 5. Keterbatasan Lingkungan

- Lingkungan pengembangan saat ini (via HP) tidak dapat menjalankan Godot lokal, pengujian runtime, atau build manual. Seluruh verifikasi dijalankan di CI atau manual terdokumentasi. Keterbatasan ini dilaporkan pada setiap laporan fase.
