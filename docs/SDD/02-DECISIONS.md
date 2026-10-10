# Apple Archery — Decision Records (ADR)

## ADR-001: Godot 4.x + GDScript
Status: Diterima (baseline)
Konteks: Target Android, pengembangan via HP, build otomatis wajib.
Keputusan: Godot 4.x dengan GDScript; ekspor Android melalui GitHub Actions.
Konsekuensi: Tidak dapat menjalankan Godot secara lokal di HP; seluruh verifikasi bergantung pada CI. Ekspor memerlukan template Android dan keystore yang dikelola melalui GitHub Secrets.

## ADR-002: Logika fisika terpisah dari scene
Status: Diterima (baseline)
Keputusan: BallisticsModel ditulis sebagai kelas murni GDScript (RefCounted) agar dapat diuji headless tanpa scene. Node Arrow hanya menjalankan integrasi yang diberikan model.
Alasan: Pengujian otomatis di CI tanpa GPU/loop render.

## ADR-003: Data-driven untuk level
Status: Diterima (baseline)
Keputusan: Level didefinisikan sebagai data (resource Godot/JSON), bukan scene per level. Scene arena tunggal dengan parameter.
Alasan: Mendukung puluhan level, Daily Challenge, dan Challenge Code tanpa duplikasi.

## ADR-004: Ghost Replay dan Challenge Code berbasis data
Status: Diterima (baseline)
Keputusan: Replay disimpan sebagai rangkaian input terkompresi (delta), bukan rekaman video. Challenge Code adalah string terenkode berisi parameter level.
Alasan: Ukuran kecil, offline, dapat dibagikan sebagai teks.

## ADR-005: CI build APK via GitHub Actions
Status: Diterima (baseline)
Keputusan: Workflow memakai container/workflow Godot export; keystore disimpan sebagai GitHub Secrets. Sebelum keystore tersedia, build APK debug tanpa tanda tangan.
Alasan: Pengembangan melalui HP tidak memungkinkan build lokal.

## ADR-006: Pengujian otomatis tanpa GPU
Status: Diterima (baseline)
Keputusan: Uji prioritas pada modul murni (fisika, skoring, save, ekonomi). Pengujian scene berjalan headless bila didukung runner.
Alasan: Runner CI tanpa GPU; tampilan diverifikasi manual terdokumentasi.

## ADR-007: Monetisasi (iklan/IAP)
Status: Ditunda
Keputusan: Tidak masuk baseline. Keputusan monetisasi ditunda hingga setelah Phase 4 agar tidak memengaruhi arsitektur awal.

## ADR-008: Cadangan keputusan sebelumnya
Status: Tidak ada.
Catatan: Repositori kosong saat baseline dibuat; tidak ada keputusan sebelumnya yang perlu dipertahankan atau dibatalkan.
