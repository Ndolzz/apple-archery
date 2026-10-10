## AimController — mesin status bidik tarikan busur (murni, tanpa node).
##
## Pemisahan tanggung jawab (04-TEST-PLAN / FR-GF-001):
##   - AimController HANYA mengelola status dan aritmetika bidik. Ia tidak membaca
##     InputEvent dan tidak membuat simulasi fisika. Node pemanggil (arena, T-1.6)
##     mengirim posisi sentuh; preview lintasan (bila perlu) dibuat caller melalui
##     BallisticsModel terpisah.
##
## Mekanika (gaya tarik-balik / slingshot):
##   - Pemain menahan titik awal lalu menarik. drag_vector = start - current.
##   - Arah tembakan = arah drag_vector (menarik ke bawah-kiri menembak ke atas-kanan).
##   - power = min(len, max_drag_distance) / max_drag_distance  (0..1, kontinu).
##   - Kecepatan luncur = direction * power * max_launch_speed (m/s, konsisten SI
##     dengan BallisticsModel).
##
## Satuan: posisi dalam piksel koordinat layar/dunia caller; kecepatan keluaran m/s.
##
## Validasi input:
##   - begin_aim di luar play_area ditolak (false) dan status tetap idle.
##   - play_area tanpa luas (Rect2 kosong) berarti seluruh layar dianggap valid.
##   - update_aim saat idle diabaikan. release saat idle mengembalikan Dictionary kosong
##     dan melaporkan error. cancel_aim mengembalikan status idle tanpa tembakan.
##
## Requirement: FR-GF-001. Pengujian: TP-1.7 s.d. TP-1.11 (04-TEST-PLAN).

class_name AimController
extends RefCounted

const DEFAULT_MAX_DRAG_DISTANCE := 160.0
const DEFAULT_MAX_LAUNCH_SPEED := 30.0

var max_drag_distance: float
var max_launch_speed: float
var play_area: Rect2

var _aiming := false
var _start := Vector2.ZERO
var _current := Vector2.ZERO


func _init(
    p_play_area: Rect2 = Rect2(),
    p_max_drag_distance: float = DEFAULT_MAX_DRAG_DISTANCE,
    p_max_launch_speed: float = DEFAULT_MAX_LAUNCH_SPEED
) -> void:
    play_area = p_play_area
    max_drag_distance = maxf(p_max_drag_distance, 1.0)
    max_launch_speed = maxf(p_max_launch_speed, 0.0)


func is_aiming() -> bool:
    return _aiming


## Mulai menarik pada posisi sentuh. False bila ditolak (di luar area atau sedang menarik).
func begin_aim(touch_position: Vector2) -> bool:
    if _aiming:
        push_error("AimController.begin_aim: already aiming")
        return false
    if not _is_valid_touch(touch_position):
        return false
    _aiming = true
    _start = touch_position
    _current = touch_position
    return true


## Perbarui posisi tarikan. Diabaikan bila tidak sedang menarik.
func update_aim(touch_position: Vector2) -> void:
    if not _aiming:
        return
    _current = touch_position


## Batalkan tarikan; tidak ada tembakan yang dihasilkan.
func cancel_aim() -> void:
    _aiming = false
    _start = Vector2.ZERO
    _current = Vector2.ZERO


## Selesaikan tarikan menjadi tembakan.
## Mengembalikan {velocity: Vector2, power: float, direction: Vector2, start: Vector2},
## atau Dictionary kosong bila tidak sedang menarik.
func release() -> Dictionary:
    if not _aiming:
        push_error("AimController.release: not aiming")
        return {}
    var drag := _start - _current
    var length := drag.length()
    var power := minf(length, max_drag_distance) / max_drag_distance
    var direction := Vector2.ZERO
    if length > 0.0:
        direction = drag / length
    var velocity := direction * (power * max_launch_speed)
    var result := {
        "velocity": velocity,
        "power": power,
        "direction": direction,
        "start": _start,
    }
    _aiming = false
    _start = Vector2.ZERO
    _current = Vector2.ZERO
    return result


func get_drag_vector() -> Vector2:
    if not _aiming:
        return Vector2.ZERO
    return _start - _current


## Power saat ini (0..1) untuk kebutuhan HUD.
func get_power() -> float:
    if not _aiming:
        return 0.0
    return minf((_start - _current).length(), max_drag_distance) / max_drag_distance


func _is_valid_touch(touch_position: Vector2) -> bool:
    if not play_area.has_area():
        return true
    return play_area.has_point(touch_position)
