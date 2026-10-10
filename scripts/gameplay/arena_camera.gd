## ArenaCamera — presentasi kamera dengan soft zoom saat membidik (T-1.6).
##
## Pemisahan tanggung jawab: kamera HANYA presentasi. Ia tidak mengubah kecepatan,
## arah, skor, collision, atau hasil simulasi (ketentuan T-1.6 poin 5).
##
## Logika zoom murni (dapat diuji tanpa node):
##   - compute_zoom_target: aiming -> ZOOM_AIM; selain itu ZOOM_NORMAL.
##   - compute_zoom_step: smoothing eksponensial exp(-SMOOTHING * dt), tanpa gerakan
##     mendadak (langkah terbatas oleh faktor smoothing), kembali mulus ke normal
##     setelah tembakan atau pembatalan.
##   - Nilai dijepit ZOOM_MIN..ZOOM_MAX.
##
## Requirement: FR-GF-006. Pengujian: TP-1.20 (04-TEST-PLAN).

class_name ArenaCamera
extends Camera2D

const ZOOM_NORMAL := 1.0
const ZOOM_AIM := 1.35
const ZOOM_MIN := 1.0
const ZOOM_MAX := 1.5
const SMOOTHING := 3.0

var _target_zoom: float = ZOOM_NORMAL


func set_aiming(aiming: bool) -> void:
    _target_zoom = compute_zoom_target(aiming)


## Pure: nilai zoom tujuan berdasarkan status bidik.
static func compute_zoom_target(aiming: bool) -> float:
    return ZOOM_AIM if aiming else ZOOM_NORMAL


## Pure: satu langkah smoothing eksponensial menuju target (tanpa lompatan).
static func compute_zoom_step(current: float, target: float, delta: float) -> float:
    var next: float = current + (target - current) * (1.0 - exp(-SMOOTHING * delta))
    return clampf(next, ZOOM_MIN, ZOOM_MAX)


func _process(delta: float) -> void:
    zoom = Vector2.ONE * compute_zoom_step(zoom.x, _target_zoom, delta)
