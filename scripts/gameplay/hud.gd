## ArenaHUD — penyempurnaan HUD arena (T-1.7).
##
## Peran: presentasi saja. HUD HANYA membaca state game dan menampilkan
## informasi; ia tidak menghitung ulang fisika, collision, atau skor
## (ketentuan T-1.7). Angin yang ditampilkan diambil dari Vector2 angin
## BallisticsModel yang sama dengan simulasi; daya bidik dari
## AimController.get_power(); umpan balik dari hasil ScoringService.
##
## Logika murni yang dapat diuji (TP-1.24):
##   - wind_arrow_text: 8 arah kompas dari sudut angin (konvensi y-up fisika),
##     "•" bila nyaris tenang.
##   - power_ratio: rasio daya 0..1 dijepit.
##   - shot_feedback_text: teks umpan balik tembakan ("PERFECT +50",
##     "+20  x3", "+10", "Meleset!").
##
## Tata letak memakai basis desain tetap 1280x720 (project.godot:
## stretch canvas_items/expand) sehingga aman untuk layar Android portrait.
## Label memakai outline gelap agar terbaca di atas arena; mode low_effects
## menghilangkan fade umpan balik demi performa perangkat terbatas.
##
## Requirement: FR-GF-001, FR-GF-002, FR-GF-005 (umpan balik skor),
## FR-AV-006. Pengujian: TP-1.24 (04-TEST-PLAN).

class_name ArenaHUD
extends CanvasLayer

const WIND_ARROWS: Array[String] = ["→", "↗", "↑", "↖", "←", "↙", "↓", "↘"]
const ZERO_WIND_TEXT := "•"
const CALM_WIND_THRESHOLD := 0.05
const FEEDBACK_DURATION := 1.2
const POWER_BAR_WIDTH := 300.0
const POWER_BAR_HEIGHT := 22.0
const FEEDBACK_X := 540.0
const FEEDBACK_Y := 180.0

var low_effects := false

var _score_label: Label
var _wind_label: Label
var _power_bar_bg: ColorRect
var _power_bar_fill: ColorRect
var _feedback_label: Label
var _feedback_timer: Timer


## Pure: teks arah angin dari vektor angin fisika (y-up).
static func wind_arrow_text(wind: Vector2) -> String:
    if wind.length() < CALM_WIND_THRESHOLD:
        return ZERO_WIND_TEXT
    var index := int(floor(fposmod(wind.angle() + PI / 8.0, TAU) / (PI / 4.0))) % 8
    return WIND_ARROWS[index]


## Pure: rasio daya bidik 0..1.
static func power_ratio(power: float) -> float:
    return clampf(power, 0.0, 1.0)


## Pure: teks umpan balik hasil tembakan terakhir.
static func shot_feedback_text(points: int, is_perfect: bool, combo: int) -> String:
    if points <= 0:
        return "Meleset!"
    if is_perfect:
        return "PERFECT +%d" % points
    if combo >= 2:
        return "+%d  x%d" % [points, combo]
    return "+%d" % points


func _ready() -> void:
    layer = 20
    _score_label = _make_label(Vector2(16.0, 12.0), 28)
    _wind_label = _make_label(Vector2(16.0, 52.0), 22)
    _feedback_label = _make_label(Vector2(FEEDBACK_X, FEEDBACK_Y), 40)
    _feedback_label.visible = false
    _power_bar_bg = ColorRect.new()
    _power_bar_bg.position = Vector2(16.0, 660.0)
    _power_bar_bg.size = Vector2(POWER_BAR_WIDTH, POWER_BAR_HEIGHT)
    _power_bar_bg.color = Color(0.15, 0.23, 0.42, 0.85)
    add_child(_power_bar_bg)
    _power_bar_bg.visible = false
    _power_bar_fill = ColorRect.new()
    _power_bar_fill.position = Vector2(2.0, 2.0)
    _power_bar_fill.size = Vector2.ZERO
    _power_bar_fill.color = Color(0.37, 0.94, 0.36)
    _power_bar_bg.add_child(_power_bar_fill)
    _feedback_timer = Timer.new()
    _feedback_timer.one_shot = true
    _feedback_timer.wait_time = FEEDBACK_DURATION
    _feedback_timer.timeout.connect(_on_feedback_timeout)
    add_child(_feedback_timer)


func _make_label(position: Vector2, font_size: int) -> Label:
    var label := Label.new()
    var settings := LabelSettings.new()
    settings.font_size = font_size
    settings.outline_size = 8
    settings.outline_color = Color(0.05, 0.09, 0.16)
    settings.shadow_size = 2
    settings.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
    label.label_settings = settings
    label.position = position
    add_child(label)
    return label


## Skor saat ini, sisa panah, dan nama level.
func update_score(score: int, arrows_left: int, level_name: String) -> void:
    _score_label.text = "%s  |  Skor: %d  |  Panah: %d" % [level_name, score, arrows_left]


## Arah dan intensitas angin — konsisten dengan parameter BallisticsModel.
func update_wind(wind: Vector2) -> void:
    _wind_label.text = "Angin: %s  %.1f m/s" % [wind_arrow_text(wind), wind.length()]


## Bar daya tarikan busur; tidak menutupi area target (pojok kiri bawah).
func update_aim(power: float) -> void:
    var ratio := power_ratio(power)
    _power_bar_fill.size = Vector2((POWER_BAR_WIDTH - 4.0) * ratio, POWER_BAR_HEIGHT - 4.0)
    _power_bar_bg.visible = ratio > 0.0


func clear_aim() -> void:
    _power_bar_fill.size = Vector2.ZERO
    _power_bar_bg.visible = false


## Umpan balik singkat hasil tembakan; memudar kecuali mode low_effects.
func show_shot_feedback(points: int, is_perfect: bool, combo: int) -> void:
    _feedback_label.text = shot_feedback_text(points, is_perfect, combo)
    _feedback_label.modulate.a = 1.0
    _feedback_label.visible = true
    _feedback_timer.start()


func _on_feedback_timeout() -> void:
    _feedback_label.visible = false


func _process(_delta: float) -> void:
    if low_effects or not _feedback_label.visible:
        return
    _feedback_label.modulate.a = clampf(_feedback_timer.time_left / FEEDBACK_DURATION, 0.0, 1.0)
