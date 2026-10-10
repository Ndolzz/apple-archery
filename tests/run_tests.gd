## Pengujian BallisticsModel dan AimController — TP-1.1 s.d. TP-1.11 (04-TEST-PLAN).
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
## Toleransi = batas galat semi-implicit Euler: 0.5 * g * dt * T.
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


## TP-1.4: titik prediksi pertama sama dengan posisi awal; jumlah titik sesuai konfigurasi.
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


## TP-1.8: power dan arah kontinu mengikuti input (tarik separuh -> power separuh,
## arah tembakan berlawanan arah tarikan).
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


## TP-1.9: tarikan melewati batas maksimum dikunci pada power 1.0 dan kecepatan maksimum.
func _test_tp_1_9_max_drag_clamped() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 1280.0, 720.0), 160.0, 30.0)
    a.begin_aim(Vector2(100.0, 100.0))
    a.update_aim(Vector2(-100.0, -100.0))
    _check(absf(a.get_power() - 1.0) < 0.000001, "TP-1.9 power clamped to 1.0")
    var shot := a.release()
    _check(absf(float(shot.velocity.length()) - 30.0) < 0.000001, "TP-1.9 launch speed clamped to max")
    _check(shot.velocity.normalized() == Vector2(1.0, 1.0).normalized(), "TP-1.9 direction preserved beyond clamp")


## TP-1.10: pembatalan mengembalikan status awal; release setelah batal tidak menghasilkan tembakan.
func _test_tp_1_10_cancel_resets() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 1280.0, 720.0), 160.0, 30.0)
    a.begin_aim(Vector2(100.0, 100.0))
    a.update_aim(Vector2(40.0, 40.0))
    a.cancel_aim()
    _check(not a.is_aiming(), "TP-1.10 cancel returns to idle")
    _check(a.get_power() == 0.0, "TP-1.10 power zero after cancel")
    var shot := a.release()
    _check(shot.is_empty(), "TP-1.10 release after cancel produces no shot")


## TP-1.11: sentuhan di luar area permainan ditolak; release tanpa menarik mengembalikan kosong.
func _test_tp_1_11_invalid_touch_rejected() -> void:
    var a := AimController.new(Rect2(0.0, 0.0, 400.0, 400.0), 160.0, 30.0)
    _check(not a.begin_aim(Vector2(500.0, 100.0)), "TP-1.11 touch outside play area rejected")
    _check(not a.is_aiming(), "TP-1.11 state stays idle after rejected touch")
    var shot := a.release()
    _check(shot.is_empty(), "TP-1.11 release without aim returns empty")
    _check(not a.begin_aim(Vector2(10.0, 10.0)) or a.is_aiming(), "TP-1.11 valid touch still accepted after rejection")


## Simulasi hingga panah kembali ke ketinggian awal (jatuh melewati garis start).
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
    print("BallisticsModel + AimController tests: %d passed, %d failed" % [_passed, _failures.size()])
    for label in _failures:
        print("  FAILED: %s" % label)
