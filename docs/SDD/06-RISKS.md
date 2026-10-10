# Apple Archery — Register Risiko

Versi: 0.3 (diperbarui pada T-1.7: R-11 teratasi via ADR-011 yang disetujui pemilik proyek)

| ID | Risiko | Dampak | Kemungkinan | Mitigasi |
|---|---|---|---|---|
| R-01 | Pengembangan via HP: tidak ada verifikasi runtime lokal | Tinggi | Pasti | Termitigasi sebagian sejak T-1.8: seluruh TP-1.x tereksekusi di CI pada setiap push; uji manual terdokumentasi tetap wajib untuk aspek visual/gameplay; jangan klaim berjalan tanpa bukti |
| R-02 | Build APK Godot di GitHub Actions kompleks (template, keystore, waktu build) | Tinggi | Tinggi | Mulai dari APK debug tanpa tanda tangan; keystore via Secrets; caching template export |
| R-03 | Pengujian scene/GUI di CI tanpa GPU | Sedang | Tinggi | Uji modul murni; checklist manual; uji headless terbatas |
| R-04 | Lingkup fitur sangat besar dibanding ritme pengembangan | Tinggi | Tinggi | SDD bertahap; vertical slice dulu; backlog menahan sisa fitur |
| R-05 | Aset visual/audio belum tersedia (kartun modern) | Sedang | Tinggi | Placeholder sederhana pada awal fase; aset final sebelum Phase 7 |
| R-06 | Fisika terasa tidak enak (game feel) tanpa uji coba langsung | Sedang | Sedang | Parameter di Physics Lab agar mudah disetel saat uji perangkat |
| R-07 | Determinisme replay untuk Ghost Replay | Sedang | Sedang | Rekam input delta, uji TP-5.2; gunakan fixed timestep |
| R-08 | Ukuran save/backup dan migrasi versi | Rendah | Sedang | Save berversi + uji migrasi TP-6.1 |
| R-09 | Performa pada HP kelas bawah | Sedang | Sedang | Aset ringan, mode performa, pengukuran FPS wajib di Phase 7 |
| R-10 | Kehilangan progres karena overwrite | Tinggi | Rendah | Commit kecil, backup save, review sebelum push |
| R-11 | Desain skoring: dengan collision lingkaran dan skor dari titik masuk pertama (ADR-009), titik impact gameplay aktual selalu tepat di tepi target (d = radius) sehingga tembakan nyata selalu mendapat zona terluar (10 poin); zona tengah/pusat tidak pernah tercapai | Tinggi | Pasti (geometri) — kini teratasi | TERATASI (T-1.7): ADR-011 disetujui pemilik proyek — titik skor dihitung dari kedalaman penetrasi ujung panah (S = E + dhat * 0.5 * L; swept collision tetap untuk deteksi/pemilihan target); tembakan melalui pusat menghasilkan Perfect Shot; terverifikasi TP-1.17/TP-1.23 pada run CI #12 (74cded1). Pemantauan lanjutan: keseimbangan nilai skor saat uji perangkat manual |
