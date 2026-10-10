# Apple Archery — Decision Records (ADR)

## ADR-001: Godot 4.x + GDScript
Status: Diterima (baseline)
Konteks: Target Android, pengembangan via HP, build otomatis wajib.
Keputusan: Godot 4.x dengan GDScript; ekspor Android melalui GitHub Actions.
Konsekuensi: Tidak dapat menjalankan Godot secara lokal di HP; seluruh verifikasi bergantung pada CI. Ekspor memerlukan template Android dan keystore yang dikelola melalui GitHub Secrets.

## ADR-002: Logika fisika terpisah dari scene
Status: Diterima (baseline)
Keputusan: BallisticsModel ditulis sebagai kelas murni GDScript (RefCounted) agar dapat diuji headless tanpa scene. Node Arrow hanya menjalankan integrasi yang diberikan model. TrajectoryPreview juga memakai predict_trajectory, bukan rumus duplikat.
Alasan: Pengujian otomatis di CI tanpa GPU/loop render.

## ADR-003: Data-driven untuk level
Status: Diterima (baseline; direalisasikan T-1.6)
Keputusan: Level didefinisikan sebagai data (JSON: assets/levels/levels.json), bukan scene per level. Scene arena tunggal dengan parameter. Loader fail-fast: satu level tidak valid menolak seluruh berkas.
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
Status: Disetujui sementara oleh pengguna (instruksi T-1.6): nilai 50/20/10, Perfect Shot pada zona pusat, batas zona inklusif ke zona dalam, rumus combo diusulkan tetap dapat dikonfigurasi per level.
Konteks: Spec FR-GF-005 hanya mengamanatkan "zona pusat memberi skor lebih tinggi" dan "combo bertambah pada tembakan berturut-turut yang berhasil"; nilai konkret tidak diatur di dokumen SDD lain.
Keputusan (data, dapat diubah per level tanpa mengubah requirement):
1. Target = lingkaran konsentris; zona dinyatakan sebagai fraksi radius (0..1]; 3 zona bawaan dengan fraksi 1/3, 2/3, 1.0 dan poin 50, 20, 10 (zone_points dapat dioverride per target di data level).
2. Perfect Shot = tembakan pada zona 0 (pusat).
3. Batas antarzona inklusif terhadap zona dalam: jarak <= radius zona menghasilkan zona tersebut.
4. Combo: penghitung tembakan berturut-turut yang berhasil; reset saat meleset; multiplier combo = 1 + 0.25 * (combo - 1) untuk combo >= 2; best_combo dicatat.
Kasus diatur: panah STUCK tidak menghasilkan skor baru; target terkena lebih dari sekali tidak mungkin pada T-1.5 (panah menancap; target bergerak: Phase 2); beberapa target satu langkah: target pertama sepanjang jalur (t terkecil) yang dinilai.

## ADR-010: Kamera dan VFX hanya presentasi (T-1.6)
Status: Diterima (persetujuan pengguna dalam instruksi T-1.6)
Konteks: Pengguna meminta soft camera zoom saat membidik dan cartoon wind VFX sebagai bagian T-1.6.
Keputusan:
1. ArenaCamera dan WindVFX adalah komponen presentasi; keduanya tidak boleh mengubah kecepatan, arah, skor, collision, atau hasil simulasi panah (dijaga oleh pemisahan antarmuka: keduanya hanya menerima status bidik / vektor angin).
2. Logika zoom dan pemetaan visual angin diimplementasikan sebagai fungsi murni yang dapat diuji tanpa rendering (compute_zoom_target/compute_zoom_step; compute_visual_params).
3. Wind VFX membaca parameter angin dari model fisika yang sama (wind Vector2 m/s level aktif); tidak ada sistem angin visual terpisah.
4. low_effects tersedia pada VFX dan preview (pengurangan goresan/titik) untuk perangkat terbatas; z_index VFX di bawah gameplay agar tidak menutupi target, zona, atau panah.
5. Kebutuhan ini dicatat sebagai requirement baru FR-GF-006 dan FR-AV-007 (perubahan spesifikasi v0.2).
Konsekuensi: Scope resmi bertambah dua requirement presentasi; tidak ada dampak pada logika simulasi; pengujian otomatis menutupi fungsi murni, verifikasi visual manual terdokumentasi.
