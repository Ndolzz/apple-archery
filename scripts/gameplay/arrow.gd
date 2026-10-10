## Arrow — node panah gameplay (visual + integrasi fisika, tanpa logika collision).
##
## Pemisahan tanggung jawab (ADR-002, FR-GF-003):
##   - Simulasi fisika: seluruhnya pada BallisticsModel (gravitasi, drag, angin).
##   - Deteksi tabrakan: CollisionService (murni); Arrow hanya memanggilnya.
##   - Visual: node ini (Node2D) — posisi dan rotasi mengikuti model.
##
## Timestep: FIXED_TIMESTEP tetap (1/120 s) dengan akumulator. advance(delta) memproses
## langkah-langkah tetap; sisa waktu disimpan untuk frame berikutnya. Deterministik untuk
## input sama (pra-syarat Ghost Replay, TP-5.2). delta dipatok pada MAX_FRAME_DELTA untuk
## mencegah spiral kematian akumulasi.
##
## Status (enum State): IDLE siap diluncurkan; FLYING terbang; STUCK menancap.
## Catatan keputusan: dalam model fisika ini panah di udara tidak pernah berhenti
## (gravitasi selalu memberi percepatan), sehingga kondisi "panah berhenti" direalisasikan
## sebagai status STUCK setelah menancap; tidak ada status STOPPED terpisah.
##
## Validasi input: launch dengan kecepatan nol ditolak (false + push_error); parameter
## fisika (drag) divalidasi oleh BallisticsModel. advance saat tidak FLYING diabaikan.
##
## Requirement: FR-GF-003. Pengujian: TP-1.14, TP-1.15, TP-1.16 (04-TEST-PLAN).

class_name Arrow
extends Node2D

enum State { IDLE, FLYING, STUCK }

const FIXED_TIMESTEP := 1.0 / 120.0
const MAX_FRAME_DELTA := 0.25

signal hit_target(result: Dictionary)

var state: State = State.IDLE
var targets: Array = []

var _model: BallisticsModel
var _accumulator := 0.0


func _init() -> void:
    _model = BallisticsModel.new()


## Luncurkan panah. Mengembalikan false bila kecepatan nol atau sedang terbang.
func launch(
    p_initial_position: Vector2,
    p_initial_velocity: Vector2,
    p_gravity: Vector2 = BallisticsModel.DEFAULT_GRAVITY,
    p_wind: Vector2 = Vector2.ZERO,
    p_drag: float = 0.0
) -> bool:
    if state == State.FLYING:
        push_error("Arrow.launch: already flying")
        return false
    if p_initial_velocity == Vector2.ZERO:
        push_error("Arrow.launch: velocity must not be zero")
        return false
    _model = BallisticsModel.new(p_initial_position, p_initial_velocity, p_gravity, p_wind, p_drag)
    _accumulator = 0.0
    state = State.FLYING
    position = p_initial_position
    rotation = p_initial_velocity.angle()
    return true


## Majukan simulasi satu frame. Collision diperiksa swept pada setiap langkah tetap.
func advance(delta: float) -> Dictionary:
    if state != State.FLYING:
        return {}
    var clamped := minf(delta, MAX_FRAME_DELTA)
    _accumulator += clamped
    var result: Dictionary = {}
    while _accumulator >= FIXED_TIMESTEP and state == State.FLYING:
        _accumulator -= FIXED_TIMESTEP
        var prev := _model.position
        _model.step(FIXED_TIMESTEP)
        if targets.is_empty():
            continue
        var hit := CollisionService.segment_targets_first_hit(prev, _model.position, targets)
        if not hit.is_empty():
            _stick(hit)
            result = hit
    _sync_transform()
    return result


## Kembalikan panah ke status siap (IDLE) untuk dipakai ulang.
func reset() -> void:
    state = State.IDLE
    _model = BallisticsModel.new()
    _accumulator = 0.0


func is_stuck() -> bool:
    return state == State.STUCK


func get_model_position() -> Vector2:
    return _model.position


func get_model_velocity() -> Vector2:
    return _model.velocity


func _stick(hit: Dictionary) -> void:
    state = State.STUCK
    _model.position = hit.point
    _model.velocity = Vector2.ZERO
    position = hit.point
    hit_target.emit(hit)


func _sync_transform() -> void:
    if state != State.FLYING:
        return
    position = _model.position
    if _model.velocity.length() > 0.0:
        rotation = _model.velocity.angle()
