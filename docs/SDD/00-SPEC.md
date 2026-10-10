# Apple Archery — Spesifikasi (SDD)

Versi: 0.2 (T-1.6: FR-GF-006 dan FR-AV-007 ditambahkan atas permintaan pengguna; ADR-009 disetujui sementara dengan konfigurasi per level)
Status: Draft; Phase 1 berjalan bertahap.

## 1. Ringkasan Produk

Apple Archery adalah game panahan 2D bergaya kartun modern, dibangun dengan Godot 4.x dan GDScript, ditargetkan utama ke Android. Pengembangan dilakukan melalui perangkat seluler, sehingga seluruh verifikasi berjalan melalui GitHub Actions (pengujian otomatis dan build APK). Identitas developer: Naze.

## 2. Lingkup

Semua fitur di bawah tercatat dalam spesifikasi ini dan backlog. Implementasi dilakukan bertahap per Phase 0-7. Fitur tidak dihapus dari spesifikasi hanya karena belum diimplementasi.

## 3. Requirements

Setiap requirement memiliki ID, acceptance criteria (AC), tugas implementasi (lihat BACKLOG), dan metode pengujian (lihat TEST-PLAN dan TRACEABILITY).

### GF — Gameplay dan Fisika

- FR-GF-001 Tarikan busur: pemain menahan dan menarik untuk menetapkan sudut dan kekuatan tembakan.
  - AC: Nilai kekuatan dan sudut berubah secara kontinu mengikuti input; pelepasan menghasilkan tembakan.
- FR-GF-002 Fisika proyektil realistis: gravitasi, hambatan udara (drag), dan angin memengaruhi lintasan panah.
  - AC: Lintasan terukur konsisten dengan model fisika yang ditetapkan; parameter angin dapat diatur per level.
- FR-GF-003 Collision detection antara panah, target, rintangan, dan area permainan.
  - AC: Panah menempel pada target sesuai titik impact; tidak menembus rintangan.
- FR-GF-004 Prediksi lintasan (trajectory hint) yang dapat diaktifkan/dinonaktifkan.
  - AC: Garis prediksi memperhitungkan gravitasi dan angin saat aktif; dihitung melalui BallisticsModel, bukan rumus duplikat.
- FR-GF-005 Skoring berbasis zona target, Perfect Shot, dan combo.
  - AC: Zona pusat memberi skor lebih tinggi; Perfect Shot terdeteksi; combo bertambah pada tembakan berturut-turut yang berhasil. Nilai zona dan rumus combo mengikuti ADR-009 (dapat dikonfigurasi per level).
- FR-GF-006 Soft Camera Zoom saat membidik (ditambahkan T-1.6 atas permintaan pengguna; presentasi saja).
  - AC: Saat membidik, kamera zoom-in halus dengan fokus visual pada anak panah; target tetap terlihat; tanpa gerakan mendadak; kembali ke tampilan normal setelah tembakan atau pembatalan bidikan; kamera tidak mengubah kecepatan, arah, skor, collision, atau hasil simulasi.

### LV — Level dan Kampanye

- FR-LV-001 Level bertahap dengan kesulitan meningkat. (Dasar T-1.6: level dari data JSON, satu scene arena.)
- FR-LV-002 Minimal 4 peta dunia berbeda (tema visual berbeda).
- FR-LV-003 Target bergerak (kecepatan dan pola gerak bervariasi).
- FR-LV-004 Rintangan dan elemen puzzle.
- FR-LV-005 Golden Apple pada setiap kelipatan 10 level.
- FR-LV-006 Boss Challenge setiap 50 level dengan mekanik khusus.

### CH — Karakter dan Ekonomi

- FR-CH-001 Karakter yang dapat dipilih dengan skill unik.
- FR-CH-002 Pilihan busur dan panah dengan atribut berbeda.
- FR-CH-003 Koin sebagai mata uang hasil bermain.
- FR-CH-004 Toko untuk membeli busur, panah, upgrade, dan kosmetik.
- FR-CH-005 Sistem upgrade dan kosmetik (kulit busur, panah, karakter).

### MD — Mode Permainan

- FR-MD-001 Mode Campaign (katalog level LV).
- FR-MD-002 Mode Time Attack (waktu terbatas, skor maksimum).
- FR-MD-003 Daily Challenge offline dengan seed tanggal.
- FR-MD-004 Rank, medali, dan papan hasil per level.
- FR-MD-005 Statistik dan pencapaian (achievements).
- FR-MD-006 Ghost Replay dari replay panahan terbaik.
- FR-MD-007 Challenge Code: berbagi level/ tantangan lewat kode.
- FR-MD-008 Local Multiplayer dua pemain pada satu perangkat.
- FR-MD-009 Berbagi hasil (teks/gambar) ke aplikasi lain.

### AV — Audio dan Visual

- FR-AV-001 Animasi karakter, busur, dan panah bergaya kartun modern.
- FR-AV-002 Efek visual (impact, trail, partikel, feedback Perfect Shot).
- FR-AV-003 Musik latar dan sound effect.
- FR-AV-004 Photo Mode untuk menangkap momen permainan.
- FR-AV-005 Tutorial interaktif untuk mekanik dasar.
- FR-AV-006 Pengaturan aksesibilitas (ukuran UI, kontras, reduksi gerak, kontrol alternatif).
- FR-AV-007 Cartoon Wind VFX (ditambahkan T-1.6 atas permintaan pengguna; presentasi saja).
  - AC: Efek angin 2D bergaya kartun (garis lengkung/partikel/daun) mengikuti arah dan intensitas dari parameter angin model fisika yang sama, bukan sistem angin visual terpisah; efek tidak menutupi target, zona skor, atau panah; tersedia pengaturan efek rendah untuk perangkat terbatas; VFX tidak mengubah hasil simulasi.

### SY — Sistem dan Penyimpanan

- FR-SY-001 Penyimpanan progres offline (save game lokal).
- FR-SY-002 Autosave dan backup progres yang dapat dipulihkan.
- FR-SY-003 Pengaturan performa untuk perangkat berspesifikasi rendah.

### DV — Identitas dan Alat Developer

- FR-DV-001 Identitas developer Naze pada tampilan game.
- FR-DV-002 Halaman About dan Credits.
- FR-DV-003 Changelog.
- FR-DV-004 Developer Console.
- FR-DV-005 Physics Lab (peraga dan pengaturan parameter fisika).
- FR-DV-006 Debug Overlay.

### QA — Pengujian dan Build

- FR-QA-001 Pengujian otomatis melalui GitHub Actions (headless Godot).
- FR-QA-002 Pengujian regresi per rilis fitur.
- FR-QA-003 Build APK melalui GitHub Actions.
- FR-QA-004 Verifikasi APK yang dihasilkan (install dan smoke test manual terdokumentasi).

## 4. Non-Functional Requirements

- NFR-001 Performa: target stabil pada perangkat kelas menengah ke bawah; mode performa tersedia.
- NFR-002 Kualitas kode: modular, mudah dirawat, tanpa dependensi berlebihan.
- NFR-003 Keamanan: tidak ada kredensial dalam repositori.
- NFR-004 Aksesibilitas: pengaturan FR-AV-006 wajib tersedia sejak Phase 5.

## 5. Out of Scope (Baseline)

- Multiplayer daring (online). Local Multiplayer tetap dalam lingkup.
- Iklan dan pembelian dalam aplikasi (belum diputuskan, lihat ADR-007).

## 6. Riwayat Perubahan Spesifikasi

- v0.2 (T-1.6): FR-GF-006 (Soft Camera Zoom) dan FR-AV-007 (Cartoon Wind VFX) ditambahkan atas permintaan dan persetujuan eksplisit pengguna dalam instruksi T-1.6; keduanya presentasi saja (tidak mengubah simulasi). FR-GF-004 diperjelas: prediksi harus melalui BallisticsModel. FR-GF-005 diperjelas: mengikuti ADR-009 (disetujui sementara pengguna; konfigurasi per level).
