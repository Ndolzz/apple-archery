## TrajectoryPreview — garis prediksi lintasan saat membidik (T-1.6).
##
## Prediksi dibuat MELALUI BallisticsModel.predict_trajectory — tidak ada rumus
## fisika yang diduplikasi di scene (ketentuan T-1.6 poin 3, ADR-002).
## Preview hanya presentasi; tidak mengubah simulasi.
##
## Pengaturan: enabled (toggle FR-GF-004), low_effects mengurangi jumlah titik
## (ketentuan T-1.6 poin 4 untuk perangkat terbatas).
##
## Requirement: FR-GF-004. Pengujian: TP-1.22 (04-TEST-PLAN).

class_name TrajectoryPreview
extends Node2D

const DEFAULT_POINT_COUNT := 40
const LOW_EFFECT_POINT_COUNT := 15
const POINT_COLOR := Color(1.0, 1.0, 1.0, 0.5)
const POINT_RADIUS := 0.08

var enabled: bool = true
var low_effects: bool = false

var _points: Array[Vector2] = []
var _physics: BallisticsModel


func _init() -> void:
    _physics = BallisticsModel.new()


## Pure: jumlah titik sesuai pengaturan efek.
func effective_point_count() -> int:
    return LOW_EFFECT_POINT_COUNT if low_effects else DEFAULT_POINT_COUNT


## Hitung titik prediksi untuk bidikan tertentu (posisi dan kecepatan luncur).
## Titik tersimpan untuk digambar; keadaan model internal tidak bocor.
func update_prediction(
    p_origin: Vector2,
    p_velocity: Vector2,
    p_gravity: Vector2,
    p_wind: Vector2,
    p_drag: float
) -> void:
    if not enabled:
        _points = []
        queue_redraw()
        return
    _physics = BallisticsModel.new(p_origin, p_velocity, p_gravity, p_wind, p_drag)
    _points = _physics.predict_trajectory(effective_point_count(), 1.0 / 30.0)
    queue_redraw()


## Titik prediksi saat ini (untuk HUD/pengujian).
func get_points() -> Array[Vector2]:
    return _points


func clear_preview() -> void:
    _points = []
    queue_redraw()


func _draw() -> void:
    if not enabled:
        return
    for point in _points:
        draw_circle(point, POINT_RADIUS, POINT_COLOR)
