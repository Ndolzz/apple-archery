## BallisticsModel — model fisika proyektil panah (murni, tanpa node).
##
## Satuan (basis SI):
##   - Posisi: meter (unit dunia Godot = meter).
##   - Kecepatan: m/s. Gravitasi: m/s^2. Angin: m/s (kecepatan udara lingkungan).
##   - Waktu: detik. drag: koefisien hambatan linier [1/s].
##
## Model dan asumsi (ADR-002):
##   a = g - k * (v - wind)  (hambatan udara linier; angin bergerak relatif terhadap panah)
##   Integrasi: semi-implicit Euler pada timestep tetap. Deterministik untuk dt sama
##   (pra-syarat Ghost Replay, TP-5.2).
##   Sistem koordinat tidak diasumsikan; gravitasi diberikan caller (mis. (0, -9.8) untuk y-atas).
##
## Batas input:
##   - drag < 0, dt <= 0, point_count <= 0 dianggap invalid: nilai dibatasi/dikoreksi
##     dan kesalahan dilaporkan via push_error (tidak ada exception pada release build).
##
## Timestep:
##   - Timestep tetap, ditentukan caller (rekomendasi 1/120 s untuk gameplay,
##     1/100 s pada pengujian). Node visual hanya menjalankan integrasi dari model ini.
##
## Requirement: FR-GF-002, FR-GF-004. Pengujian: TP-1.1 s.d. TP-1.4 (04-TEST-PLAN).

class_name BallisticsModel
extends RefCounted

const DEFAULT_GRAVITY := Vector2(0.0, -9.8)
const DEFAULT_DRAG := 0.0
const MAX_DRAG := 10.0
const MAX_POINT_COUNT := 500

var position: Vector2
var velocity: Vector2
var gravity: Vector2
var wind: Vector2
var drag: float


func _init(
    p_initial_position: Vector2 = Vector2.ZERO,
    p_initial_velocity: Vector2 = Vector2.ZERO,
    p_gravity: Vector2 = DEFAULT_GRAVITY,
    p_wind: Vector2 = Vector2.ZERO,
    p_drag: float = DEFAULT_DRAG
) -> void:
    position = p_initial_position
    velocity = p_initial_velocity
    gravity = p_gravity
    wind = p_wind
    drag = _sanitize_drag(p_drag)


func reset(p_initial_position: Vector2, p_initial_velocity: Vector2) -> void:
    position = p_initial_position
    velocity = p_initial_velocity


## Satu langkah integrasi semi-implicit Euler. dt <= 0 diabaikan dengan error log.
func step(delta: float) -> void:
    if delta <= 0.0:
        push_error("BallisticsModel.step: delta must be > 0, got %f" % delta)
        return
    var accel := gravity - drag * (velocity - wind)
    velocity += accel * delta
    position += velocity * delta


## Prediksi lintasan tanpa mengubah keadaan model.
## Mengembalikan point_count titik termasuk posisi awal.
func predict_trajectory(point_count: int, delta: float) -> Array[Vector2]:
    if point_count <= 0:
        push_error("BallisticsModel.predict_trajectory: point_count must be > 0, got %d" % point_count)
        point_count = 1
    if point_count > MAX_POINT_COUNT:
        point_count = MAX_POINT_COUNT
    if delta <= 0.0:
        push_error("BallisticsModel.predict_trajectory: delta must be > 0, got %f" % delta)
        delta = 0.016
    var sim := BallisticsModel.new(position, velocity, gravity, wind, drag)
    var points: Array[Vector2] = [sim.position]
    for i in range(point_count - 1):
        sim.step(delta)
        points.append(sim.position)
    return points


func _sanitize_drag(p_drag: float) -> float:
    if p_drag < 0.0:
        push_error("BallisticsModel: negative drag %f clamped to 0.0" % p_drag)
        return 0.0
    if p_drag > MAX_DRAG:
        push_error("BallisticsModel: drag %f clamped to %f" % [p_drag, MAX_DRAG])
        return MAX_DRAG
    return p_drag
