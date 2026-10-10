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

## ADR-009: Nilai zona skor dan aturan combo (T-1.5)
Status: Diterima sementara — menunggu persetujuan pengguna
Konteks: Spec FR-GF-005 hanya mengamanatkan "zona pusat memberi skor lebih tinggi" dan "combo bertambah pada tembakan berturut-turut yang berhasil"; nilai konkret tidak diatur di dokumen SDD mana pun.
Keputusan (data, dapat diubah tanpa mengubah requirement):
1. Target = lingkaran konsentris; zona dinyatakan sebagai fraksi radius (0..1]; 3 zona bawaan dengan fraksi 1/3, 2/3, 1.0 dan poin 50, 20, 10.
2. Perfect Shot = tembakan pada zona 0 (pusat).
3. Batas antarzona inklusif terhadap zona dalam: jarak <= radius zona menghasilkan zona tersebut (konsisten dengan collision yang menerima titik tepat pada batas target).
4. Combo: penghitung tembakan berturut-turut yang berhasil; reset saat meleset; multiplier combo = 1 + 0.25 * (combo - 1) untuk combo >= 2; best_combo dicatat.
Kasus diatur/didokumentasikan: panah STUCK tidak menghasilkan skor baru (Arrow.advance kosong saat tidak FLYING); target terkena lebih dari sekali tidak mungkin pada T-1.5 karena panah menancap pada hit pertama (target bergerak: Phase 2); beberapa target satu langkah: target pertama sepanjang jalur (t terkecil) yang dinilai.
Alasan: Memenuhi AC FR-GF-005 tanpa mengarang aturan yang bertentangan; seluruh nilai adalah data per level sehingga dapat disetel ulang tanpa perubahan kode.
Dampak: Tidak mengubah requirement; apabila pengguna menolak nilai ini, hanya konstanta Target/ScoringService yang berubah.
