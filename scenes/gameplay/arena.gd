## Arena — scene gameplay vertical slice (T-1.6): satu scene, level dari data.
##
## Peran: orkestrasi saja. Fisika = BallisticsModel (via Arrow), collision =
## CollisionService, bidik = AimController, skor = ScoringService, level =
## LevelData dari JSON. Kamera (ArenaCamera), VFX angin (WindVFX), dan preview
## lintasan (TrajectoryPreview) hanya presentasi (ketentuan T-1.6 poin 5).
##
## Alur: sentuh untuk menarik; lepas untuk menembak; gerak panah via advance()
## per frame dengan delta nyata; hasil hit dinilai ScoringService dari titik
## masuk pertama. Batas panah per level (arrow_count); R memuat ulang level.
##
## Requirement: FR-GF-001..005, FR-LV-001 (dasar), FR-GF-006, FR-AV-007.

class_name Arena
extends Node2D

const LEVELS_PATH := "res://assets/levels/levels.json"
const ARCHER_POSITION := Vector2(2.0, 2.0)
const MAX_LAUNCH_SPEED := 30.0
const MAX_DRAG_DISTANCE := 160.0
const PLAY_AREA := Rect2(0.0, 0.0, 1280.0, 720.0)
const TARGETS_Z_INDEX := 10

var level_index := 0
var low_effects := false

var _levels: Array = []
var _level: LevelData
var _aim: AimController
var _scoring: ScoringService
var _arrow: Arrow
var _camera: ArenaCamera
var _wind_vfx: WindVFX
var _preview: TrajectoryPreview
var _hud_score: Label
var _hud_info: Label
var _arrows_left := 0
var _total_score := 0
var _touch_index := -1


func _ready() -> void:
    _aim = AimController.new(PLAY_AREA, MAX_DRAG_DISTANCE, MAX_LAUNCH_SPEED)
    _scoring = ScoringService.new()
    _arrow = Arrow.new()
    add_child(_arrow)
    _camera = ArenaCamera.new()
    _camera.position = Vector2(12.0, 8.0)
    add_child(_camera)
    _camera.make_current()
    _wind_vfx = WindVFX.new()
    _wind_vfx.z_index = -10
    add_child(_wind_vfx)
    _preview = TrajectoryPreview.new()
    _preview.low_effects = low_effects
    _preview.z_index = 5
    add_child(_preview)
    _wind_vfx.low_effects = low_effects
    _build_hud()
    _levels = LevelData.load_all_from_file(LEVELS_PATH)
    if _levels.is_empty():
        push_error("Arena: no valid levels loaded from %s" % LEVELS_PATH)
        return
    load_level(0)


func _build_hud() -> void:
    _hud_score = Label.new()
    _hud_score.position = Vector2(16.0, 16.0)
    _hud_score.text = "Skor: 0"
    add_child(_hud_score)
    _hud_info = Label.new()
    _hud_info.position = Vector2(16.0, 48.0)
    add_child(_hud_info)


## Muat level dari data; membangun target visual sederhana (placeholder Phase 6).
func load_level(index: int) -> void:
    if index < 0 or index >= _levels.size():
        push_error("Arena.load_level: index out of range: %d" % index)
        return
    level_index = index
    _level = _levels[index]
    _arrows_left = _level.arrow_count
    _scoring.reset()
    _arrow.reset()
    _arrow.targets = _level.to_collision_targets()
    _wind_vfx.update_wind(_level.wind)
    _preview.clear_preview()
    for child in get_children():
        if child is Node2D and child.get_meta("is_target", false):
            child.queue_free()
    for target in _level.targets:
        var visual := _draw_target_visual(target)
        add_child(visual)
    _update_hud()


func _draw_target_visual(target: Target) -> Node2D:
    var node := Node2D.new()
    node.set_meta("is_target", true)
    node.position = target.position
    node.z_index = TARGETS_Z_INDEX
    node.set_script(null)
    var colors: Array[Color] = [Color(1.0, 0.92, 0.4), Color(0.96, 0.4, 0.35), Color(1.0, 1.0, 1.0)]
    var drawer := TargetVisual.new()
    drawer.target = target
    drawer.colors = colors
    node.add_child(drawer)
    return node


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch(event as InputEventScreenTouch)
    elif event is InputEventScreenDrag:
        _handle_drag(event as InputEventScreenDrag)
    elif event is InputEventMouseButton:
        _handle_mouse(event as InputEventMouseButton)
    elif event is InputEventMouseMotion:
        _handle_mouse_motion(event as InputEventMouseMotion)
    elif event is InputEventKey and event.is_action_pressed("ui_text_redo"):
        load_level(level_index)


func _handle_touch(event: InputEventScreenTouch) -> void:
    if event.pressed and _touch_index == -1:
        if _aim.begin_aim(_screen_to_world(event.position)):
            _touch_index = event.index
            _camera.set_aiming(true)
    elif not event.pressed and event.index == _touch_index:
        _fire()
        _touch_index = -1


func _handle_drag(event: InputEventScreenDrag) -> void:
    if event.index == _touch_index:
        _aim.update_aim(_screen_to_world(event.position))
        _refresh_preview()


func _handle_mouse(event: InputEventMouseButton) -> void:
    if event.button_index != MOUSE_BUTTON_LEFT:
        return
    if event.pressed and _touch_index == -1:
        if _aim.begin_aim(_screen_to_world(event.position)):
            _touch_index = 999
            _camera.set_aiming(true)
    elif not event.pressed and _touch_index == 999:
        _fire()
        _touch_index = -1


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
    if _touch_index == 999 and _aim.is_aiming():
        _aim.update_aim(_screen_to_world(event.position))
        _refresh_preview()


func _screen_to_world(screen_position: Vector2) -> Vector2:
    return screen_position / 64.0


func _refresh_preview() -> void:
    if not _aim.is_aiming():
        return
    var shot := _current_shot_velocity()
    if shot == Vector2.ZERO:
        _preview.clear_preview()
        return
    _preview.update_prediction(ARCHER_POSITION, shot, BallisticsModel.DEFAULT_GRAVITY, _level.wind, _level.drag)


func _current_shot_velocity() -> Vector2:
    var drag := _aim.get_drag_vector()
    var length := drag.length()
    if length <= 0.0:
        return Vector2.ZERO
    var power := minf(length, MAX_DRAG_DISTANCE) / MAX_DRAG_DISTANCE
    return (drag / length) * (power * MAX_LAUNCH_SPEED)


func _fire() -> void:
    var shot := _aim.release()
    _camera.set_aiming(false)
    _preview.clear_preview()
    if shot.is_empty() or _arrows_left <= 0 or not _arrow.launch(
        ARCHER_POSITION, shot.velocity, BallisticsModel.DEFAULT_GRAVITY, _level.wind, _level.drag
    ):
        return
    _arrows_left -= 1
    _update_hud()


func _cancel_aim() -> void:
    _aim.cancel_aim()
    _camera.set_aiming(false)
    _preview.clear_preview()
    _touch_index = -1


func _process(delta: float) -> void:
    if _arrow.state == Arrow.State.FLYING:
        var hit := _arrow.advance(delta)
        if not hit.is_empty():
            _on_hit(hit)


func _on_hit(hit: Dictionary) -> void:
    var target: Target = _level.targets[int(hit.target_index)]
    var result := ScoringService.score_hit(hit, target)
    var scored := not result.is_empty()
    var combo := _scoring.register_shot(scored)
    if scored:
        _total_score += ScoringService.combo_points(int(result.points), combo)
    _update_hud()
    if _arrows_left <= 0:
        _hud_info.text += "  [E] ulang"


func _update_hud() -> void:
    _hud_score.text = "Skor: %d" % _total_score
    var wind := _level.wind
    _hud_info.text = "%s | Panah: %d | Angin: %.1f m/s" % [
        _level.display_name, _arrows_left, wind.x
    ]
