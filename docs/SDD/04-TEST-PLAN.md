# Apple Archery — Test Plan

Versi: 0.1.3 (TP-1.17 ditambahkan pada T-1.5; nilai zona mengikuti ADR-009)

## 1. Strategi

1. Pengujian otomatis dijalankan GitHub Actions pada setiap push dan pull request.
2. Prioritas pengujian otomatis pada modul murni (fisika, skoring, save, ekonomi) karena runner CI tidak memiliki GPU.
3. Pengujian visual dan gameplay dilakukan manual pada perangkat dan dicatat dalam laporan fase.
4. APK diverifikasi secara manual (install, smoke test) dengan temuan tercatat.

## 2. Pengujian Otomatis (direncanakan per Phase)

### Phase 1 (fisika, skoring, dan bidik)
- TP-1.1 BallisticsModel: lintasan tanpa angin cocok dengan solusi analitik parabola (toleransi).
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
- TP-1.13 CollisionService: titik impact adalah titik masuk pertama segmen ke lingkaran (bukan titik terdalam); segmen di belakang atau jauh dari target tidak mengenai; target pertama sepanjang jalur dipilih.
- TP-1.14 Arrow: posisi node konsisten dengan BallisticsModel pada timestep tetap (simulasi independen identik).
- TP-1.15 Arrow: panah menancap pada titik impact, sinyal hit_target terbit, panah tidak bergerak lagi setelah menancap.
- TP-1.16 Arrow: peluncuran kecepatan nol ditolak; peluncuran ulang saat terbang ditolak; reset mengembalikan status siap; advance saat idle diabaikan.
- TP-1.17 ScoringService/Target: batas antarzona inklusif terhadap zona dalam; tepi luar target (d == radius) tetap dihitung; skor dihitung dari titik masuk pertama collision (bukan posisi akhir panah); panah STUCK tidak menghasilkan skor/kedua; beberapa target satu langkah: target pertama sepanjang jalur yang dinilai; id target tidak cocok tidak menghasilkan skor.

Catatan TP-1.17 (ditambahkan pada T-1.5): AC FR-GF-005 mengenai pencegahan skor ganda dan batas zona memerlukan metode pengujian otomatis. Penambahan metode pengujian, bukan perubahan requirement. Nilai zona mengikuti ADR-009 (menunggu persetujuan pengguna).

Catatan TP-1.12 s.d. TP-1.16 (ditambahkan pada T-1.4): acceptance criteria FR-GF-003 (collision, panah menempel) memerlukan metode pengujian otomatis. Ini penambahan metode pengujian, bukan perubahan requirement.

Catatan TP-1.7 s.d. TP-1.11 (ditambahkan pada T-1.3): acceptance criteria FR-GF-001 (kontinuitas tarikan, batas maksimum, pembatalan, sentuhan di luar area) memerlukan metode pengujian otomatis karena sebelumnya hanya tercantum pengujian manual. Ini penambahan metode pengujian, bukan perubahan requirement.

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
