# Apple Archery — Arsitektur

Versi: 0.1 (Baseline Phase 0)

## 1. Teknologi

- Engine: Godot 4.x (scripting GDScript).
- Target utama: Android (APK). Desktop digunakan untuk pengembangan headless/CI bila memungkinkan.
- CI: GitHub Actions untuk pengujian (Godot headless) dan build APK.
- Testing: pengujian unit/integrasi via Godot headless; skrip verifikasi tambahan bila lingkungan mendukung.

## 2. Struktur Proyek (Direncanakan)

    apple-archery/
      project.godot            # proyek Godot
      addons/                  # plugin (bila diperlukan)
      assets/                  # sprite, audio, tema
      scenes/                  # scene per fitur
        core/                  # autoload, manager (save, audio, settings)
        gameplay/              # arena, bow, arrow, target, obstacle
        ui/                    # menu, HUD, toko, pengaturan
        debug/                 # Developer Console, Physics Lab, Debug Overlay
      scripts/
        core/                  # state, save, ekonomi, progres
        physics/               # model fisika panah (murni, dapat diuji)
        levels/                # generator dan data level
        modes/                 # campaign, time attack, daily, multiplayer
      tests/                   # pengujian otomatis
      .github/workflows/       # CI pengujian dan build APK
      docs/SDD/                # spesifikasi, backlog, plan, traceability

## 3. Prinsip Arsitektur

1. Logika fisika lintasan diimplementasikan sebagai modul murni (tanpa dependensi node) sehingga dapat diuji otomatis tanpa tampilan.
2. Manajer global melalui autoload (SaveManager, AudioManager, SettingsManager, ProgressManager, EconomyManager).
3. Data level berbasis resource/data-driven agar level baru tidak memerlukan kode baru.
4. Mode permainan berbagi arena gameplay inti; modus hanya mengubah aturan skoring dan alur.
5. UI dipisahkan dari logika gameplay.

## 4. Alur Data Utama

- Input tarikan -> AimController -> BallisticsModel (kecepatan awal, gravitasi, drag, angin) -> Arrow (node) -> Collision -> ScoringService -> ProgressManager/SaveManager.

## 5. Model Penyimpanan

- Save lokal (user://) berformat JSON versi dengan migrasi; backup disimpan pada berkas terpisah.
