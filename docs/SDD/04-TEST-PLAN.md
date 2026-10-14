# Apple Archery — Test Plan

Versi: 0.1.8 (T-6.10: TP-6.2 kontrak splash "Archery Signature"/menu placeholder ditambahkan dan tereksekusi di CI pada commit b9d11ab; checklist manual splash ditambahkan)

## 1. Strategi

1. Pengujian otomatis dijalankan GitHub Actions pada setiap push dan pull request.
2. Prioritas pengujian otomatis pada modul murni (fisika, skoring, save, ekonomi) karena runner CI tidak memiliki GPU.
3. Pengujian visual dan gameplay dilakukan manual pada perangkat dan dicatat dalam laporan fase.
4. APK diverifikasi secara manual (install, smoke test) dengan temuan tercatat.

## 2. Pengujian Otomatis (direncanakan per Phase)

### Status eksekusi CI (T-1.8)

TP-1.1 s.d. TP-1.24 tereksekusi di GitHub Actions (workflow ci.yml, Godot 4.3-stable eksplisit, ubuntu-24.04). Bukti: run CI #8 pada commit 1b954a0 (22/22 kelompok, 111 pemeriksaan lulus, 0 gagal) dan run CI #12 pada commit 74cded1 (24/24 kelompok tereksekusi, 0 gagal; job "Headless import, parse check, and tests" succeeded); import resource headless dan parse check seluruh berkas .gd lulus. Riwayat run #1..#7 (kegagalan dan perbaikannya) tercatat pada catatan T-1.8 di 03-BACKLOG.md. Catatan transparansi: run CI untuk commit 34518a1 gagal di gerbang keterlacakan karena run_tests.gd belum memuat TP-1.24 pada commit tersebut (kesenjangan sementara antar commit, ditutup pada 74cded1); kegagalan tersebut tidak disembunyikan. T-6.10 (ADR-012): TP-6.2 (kontrak splash/menu) ditambahkan dan tereksekusi pada run CI untuk commit b9d11ab — job "Headless import, parse check, and tests" succeeded (18 s); gerbang keterlacakan kini mewajibkan 24 grup TP-1.x dan TP-6.2 tereksekusi dengan 0 kegagalan.

### Phase 1 (fisika, skoring, bidik, level, presentasi murni)
- TP-1.1 BallisticsModel: lintasan tanpa angin cocok dengan solusi analitik parabola (toleransi batas metode 0.5*|g|*dt*t ditambah margin numerik 0.001 untuk akumulasi float32 Vector2 Godot).
- TP-1.2 BallisticsModel: drag mengurangi jangkauan dibanding tanpa drag.
- TP-1.3 BallisticsModel: angin arah positif/negatif menggeser titik impact sesuai tanda.
- TP-1.4 Prediksi lintasan: titik pertama sama dengan posisi awal; jumlah titik sesuai konfigurasi.
- TP-1.5 Skoring: zona pusat > zona tepi; Perfect Shot terdeteksi pada pusat; tiap zona memberi poin sesuai ADR-009; titik di luar target tidak menghasilkan skor.
- TP-1.6 Combo: bertambah pada hit berturut-turut; reset saat meleset; best combo dicatat; multiplier sesuai ADR-009.
- TP-1.7 AimController: begin_aim di dalam area berhasil; status aiming aktif; drag awal nol.
- TP-1.8 AimController: power dan arah kontinu mengikuti input; arah tembakan berlawanan arah tarikan; release mengakhiri status aiming.
- TP-1.9 AimController: tarikan melewati batas maksimum dikunci pada power 1.0 dan kecepatan maksimum; arah tetap benar.
- TP-1.10 AimController: pembatalan mengembalikan status idle; release setelah batal tidak menghasilkan tembakan.
- TP-1.11 AimController: sentuhan di luar area permainan ditolak; release tanpa menarik mengembalikan hasil kosong.
- TP-1.12 CollisionService: swept collision menangkap panah cepat yang dilewatkan cek diskret pada titik ujung.
- TP-1.13 CollisionService: titik impact adalah titik masuk pertama segmen ke lingkaran; segmen di belakang/jauh tidak mengenai; target pertama sepanjang jalur dipilih.
- TP-1.14 Arrow: posisi node konsisten dengan BallisticsModel pada timestep tetap (simulasi independen identik); advance dipanggil per frame sesuai kontrak MAX_FRAME_DELTA.
- TP-1.15 Arrow: panah menancap pada titik impact (titik masuk pertama), sinyal hit_target terbit, panah tidak bergerak lagi.
- TP-1.16 Arrow: peluncuran kecepatan nol ditolak; peluncuran ulang saat terbang ditolak; reset mengembalikan status siap; advance saat idle diabaikan.
- TP-1.17 ScoringService/Target: batas antarzona inklusif; tepi luar target dihitung; skor dari titik penetrasi ujung panah (ADR-011: tembakan horizontal melalui pusat menghasilkan Perfect 50; titik masuk hanya menentukan target dan arah datang); panah STUCK tanpa skor kedua; multi-target: target pertama jalur yang dinilai; id target tidak cocok tidak menghasilkan skor.
- TP-1.18 LevelData: 3 level termuat dari JSON; id unik dan berurutan; parameter (wind, drag, arrow_count, target) terurai benar; urutan dan id target dipertahankan.
- TP-1.19 LevelData: data tidak valid ditolak (id kosong, tanpa target, arrow_count < 1, radius target tidak valid, berkas hilang) — fail-fast.
- TP-1.20 ArenaCamera (FR-GF-006): zoom tujuan saat bidik/kembali normal; konvergensi mulus; langkah satu frame kecil (tanpa gerakan mendadak); nilai dijepit batas.
- TP-1.21 WindVFX (FR-AV-007): angin nol tanpa goresan; intensitas dan arah mengikuti vektor angin fisika; intensitas terkunci 1.0 di atas batas; arah mengikuti tanda; low_effects mengurangi jumlah goresan.
- TP-1.22 TrajectoryPreview: titik identik dengan BallisticsModel.predict_trajectory untuk parameter sama (tidak ada fisika duplikat); low_effects mengurangi jumlah titik; toggle enabled menghapus titik.
- TP-1.23 ScoringService/CollisionService (regresi ADR-011): titik masuk collision tidak otomatis menentukan skor akhir; penetrasi mengarah ke pusat menghasilkan Perfect (50); penetrasi dangkal menghasilkan zona luar (10); tembakan dari arah berlawanan simetris; tabrakan tangensial/arah nol dinilai dari titik masuk (tepi, inklusif); tembakan meleset tidak menghasilkan skor; satu panah tepat satu skor; target pertama sepanjang jalur konsisten.
- TP-1.24 ArenaHUD (T-1.7, logika murni): arah angin 8 sektor sesuai konvensi y-up fisika ("•" saat tenang, timur/barat/utara/diagonal); rasio daya dijepit 0..1; teks umpan balik benar untuk Perfect ("PERFECT +50"), combo ("+20  x3"), hit biasa ("+10"), dan meleset ("Meleset!").
- TP-6.2 Splash/MainMenu (T-6.10, ADR-012, kontrak): durasi total garis waktu 2.5 s; batas antarfase (background/bow/arrow/target/title/hold) tepat; fase terdefinisi untuk semua nilai waktu (dijepit); tidak ada transisi sebelum garis waktu selesai (anti-skip/anti-prematur); transisi hanya diizinkan pada/setelah selesai; path tujuan transisi = scene menu utama; scene splash dan menu termuat headless; menu placeholder tidak mengekspos navigasi; splash dikonfigurasi sebagai main scene proyek (ProjectSettings).

### Koreksi pengujian pada T-1.8 (berbasis bukti run CI; bukan pelemahan tes)

1. TP-1.1: margin toleransi 1e-6 diganti 0.001 — akumulasi pembulatan float32 Vector2 Godot melebihi margin lama; batas galat metode (0.5*|g|*dt*t = 0.049) dipertahankan sehingga tes tetap membedakan integrator benar dari salah.
2. TP-1.14/TP-1.15: simulasi dijalankan sebagai advance per frame (30 frame @ 1/60 s). Kontrak Arrow membatasi delta per panggilan pada MAX_FRAME_DELTA = 0.25 s; panggilan tunggal advance(0.5) hanya mensimulasikan 0.25 s. TP-1.15 memakai lintasan lurus (gravitasi nol) agar geometri deterministik — target versi lama (12, 0) tidak dilewati lintasan melengkung (panah turun ~1.2 m pada 12 m); integritas stick tidak bergantung gravitasi. Pemeriksaan titik menancap ditambahkan (titik masuk pertama x = 11.5, toleransi 1 mm float32).
3. TP-1.15: penangkapan sinyal via lambda — lambda GDScript menangkap variabel lokal secara nilai sehingga penetapan ulang tidak terlihat dari luar; diganti mutasi Array yang ditangkap.
4. TP-1.17: titik uji "just outside middle boundary" dikoreksi (5 + 2.0 + 0.001, bukan 5 + 2/3 + 0.001 — titik lama berada di dalam zona pusat). Ekspektasi skor dari titik masuk pertama diselaraskan dengan ADR-009: titik masuk pertama lingkaran selalu tepat di tepi (d = radius) sehingga zona terluar (10 poin, bukan perfect); diperkuat kontras bahwa posisi akhir di luar target tidak menghasilkan skor. score_hit membutuhkan id target sehingga tes memakai segment_targets_first_hit (seperti jalur gameplay); segment_circle_first_hit tunggal tidak menyertakan id.
5. Temuan desain dari TP-1.17 (bukan cacat implementasi; lihat R-11 di 06-RISKS.md): titik impact swept pada target lingkaran selalu di tepi; zona tengah/pusat tidak tercapai dari tembakan gameplay aktual di bawah ADR-009. Menunggu keputusan desain pengguna.
6. T-1.7 (ADR-011): ekspektasi TP-1.17 diperbarui dari titik masuk pertama (tepi, 10 poin) ke titik penetrasi (tembakan melalui pusat menghasilkan Perfect 50) — perubahan ekspektasi yang dijustifikasi oleh ADR-011 yang disetujui pemilik proyek, bukan pelemahan tes. TP-1.23 (regresi penetrasi) dan TP-1.24 (logika murni HUD) ditambahkan; gerbang keterlacakan CI diperbarui ke 24 kelompok.

Catatan TP-1.18 s.d. TP-1.22 (ditambahkan pada T-1.6): AC FR-GF-006 dan FR-AV-007 (baru, spesifikasi v0.2) serta AC dasar FR-LV-001 (level dari data) memerlukan metode pengujian otomatis. Penambahan metode pengujian dan requirement presentasi murni; logika simulasi tidak berubah.

Catatan TP-1.12 s.d. TP-1.16 (ditambahkan pada T-1.4): AC FR-GF-003 memerlukan metode pengujian otomatis. Penambahan metode pengujian, bukan perubahan requirement.

Catatan TP-1.7 s.d. TP-1.11 (ditambahkan pada T-1.3): AC FR-GF-001 memerlukan metode pengujian otomatis. Penambahan metode pengujian, bukan perubahan requirement.

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
- Soft camera zoom terasa halus, target tetap terlihat, kembali normal setelah tembakan/batal.
- Wind VFX mengikuti arah angin level dan tidak menutupi target/zona/panah.
- Trajectory preview akurat terhadap lintasan aktual dan dapat dinonaktifkan.
- Mode efek rendah terlihat lebih hemat tanpa merusak keterbacaan.
- FPS stabil pada perangkat target (dicatat angka).
- Audio tidak terpotong; volume pengaturan berfungsi.
- Multiplayer lokal: input dua pemain tidak bertukar.
- Aksesibilitas: pengaturan diterapkan tanpa restart bila mungkin.
- Splash (T-6.10): enam fase animasi berjalan halus total ~2.5 s; tidak dapat dilewati oleh sentuhan/klik/tombol; transisi ke menu utama tepat satu kali; judul dan kredit terbaca pada rasio layar berbeda; waktu startup dan pemakaian memori wajar pada perangkat Android target; kegagalan memuat scene tujuan menampilkan error yang jelas.

## 4. Gerbang Mutu

- Setiap fase lulus pengujian otomatis dan checklist manual sebelum lanjut.
- Setiap klaim keberhasilan harus disertai bukti: log CI, nomor eksekusi workflow, atau catatan manual.
- CI wajib hijau pada main sebelum tugas gameplay baru dimulai (berlaku sejak T-1.8).

## 5. Keterbatasan Lingkungan

- Lingkungan pengembangan saat ini (via HP) tidak dapat menjalankan Godot lokal, pengujian runtime, atau build manual. Verifikasi runtime otomatis tersedia via CI (sejak T-1.8); aspek visual/gameplay tetap memerlukan uji manual terdokumentasi. Keterbatasan ini dilaporkan pada setiap laporan fase.
