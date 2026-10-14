# Apple Archery — Spesifikasi (SDD)

Versi: 0.4 (T-6.10: FR-AV-008 Splash Screen "Archery Signature" ditambahkan atas permintaan pengguna; menu utama placeholder visual tanpa navigasi; riwayat pada bagian 6)
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
  - AC: Zona pusat memberi skor lebih tinggi; Perfect Shot terdeteksi; combo bertambah pada tembakan berturut-turut yang berhasil. Nilai zona dan rumus combo mengikuti ADR-009 (dapat dikonfigurasi per level). Titik skor ditentukan dari kedalaman penetrasi ujung panah ke dalam geometri target (ADR-011): tembakan yang mengarah ke pusat dapat mencapai zona pusat (Perfect Shot) dari jalur gameplay normal, sementara deteksi tabrakan tetap menggunakan swept collision pada titik masuk pertama.
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
- FR-AV-008 Splash Screen "Archery Signature" (ditambahkan T-6.10 atas permintaan pengguna; presentasi saja).
  - AC: Animasi pembukaan dengan urutan latar → siluet busur → jejak panah → target/apel → judul "Apple Archery" → penahanan singkat; total durasi sekitar 2.5 detik (rentang 2-3 detik); tidak dapat dilewati oleh input apa pun (sentuhan, klik, tombol); transisi menuju menu utama terjadi tepat satu kali setelah animasi selesai; kegagalan memuat scene tujuan menghasilkan error yang jelas; splash tidak menyentuh fisika, collision, skor, atau kontrol; menu utama saat ini placeholder visual tanpa navigasi (keputusan pemilik proyek; navigasi menyusul dengan persetujuan).

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
- v0.3 (T-1.7): FR-GF-005 diperjelas berdasarkan keputusan desain pemilik proyek untuk risiko R-11 (ADR-011): titik skor dihitung dari kedalaman penetrasi ujung panah ke dalam geometri target, bukan semata titik masuk pertama swept collision; swept collision tetap untuk deteksi dan pemilihan target; nilai zona/combo ADR-009 dipertahankan.
- v0.4 (T-6.10): FR-AV-008 (Splash Screen "Archery Signature") ditambahkan atas permintaan dan keputusan eksplisit pemilik proyek (tujuan transisi: menu utama placeholder visual tanpa navigasi; ID tugas baru di bawah Phase 6); perubahan alur startup (run/main_scene kini splash) tercatat pada ADR-012.
