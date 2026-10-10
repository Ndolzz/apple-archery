## WindVFX — efek angin kartun 2D (T-1.6), garis lengkung digambar prosedural.
##
## Pemisahan tanggung jawab: VFX HANYA presentasi. Arah dan intensitas visual
## diambil dari parameter angin model fisika yang SAMA (wind Vector2 m/s) melalui
## compute_visual_params — bukan sistem angin visual terpisah (ketentuan T-1.6 poin 2).
## VFX tidak mengubah simulasi apa pun.
##
## Pemetaan visual (pure, dapat diuji):
##   - intensity = clamp(|wind| / MAX_VISUAL_WIND, 0, 1); 0 -> tidak ada goresan.
##   - direction = wind.angle() (rad).
##   - streaks = 3 + round(intensity * 6); mode low_effects mengurangi separuh.
## Efek digambar pada lapisan latar belakang sehingga tidak menutupi target, zona,
## atau panah (ketentuan T-1.6 poin 4); transparansi rendah.
##
## Requirement: FR-AV-007. Pengujian: TP-1.21 (04-TEST-PLAN).

class_name WindVFX
extends Node2D

const MAX_VISUAL_WIND := 8.0
const BASE_STREAKS := 3
const INTENSITY_STREAKS := 6
const STREAK_LENGTH := 2.4
const STREAK_ALPHA := 0.35
const STREAK_COLOR := Color(0.6, 0.8, 1.0, STREAK_ALPHA)

var low_effects: bool = false
var wind: Vector2 = Vector2.ZERO

var _params: Dictionary = {}


## Pure: parameter visual dari angin fisika. {intensity, direction, streaks}
static func compute_visual_params(wind: Vector2, p_low_effects: bool) -> Dictionary:
    var speed := wind.length()
    var intensity := clampf(speed / MAX_VISUAL_WIND, 0.0, 1.0)
    var direction := 0.0
    if speed > 0.0:
        direction = wind.angle()
    var streaks := 0
    if intensity > 0.0:
        streaks = BASE_STREAKS + int(round(intensity * INTENSITY_STREAKS))
        if p_low_effects:
            streaks = maxi(1, streaks / 2)
    return {"intensity": intensity, "direction": direction, "streaks": streaks}


## Perbarui efek dari angin level aktif (dipanggil arena saat level dimuat).
func update_wind(p_wind: Vector2) -> void:
    wind = p_wind
    _params = compute_visual_params(wind, low_effects)
    queue_redraw()


func _draw() -> void:
    if _params.is_empty() or float(_params.intensity) <= 0.0:
        return
    var count := int(_params.streaks)
    var direction: float = float(_params.direction)
    var alpha_factor: float = float(_params.intensity)
    var color := Color(STREAK_COLOR.r, STREAK_COLOR.g, STREAK_COLOR.b, STREAK_ALPHA * alpha_factor)
    for i in count:
        var offset := Vector2(2.0 + 3.0 * i, 1.5 + 2.5 * float((i * 7) % 5))
        var start := offset
        var control := start + Vector2(STREAK_LENGTH * 0.5, -0.6).rotated(direction)
        var end := start + Vector2(STREAK_LENGTH, 0.0).rotated(direction)
        var points: Array[Vector2] = []
        for s in 9:
            var t := float(s) / 8.0
            var q: Vector2 = start.lerp(control, t).lerp(control.lerp(end, t), t)
            points.append(q)
        draw_polyline(PackedVector2Array(points), color, 0.08)
