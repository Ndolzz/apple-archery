## Pengujian BallisticsModel, AimController, CollisionService, dan Arrow — TP-1.1 s.d. TP-1.16.
## Runner mandiri tanpa dependensi addon (NFR-002): dijalankan dengan
##   godot --headless --path . --script tests/run_tests.gd
## Keluar dengan kode 0 bila seluruh pengujian lulus, 1 bila ada kegagalan.

extends SceneTree

var _failures: Array[String] = []
var _passed: int = 0


func _init() -> void:
    _test_tp_1_1_analytic_parabola()
    _test_tp_1_2_drag_reduces_range()
    _test_tp_1_3_wind_shifts_impact()
    _test_tp_1_4_prediction_shape()
    _test_tp_1_7_begin_aim_in_area()
    _test_tp_1_8_power_direction_continuous()
    _test_tp_1_9_max_drag_clamped()
    _test_tp_1_10_cancel_resets()
    _test_tp_1_11_invalid_touch_rejected()
    _test_tp_1_12_swept_catches_fast_arrow()
    _test_tp_1_13_impact_point_first_entry()
    _test_tp_1_14_arrow_flight_consistency()
    _test_tp_1_15_arrow_sticks_on_hit()
    _test_tp_1_16_arrow_invalid_launch_and_reset()
    _print_summary()
    quit(1 if _failures.size() > 0 else 0)


func _check(condition: bool, label: String) -> void:
    if condition:
        _passed += 1
        print("PASS: %s" % label)
    else:
        _failures.append(label)
        print("FAIL: %s" % label)


## TP-1.1: tanpa angin dan drag, lintasan cocok dengan parabola analitik dalam toleransi.
func _test_tp_1_1_analytic_parabola() -> void:
    var dt := 0.01
    var g := Vector2(0.0, -9.8)
    var v0 := Vector2(10.0, 4.9)
    var t_end := 1.0
    var m := BallisticsModel.new(Vector2.ZERO, v0, g, Vector2.ZERO, 0.0)
    var steps := int(t_end / dt)
    for i in range(steps):
        m.step(dt)
    var analytic := Vector2(v0.x * t_end, v0.y * t_end + 0.5 * g.y * t_end * t_end)
    var err_bound := 0.5 * 9.8 * dt * t_end + 0.000001
    _check(m.position.distance_to(analytic) <= err_bound, "TP-1.1 analytic parabola within tolerance")


## TP-1.2: drag mengurangi jangkauan dibanding tanpa drag.
func _test_tp_1_2_drag_reduces_range() -> void:
    var dt := 0.01
    var g := Vector2(0.0, -9.8)
    var v0 := Vector2(20.0, 10.0)
    var no_drag := _range_until_ground(v0, g, Vector2.ZERO, 0.0, dt)
    var with_drag := _range_until_ground(v0, g, Vector2.ZERO, 0.8, dt)
    _check(with_drag < no_drag * 0.9, "TP-1.2 drag reduces range")


## TP-1.3: tanda angin menggeser titik impact sesuai arahnya.
func _test_tp_1_3_wind_shifts_impact() -> void:
    var dt := 0.01
    var g := Vector2(0.0, -9.8)
    var v0 := Vector2(15.0, 8.0)
    var pos_wind := _range_until_ground(v0, g, Vector2(4.0, 0.0), 0.5, dt)
    var neg_wind := _range_until_ground(v0, g, Vector2(-4.0, 0.0), 0.5, dt)
    _check(pos_wind > neg_wind, "TP-1.3 wind sign shifts impact")


## TP-1.4: prediksi lintasan: titik pertama = posisi awal; jumlah titik sesuai; tanpa mutasi.
func _test_tp_1_4_prediction_shape() -> void:
    var m := BallisticsModel.new(Vector2(3.0, 7.0), Vector2(10.0, 5.0))
    var points := m.predict_trajectory(10, 0.01)
    _check(points.size() == 10, "TP-1.4 prediction point count")
    _check(points[0] == Vector2(3.0, 7.0), "TP-1.4 first predicted point equals start")
    var unchanged := m.position == Vector2(3.0, 7.0) and m.velocity == Vector2(10.0, 5.0)
    _check(unchanged, "TP-1.4 prediction does not mutate model state")


## TP-1.7: begin_aim di dalam area berhasil dan status menjadi aiming.
func _test_tp_1_7_begin_aim_in_area() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 1280.0, 720.0))
    _check(a.begin_aim(Vector2(200.0, 600.0)), "TP-1.7 begin_aim inside area accepted")
    _check(a.is_aiming(), "TP-1.7 state is aiming after begin")
    _check(a.get_drag_vector() == Vector2.ZERO, "TP-1.7 zero drag right after begin")


## TP-1.8: power dan arah kontinu mengikuti input.
func _test_tp_1_8_power_direction_continuous() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 1280.0, 720.0), 160.0, 30.0)
    a.begin_aim(Vector2(100.0, 100.0))
    a.update_aim(Vector2(80.0, 80.0))
    var expected_power := 20.0 * sqrt(2.0) / 160.0
    _check(absf(a.get_power() - expected_power) < 0.000001, "TP-1.8 power continuous at partial pull")
    var shot := a.release()
    _check(shot.velocity.x > 0.0 and shot.velocity.y > 0.0, "TP-1.8 aim direction opposite to pull")
    _check(absf(float(shot.power) - expected_power) < 0.000001, "TP-1.8 released power matches drag")
    _check(not a.is_aiming(), "TP-1.8 release ends aiming state")


## TP-1.9: tarikan melewati batas maksimum dikunci.
func _test_tp_1_9_max_drag_clamped() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 1280.0, 720.0), 160.0, 30.0)
    a.begin_aim(Vector2(100.0, 100.0))
    a.update_aim(Vector2(-100.0, -100.0))
    _check(absf(a.get_power() - 1.0) < 0.000001, "TP-1.9 power clamped to 1.0")
    var shot := a.release()
    _check(absf(float(shot.velocity.length()) - 30.0) < 0.000001, "TP-1.9 launch speed clamped to max")
    _check(shot.velocity.normalized() == Vector2(1.0, 1.0).normalized(), "TP-1.9 direction preserved beyond clamp")


## TP-1.10: pembatalan mengembalikan status awal.
func _test_tp_1_10_cancel_resets() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 1280.0, 720.0), 160.0, 30.0)
    a.begin_aim(Vector2(100.0, 100.0))
    a.update_aim(Vector2(40.0, 40.0))
    a.cancel_aim()
    _check(not a.is_aiming(), "TP-1.10 cancel returns to idle")
    _check(a.get_power() == 0.0, "TP-1.10 power zero after cancel")
    var shot := a.release()
    _check(shot.is_empty(), "TP-1.10 release after cancel produces no shot")


## TP-1.11: sentuhan tidak valid ditolak.
func _test_tp_1_11_invalid_touch_rejected() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 400.0, 400.0), 160.0, 30.0)
    _check(not a.begin_aim(Vector2(500.0, 100.0)), "TP-1.11 touch outside play area rejected")
    _check(not a.is_aiming(), "TP-1.11 state stays idle after rejected touch")
    var shot := a.release()
    _check(shot.is_empty(), "TP-1.11 release without aim returns empty")
    _check(not a.begin_aim(Vector2(10.0, 10.0)) or a.is_aiming(), "TP-1.11 valid touch still accepted after rejection")


## TP-1.12: swept collision menangkap panah cepat yang lolos dari cek diskret.
func _test_tp_1_12_swept_catches_fast_arrow() -> void:
    var from := Vector2(0.0, 0.0)
    var to := Vector2(20.0, 0.0)
    var center := Vector2(10.0, 0.5)
    var radius := 1.0
    var discrete_miss := from.distance_to(center) > radius and to.distance_to(center) > radius
    var hit := CollisionService.segment_circle_first_hit(from, to, center, radius)
    _check(discrete_miss, "TP-1.12 setup: discrete endpoint check would miss")
    _check(not hit.is_empty() and bool(hit.hit), "TP-1.12 swept collision catches fast arrow")


## TP-1.13: titik impact = titik masuk pertama, bukan titik terdalam.
func _test_tp_1_13_impact_point_first_entry() -> void:
    var hit := CollisionService.segment_circle_first_hit(
        Vector2(0.0, 0.0), Vector2(20.0, 0.0), Vector2(10.0, 0.0), 1.0
    )
    _check(not hit.is_empty(), "TP-1.13 crossing hit detected")
    _check(absf(float(hit.point.x) - 9.0) < 0.000001 and absf(float(hit.point.y)) < 0.000001,
        "TP-1.13 impact point is first entry (x=9), not deepest (x=10)")
    var behind := CollisionService.segment_circle_first_hit(
        Vector2(15.0, 0.0), Vector2(20.0, 0.0), Vector2(10.0, 0.0), 1.0
    )
    _check(behind.is_empty(), "TP-1.13 segment behind circle does not hit")
    var miss := CollisionService.segment_circle_first_hit(
        Vector2(0.0, 0.0), Vector2(20.0, 0.0), Vector2(10.0, 5.0), 1.0
    )
    _check(miss.is_empty(), "TP-1.13 far target does not hit")
    var targets := [
        {"position": Vector2(30.0, 0.0), "radius": 1.0, "id": "far"},
        {"position": Vector2(10.0, 0.0), "radius": 1.0, "id": "near"},
    ]
    var first := CollisionService.segment_targets_first_hit(Vector2(0.0, 0.0), Vector2(40.0, 0.0), targets)
    _check(not first.is_empty() and String(first.id) == "near", "TP-1.13 first target along path is selected")


## TP-1.14: posisi node panah konsisten dengan BallisticsModel pada timestep tetap.
func _test_tp_1_14_arrow_flight_consistency() -> void:
    var arrow := Arrow.new()
    arrow.launch(Vector2.ZERO, Vector2(24.0, 0.0), Vector2(0.0, -9.8))
    arrow.advance(0.5)
    var m := BallisticsModel.new(Vector2.ZERO, Vector2(24.0, 0.0), Vector2(0.0, -9.8))
    var steps := int(0.5 / Arrow.FIXED_TIMESTEP)
    for i in range(steps):
        m.step(Arrow.FIXED_TIMESTEP)
    _check(arrow.get_model_position().distance_to(m.position) < 0.000001,
        "TP-1.14 arrow model matches independent simulation")
    _check(arrow.position.distance_to(m.position) < 0.000001,
        "TP-1.14 node position synced to model")
    _check(arrow.state == Arrow.State.FLYING, "TP-1.14 arrow still flying without targets")


## TP-1.15: panah menancap pada titik impact dan tidak bergerak lagi.
func _test_tp_1_15_arrow_sticks_on_hit() -> void:
    var arrow := Arrow.new()
    arrow.targets = [{"position": Vector2(12.0, 0.0), "radius": 0.5, "id": "t1"}]
    var hit_detected: Dictionary = {}
    arrow.hit_target.connect(func(result: Dictionary) -> void: hit_detected = result)
    arrow.launch(Vector2.ZERO, Vector2(24.0, 0.0), Vector2(0.0, -9.8))
    arrow.advance(0.5)
    _check(arrow.is_stuck(), "TP-1.15 arrow is stuck after hit")
    _check(not hit_detected.is_empty(), "TP-1.15 hit_target signal emitted")
    var stuck_pos: Vector2 = arrow.position
    arrow.advance(1.0)
    _check(arrow.position == stuck_pos, "TP-1.15 stuck arrow does not move on further advance")
    _check(absf(float(arrow.get_model_velocity().length())) < 0.000001, "TP-1.15 stuck arrow velocity zero")


## TP-1.16: peluncuran tidak valid ditolak; reset mengembalikan status siap.
func _test_tp_1_16_arrow_invalid_launch_and_reset() -> void:
    var arrow := Arrow.new()
    _check(not arrow.launch(Vector2.ZERO, Vector2.ZERO), "TP-1.16 zero-velocity launch rejected")
    _check(arrow.state == Arrow.State.IDLE, "TP-1.16 state stays idle after rejected launch")
    _check(arrow.launch(Vector2.ZERO, Vector2(10.0, 10.0)), "TP-1.16 valid launch accepted")
    _check(arrow.state == Arrow.State.FLYING, "TP-1.16 state flying after valid launch")
    _check(not arrow.launch(Vector2.ZERO, Vector2(5.0, 5.0)), "TP-1.16 relaunch while flying rejected")
    arrow.reset()
    _check(arrow.state == Arrow.State.IDLE, "TP-1.16 reset returns to idle")
    _check(arrow.get_model_position() == Vector2.ZERO, "TP-1.16 reset clears model position")
    _check(arrow.advance(1.0).is_empty(), "TP-1.16 advance in idle returns empty")
    _check(arrow.launch(Vector2(1.0, 1.0), Vector2(5.0, 5.0)), "TP-1.16 launch works after reset")


## Simulasi hingga panah kembali ke ketinggian awal.
func _range_until_ground(v0: Vector2, g: Vector2, wind: Vector2, drag: float, dt: float) -> float:
    var m := BallisticsModel.new(Vector2.ZERO, v0, g, wind, drag)
    var start_y := m.position.y
    var max_steps := 200000
    for i in range(max_steps):
        var prev_y := m.position.y
        m.step(dt)
        if m.velocity.y < 0.0 and prev_y > start_y and m.position.y <= start_y:
            break
    return m.position.x


func _print_summary() -> void:
    print("")
    print("BallisticsModel + AimController + CollisionService + Arrow tests: %d passed, %d failed" % [_passed, _failures.size()])
    for label in _failures:
        print("  FAILED: %s" % label)
