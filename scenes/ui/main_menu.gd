## MainMenu — placeholder menu utama (T-6.10, ADR-012).
##
## Peran: presentasi saja. Scene ini adalah TUJUAN transisi splash dan sengaja
## berupa placeholder visual TANPA navigasi — keputusan eksplisit pemilik
## proyek (briefing T-6.10): navigasi menu (mis. tombol Play ke arena)
## menyusul sebagai tugas terpisah yang menunggu persetujuan. Kontrak ini
## diuji oleh TP-6.2: navigation_enabled() harus false.
##
## Tidak ada tombol interaktif, tidak ada pemrosesan input, tidak ada akses
## ke sistem gameplay (arena dimuat langsung saat pengembangan bila perlu).
##
## Requirement: FR-AV-008 (tujuan transisi splash). Pengujian: TP-6.2.

class_name MainMenu
extends CanvasLayer

const OUTLINE_COLOR := Color(0.05, 0.09, 0.16)
const TITLE_TEXT := "Apple Archery"
const SUBTITLE_TEXT := "Menu Utama — navigasi menyusul"


## Pure: kontrak placeholder — navigasi belum diaktifkan (TP-6.2).
static func navigation_enabled() -> bool:
    return false


func _ready() -> void:
    layer = 10
    var title := _make_label(TITLE_TEXT, 72, Vector2(0.0, 120.0), Vector2(1280.0, 110.0))
    add_child(title)
    var subtitle := _make_label(SUBTITLE_TEXT, 28, Vector2(0.0, 250.0), Vector2(1280.0, 50.0))
    subtitle.label_settings.outline_size = 8
    add_child(subtitle)
    var credit := _make_label("Dikembangkan oleh Naze", 24, Vector2(0.0, 655.0), Vector2(1280.0, 40.0))
    add_child(credit)


func _make_label(text: String, font_size: int, position: Vector2, size: Vector2) -> Label:
    var label := Label.new()
    var settings := LabelSettings.new()
    settings.font_size = font_size
    settings.outline_size = 12
    settings.outline_color = OUTLINE_COLOR
    settings.shadow_size = 3
    settings.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
    label.label_settings = settings
    label.text = text
    label.position = position
    label.size = size
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    return label
