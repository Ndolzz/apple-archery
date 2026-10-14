## Splash — animasi pembukaan "Archery Signature" (T-6.10, ADR-012).
##
## Peran: presentasi saja. Splash tidak menyentuh model fisika, collision,
## skor, atau kontrol bidikan. Seluruh visual dibangun dari node bawaan
## Godot (ColorRect, Line2D, Label, _draw) tanpa aset eksternal, plugin,
## shader, atau partikel berat — placeholder prosedural sesuai R-05.
##
## Garis waktu (basis desain 1280x720; total 2.5 s, rentang 2-3 s yang
## disetujui pemilik proyek):
##   0.0-0.4  background  — latar bergaya kartun muncul (fade).
##   0.4-0.9  bow         — siluet busur muncul.
##   0.9-1.5  arrow       — jejak panah bergerak melintasi komposisi.
##   1.5-1.9  target      — target dan simbol apel terungkap.
##   1.9-2.3  title       — judul "Apple Archery" tampil.
##   2.3-2.5  hold        — penahanan singkat sebelum transisi.
##
## Perilaku (ADR-012): tidak ada skip — input tidak ditangani sama sekali;
## transisi ke menu utama terjadi tepat satu kali setelah garis waktu
## selesai (flag _transitioned + Timer satu kali); kegagalan memuat scene
## tujuan menghasilkan push_error yang jelas, bukan dianggap berhasil.
## Kontrak transisi: MENU_SCENE_PATH = scene menu utama placeholder visual
## tanpa navigasi (keputusan pemilik proyek; navigasi menyusul).
##
## Requirement: FR-AV-008. Pengujian: TP-6.2 (04-TEST-PLAN).

class_name Splash
extends Node2D

const TOTAL_DURATION := 2.5
const SPLASH_SCENE_PATH := "res://scenes/ui/splash.tscn"
const MENU_SCENE_PATH := "res://scenes/ui/main_menu.tscn"

const PHASE_BACKGROUND := "background"
const PHASE_BOW := "bow"
const PHASE_ARROW := "arrow"
const PHASE_TARGET := "target"
const PHASE_TITLE := "title"
const PHASE_HOLD := "hold"

const BACKGROUND_COLOR := Color(0.55, 0.78, 0.95)
const WOOD_COLOR := Color(0.45, 0.26, 0.12)
const STRING_COLOR := Color(0.15, 0.15, 0.15)
const TRAIL_COLOR := Color(1.0, 0.85, 0.3)
const OUTLINE_COLOR := Color(0.05, 0.09, 0.16)

var _transitioned := false
var _transition_timer: Timer
var _background: ColorRect
var _bow_group: Node2D
var _trail: ColorRect
var _art: Node2D
var _title: Label
var _credit: Label


## Pure: total durasi garis waktu animasi (detik).
static func total_duration() -> float:
    return TOTAL_DURATION


## Pure: path scene splash (entry scene proyek).
static func splash_scene_path() -> String:
    return SPLASH_SCENE_PATH


## Pure: path scene tujuan transisi (menu utama).
static func menu_scene_path() -> String:
    return MENU_SCENE_PATH


## Pure: nama fase animasi pada waktu tertentu (dijepit ke garis waktu).
static func phase_for_time(elapsed: float) -> String:
    if elapsed < 0.4:
        return PHASE_BACKGROUND
    if elapsed < 0.9:
        return PHASE_BOW
    if elapsed < 1.5:
        return PHASE_ARROW
    if elapsed < 1.9:
        return PHASE_TARGET
    if elapsed < 2.3:
        return PHASE_TITLE
    return PHASE_HOLD


## Pure: transisi hanya boleh terjadi setelah garis waktu selesai.
static func should_transition(elapsed: float) -> bool:
    return elapsed >= TOTAL_DURATION


func _ready() -> void:
    _build_visuals()
    _start_animation()


func _build_visuals() -> void:
    _background = ColorRect.new()
    _background.position = Vector2.ZERO
    _background.size = Vector2(1280.0, 720.0)
    _background.color = BACKGROUND_COLOR
    _background.modulate.a = 0.0
    add_child(_background)

    _bow_group = Node2D.new()
    _bow_group.modulate.a = 0.0
    add_child(_bow_group)
    var bow_center := Vector2(320.0, 400.0)
    var bow_radius := 110.0
    var bow_line := Line2D.new()
    bow_line.width = 10.0
    bow_line.default_color = WOOD_COLOR
    var points: PackedVector2Array = []
    for i in range(13):
        var t := float(i) / 12.0
        var angle := deg_to_rad(100.0 + t * 160.0)
        points.append(bow_center + bow_radius * Vector2(cos(angle), sin(angle)))
    bow_line.points = points
    _bow_group.add_child(bow_line)
    var string := Line2D.new()
    string.width = 4.0
    string.default_color = STRING_COLOR
    string.points = PackedVector2Array([points[0], points[12]])
    _bow_group.add_child(string)

    _trail = ColorRect.new()
    _trail.position = Vector2(400.0, 397.0)
    _trail.size = Vector2(170.0, 6.0)
    _trail.color = TRAIL_COLOR
    _trail.modulate.a = 0.0
    add_child(_trail)

    _art = TargetArt.new()
    _art.position = Vector2(950.0, 400.0)
    _art.modulate.a = 0.0
    add_child(_art)

    _title = _make_label("Apple Archery", 72, Vector2(0.0, 100.0), Vector2(1280.0, 110.0))
    _title.pivot_offset = _title.size / 2.0
    _title.modulate.a = 0.0
    add_child(_title)

    _credit = _make_label("Dikembangkan oleh Naze", 24, Vector2(0.0, 655.0), Vector2(1280.0, 40.0))
    _credit.modulate.a = 0.0
    add_child(_credit)


func _make_label(text: String, font_size: int, position: Vector2, size: Vector2) -> Label:
    var label := Label.new()
    var settings := LabelSettings.new()
    settings.font_size = font_size
    settings.outline_size = 10
    settings.outline_color = OUTLINE_COLOR
    settings.shadow_size = 3
    settings.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
    label.label_settings = settings
    label.text = text
    label.position = position
    label.size = size
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    return label


func _start_animation() -> void:
    var tween := create_tween()
    # 0.0-0.4: latar muncul.
    tween.tween_property(_background, "modulate:a", 1.0, 0.4).from(0.0)
    # 0.4-0.9: siluet busur.
    tween.tween_property(_bow_group, "modulate:a", 1.0, 0.5).from(0.0)
    # 0.9-1.5: jejak panah melintasi komposisi lalu memudar.
    tween.tween_property(_trail, "modulate:a", 1.0, 0.1).from(0.0)
    tween.tween_property(_trail, "position:x", 870.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(_trail, "modulate:a", 0.0, 0.05)
    # 1.5-1.9: target terungkap dengan sedikit overshoot kartun.
    tween.tween_property(_art, "modulate:a", 1.0, 0.4).from(0.0)
    tween.parallel().tween_property(_art, "scale", Vector2.ONE, 0.4).from(Vector2(0.7, 0.7)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    # 1.9-2.3: judul.
    tween.tween_property(_title, "modulate:a", 1.0, 0.35).from(0.0)
    tween.parallel().tween_property(_title, "scale", Vector2.ONE, 0.35).from(Vector2(0.9, 0.9)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    # 2.25-2.3: identitas developer (FR-DV-001).
    tween.tween_property(_credit, "modulate:a", 1.0, 0.05).from(0.0)
    # 2.5: transisi tunggal — Timer satu kali, bukan loop.
    _transition_timer = Timer.new()
    _transition_timer.one_shot = true
    _transition_timer.wait_time = TOTAL_DURATION
    _transition_timer.timeout.connect(_on_transition_timeout)
    add_child(_transition_timer)
    _transition_timer.start()


func _on_transition_timeout() -> void:
    if _transitioned:
        return
    _transitioned = true
    var err := get_tree().change_scene_to_file(MENU_SCENE_PATH)
    if err != OK:
        push_error("Splash: gagal memuat scene menu utama '%s' (kode error %d); transisi dibatalkan, splash tetap tampil" % [MENU_SCENE_PATH, err])


## Ikon target + apel untuk fase target reveal — placeholder prosedural (R-05).
class TargetArt extends Node2D:
    var ring_color := Color(0.96, 0.4, 0.35)
    var ring_mid := Color(1.0, 0.92, 0.4)
    var apple_red := Color(0.89, 0.12, 0.16)
    var leaf_green := Color(0.2, 0.6, 0.25)

    func _draw() -> void:
        draw_circle(Vector2.ZERO, 85.0, Color(1.0, 1.0, 1.0))
        draw_circle(Vector2.ZERO, 78.0, ring_color)
        draw_circle(Vector2.ZERO, 52.0, ring_mid)
        draw_circle(Vector2.ZERO, 26.0, ring_color)
        draw_circle(Vector2.ZERO, 12.0, apple_red)
        draw_circle(Vector2(7.0, -16.0), 5.0, leaf_green)
