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

## ADR-011: Skor dari kedalaman penetrasi ujung panah (T-1.7)
Status: Disetujui pemilik proyek (briefing T-1.7: keputusan desain untuk R-11)
Konteks: R-11 — dengan collision lingkaran dan skor dari titik masuk pertama (ADR-009), titik impact gameplay selalu tepat di tepi target (d = radius) sehingga tembakan nyata selalu mendapat zona terluar; zona tengah/pusat tidak pernah tercapai dari jalur gameplay normal.
Keputusan:
1. Swept collision tetap digunakan untuk mendeteksi tabrakan dan menentukan target yang terkena (titik masuk pertama; target pertama sepanjang jalur). Hasil hit menambah kunci "direction": arah segmen ternormalisasi (Vector2.ZERO bila degenerate).
2. Titik skor S = E + dhat * p dalam koordinat target, dengan E = titik masuk pertama, dhat = arah datang ternormalisasi, p = PENETRATION_FRACTION * L dijepit [0, L]; L = 2 * sqrt(r^2 - h^2) adalah panjang chord lingkaran target sepanjang garis tembakan, h = jarak tegak lurus garis tembakan ke pusat dihitung dari E. Target statis; zona konsentris ADR-009 (fraksi radius, batas inklusif ke zona dalam) tidak berubah.
3. PENETRATION_FRACTION = 0.5 (konstanta implementasi, bukan requirement): tembakan lurus melalui pusat menempatkan titik skor tepat di pusat sehingga Perfect Shot tercapai dari jalur gameplay normal, tanpa mengorbankan deteksi tabrakan cepat (swept tetap menangkap panah cepat). Konfigurasi per level ditunda ke Phase 2 (dicatat sebagai data).
4. Kasus batas: arah nol / tabrakan tangensial / titik masuk sudah di dalam target → S = E (tepi; zona terluar; batas inklusif ke zona dalam tetap berlaku); komponen arah maju <= 0 → S = E; tembakan dari arah berlawanan simetris terhadap geometri; panah STUCK tidak menghasilkan skor baru; satu panah maksimal menghasilkan satu skor.
5. Panah tetap menempel secara visual pada titik masuk E (FR-GF-003 tidak berubah); titik skor S hanya konsep penilaian.
6. Nilai ADR-009 dipertahankan penuh: zona 50/20/10 (fraksi 1/3, 2/3, 1.0), Perfect Shot = zona pusat, batas inklusif ke zona dalam, rumus combo 1 + 0.25 * (combo - 1) untuk combo >= 2.
Dampak API: CollisionService.segment_circle_first_hit mengembalikan "direction"; ScoringService.score_hit menghitung titik penetrasi via compute_penetration_point sebelum classify; classify tidak berubah. Ekspektasi TP-1.17 diperbarui (penetrasi, bukan tepi) dan TP-1.23 (regresi penetrasi) ditambahkan; TP-1.24 (logika murni HUD) ditambahkan pada T-1.7 yang sama.
Konsekuensi: Skor kini bergantung pada geometri penetrasi yang terdefinisi, bukan titik masuk semata. Verifikasi: run CI #12 (commit 74cded1) lulus — 24/24 kelompok TP tereksekusi, 0 gagal. Keseimbangan nilai skor (tembakan pusat menjadi lebih mudah dicapai) ditinjau saat uji perangkat manual.
