## Pengujian modul Phase 1 — TP-1.1 s.d. TP-1.22.
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
    _test_tp_1_5_scoring_zones_and_perfect()
    _test_tp_1_6_combo_sequence()
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
    _test_tp_1_17_scoring_boundaries_and_no_double()
    _test_tp_1_18_levels_from_data()
    _test_tp_1_19_invalid_level_data_rejected()
    _test_tp_1_20_camera_zoom_logic()
    _test_tp_1_21_wind_vfx_mapping()
    _test_tp_1_22_trajectory_preview_uses_model()
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


## TP-1.5: zona skor — pusat tertinggi, tiap zona benar, Perfect Shot terdeteksi.
func _test_tp_1_5_scoring_zones_and_perfect() -> void:
    var t := Target.new("t1", Vector2(10.0, 5.0), 3.0)
    _check(t.is_valid(), "TP-1.5 target with default zones is valid")
    var center := ScoringService.classify(t, Vector2(10.0, 5.0))
    _check(not center.is_empty() and int(center.points) == 50 and bool(center.is_perfect),
        "TP-1.5 center scores highest zone (50) and is Perfect Shot")
    var inner_edge := ScoringService.classify(t, Vector2(10.0, 6.0))
    _check(not inner_edge.is_empty() and int(inner_edge.points) == 50,
        "TP-1.5 inner zone boundary (d=1.0, frac 1/3 * 3) scores 50")
    var middle := ScoringService.classify(t, Vector2(10.0, 6.5))
    _check(not middle.is_empty() and int(middle.points) == 20 and not bool(middle.is_perfect),
        "TP-1.5 middle zone scores 20, not perfect")
    var outer := ScoringService.classify(t, Vector2(10.0, 7.5))
    _check(not outer.is_empty() and int(outer.points) == 10,
        "TP-1.5 outer zone scores 10")
    var missed := ScoringService.classify(t, Vector2(10.0, 8.1))
    _check(missed.is_empty(), "TP-1.5 point outside target scores nothing")
    var invalid := Target.new("t2", Vector2(0.0, 0.0), -1.0)
    _check(not invalid.is_valid(), "TP-1.5 invalid target rejected")
    _check(ScoringService.classify(invalid, Vector2.ZERO).is_empty(), "TP-1.5 invalid target gives no score")
    var wrong_id := ScoringService.score_hit({"point": Vector2(10.0, 5.0), "id": "other"}, t)
    _check(wrong_id.is_empty(), "TP-1.5 score_hit with mismatched target id returns empty")


## TP-1.6: combo bertambah pada hit berturut-turut, reset saat meleset.
func _test_tp_1_6_combo_sequence() -> void:
    var s := ScoringService.new()
    _check(s.register_shot(true) == 1, "TP-1.6 first hit: combo 1")
    _check(s.register_shot(true) == 2, "TP-1.6 second consecutive hit: combo 2")
    _check(s.register_shot(true) == 3, "TP-1.6 third consecutive hit: combo 3")
    _check(s.register_shot(false) == 0, "TP-1.6 miss resets combo to 0")
    _check(s.register_shot(true) == 1, "TP-1.6 hit after miss: combo 1")
    _check(s.best_combo == 3, "TP-1.6 best combo retained (3)")
    s.reset()
    _check(s.combo == 0 and s.best_combo == 0, "TP-1.6 reset clears combo and best combo")
    _check(ScoringService.combo_points(50, 1) == 50, "TP-1.6 combo 1 gives no multiplier")
    _check(ScoringService.combo_points(50, 3) == 75, "TP-1.6 combo 3 multiplies base by 1.5 (75)")


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


## TP-1.17: batas antarzona inklusif; skor dari titik masuk pertama; tanpa skor ganda.
func _test_tp_1_17_scoring_boundaries_and_no_double() -> void:
    var t := Target.new("t17", Vector2(10.0, 5.0), 3.0)
    var exact_outer := ScoringService.classify(t, Vector2(10.0, 8.0))
    _check(not exact_outer.is_empty() and int(exact_outer.points) == 10,
        "TP-1.17 exact outer edge (d == radius) is inclusive and scores outer zone")
    var just_inside := ScoringService.classify(t, Vector2(10.0, 5.0 + 2.0 / 3.0 + 0.001))
    _check(not just_inside.is_empty() and int(just_inside.points) == 10,
        "TP-1.17 just outside middle boundary scores outer zone, not middle")
    var middle_edge := ScoringService.classify(t, Vector2(10.0, 5.0 + 2.0))
    _check(not middle_edge.is_empty() and int(middle_edge.points) == 20,
        "TP-1.17 exact middle boundary (d == 2.0) is inclusive to middle zone")
    var hit := CollisionService.segment_circle_first_hit(
        Vector2(0.0, 5.0), Vector2(20.0, 5.0), Vector2(10.0, 5.0), 3.0
    )
    _check(not hit.is_empty(), "TP-1.17 swept hit detected")
    var scored := ScoringService.score_hit(hit, t)
    _check(not scored.is_empty() and int(scored.points) == 50 and bool(scored.is_perfect),
        "TP-1.17 score from first-entry point (x=7, zone 0), not final position (x=20)")
    var arrow := Arrow.new()
    var s := ScoringService.new()
    arrow.targets = [t.to_collision_dict()]
    arrow.launch(Vector2(0.0, 5.0), Vector2(30.0, 0.0), Vector2(0.0, -9.8))
    var first_result := arrow.advance(0.5)
    _check(not first_result.is_empty(), "TP-1.17 first advance produces a hit")
    _check(s.register_shot(not first_result.is_empty()) == 1, "TP-1.17 combo registered once")
    var second_result := arrow.advance(1.0)
    _check(second_result.is_empty(), "TP-1.17 stuck arrow produces no second hit")
    _check(s.register_shot(not second_result.is_empty()) == 0, "TP-1.17 empty result resets combo (no double score)")
    var t_near := Target.new("near", Vector2(8.0, 5.0), 1.0)
    var t_far := Target.new("far", Vector2(16.0, 5.0), 1.0)
    var multi_hit := CollisionService.segment_targets_first_hit(
        Vector2(0.0, 5.0), Vector2(30.0, 5.0),
        [t_far.to_collision_dict(), t_near.to_collision_dict()]
    )
    _check(not multi_hit.is_empty() and String(multi_hit.id) == "near",
        "TP-1.17 multi-target: first target along path selected")
    var multi_score := ScoringService.score_hit(multi_hit, t_near)
    _check(not multi_score.is_empty() and bool(multi_score.is_perfect),
        "TP-1.17 multi-target: score computed from selected target (near)")


## TP-1.18: level termuat dari data JSON — 3 level, id unik, parameter benar.
func _test_tp_1_18_levels_from_data() -> void:
    var levels := LevelData.load_all_from_file("res://assets/levels/levels.json")
    _check(levels.size() == 3, "TP-1.18 exactly 3 trial levels loaded from data")
    var ids := []
    for level in levels:
        ids.append(level.id)
        _check(level.is_valid(), "TP-1.18 level '%s' valid" % level.id)
        _check(not level.targets.is_empty(), "TP-1.18 level '%s' has targets" % level.id)
    _check(ids[0] == "trial_1" and ids[1] == "trial_2" and ids[2] == "trial_3",
        "TP-1.18 level ids in order trial_1..trial_3")
    var trial_2: LevelData = levels[1]
    _check(absf(trial_2.wind.x - 2.5) < 0.000001, "TP-1.18 level 2 wind parsed (2.5 m/s)")
    _check(absf(trial_2.drag - 0.15) < 0.000001, "TP-1.18 level 2 drag parsed (0.15)")
    _check(trial_2.arrow_count == 5, "TP-1.18 level 2 arrow_count parsed (5)")
    var trial_3: LevelData = levels[2]
    _check(trial_3.targets.size() == 2, "TP-1.18 level 3 has two targets from data")
    var collision_targets := trial_3.to_collision_targets()
    _check(collision_targets.size() == 2 and String(collision_targets[1].id) == "t2",
        "TP-1.18 to_collision_targets preserves order and ids")


## TP-1.19: data level tidak valid ditolak (fail-fast).
func _test_tp_1_19_invalid_level_data_rejected() -> void:
    var no_id := LevelData.from_dict({
        "name": "x", "arrow_count": 3,
        "targets": [{"id": "t", "position": {"x": 1.0, "y": 1.0}, "radius": 1.0}],
    })
    _check(no_id == null, "TP-1.19 level without id rejected")
    var no_targets := LevelData.from_dict({"id": "a", "arrow_count": 3, "targets": []})
    _check(no_targets == null, "TP-1.19 level without targets rejected")
    var bad_arrows := LevelData.from_dict({
        "id": "a", "arrow_count": 0,
        "targets": [{"id": "t", "position": {"x": 1.0, "y": 1.0}, "radius": 1.0}],
    })
    _check(bad_arrows == null, "TP-1.19 level with arrow_count < 1 rejected")
    var bad_target := LevelData.from_dict({
        "id": "a", "arrow_count": 3,
        "targets": [{"id": "t", "position": {"x": 1.0, "y": 1.0}, "radius": -2.0}],
    })
    _check(bad_target == null, "TP-1.19 level with invalid target radius rejected")
    var missing_file := LevelData.load_all_from_file("res://assets/levels/does_not_exist.json")
    _check(missing_file.is_empty(), "TP-1.19 missing file returns empty, not crash")


## TP-1.20: logika zoom kamera murni — zoom saat bidik, kembali mulus, tanpa lompatan.
func _test_tp_1_20_camera_zoom_logic() -> void:
    _check(absf(ArenaCamera.compute_zoom_target(true) - 1.35) < 0.000001,
        "TP-1.20 aiming targets ZOOM_AIM (1.35)")
    _check(absf(ArenaCamera.compute_zoom_target(false) - 1.0) < 0.000001,
        "TP-1.20 not aiming targets ZOOM_NORMAL (1.0)")
    var z := 1.0
    for i in range(120):
        z = ArenaCamera.compute_zoom_step(z, 1.35, 1.0 / 60.0)
    _check(absf(z - 1.35) < 0.01, "TP-1.20 zoom converges smoothly to aim zoom")
    var one_step := ArenaCamera.compute_zoom_step(1.0, 1.35, 1.0 / 60.0)
    _check(one_step > 1.0 and one_step < 1.1,
        "TP-1.20 single frame step is small (no sudden movement)")
    var back := z
    for i in range(240):
        back = ArenaCamera.compute_zoom_step(back, 1.0, 1.0 / 60.0)
    _check(absf(back - 1.0) < 0.001,
        "TP-1.20 zoom returns to normal after release/cancel")
    var clamped := ArenaCamera.compute_zoom_step(1.0, 99.0, 1.0)
    _check(clamped <= ArenaCamera.ZOOM_MAX, "TP-1.20 zoom clamped to ZOOM_MAX")


## TP-1.21: pemetaan VFX angin mengikuti parameter angin fisika.
func _test_tp_1_21_wind_vfx_mapping() -> void:
    var zero := WindVFX.compute_visual_params(Vector2.ZERO, false)
    _check(float(zero.intensity) == 0.0 and int(zero.streaks) == 0,
        "TP-1.21 zero wind: no visual streaks")
    var medium := WindVFX.compute_visual_params(Vector2(4.0, 0.0), false)
    _check(absf(float(medium.intensity) - 0.5) < 0.000001 and absf(float(medium.direction)) < 0.000001,
        "TP-1.21 4 m/s east wind: intensity 0.5, direction 0 rad")
    var max_wind := WindVFX.compute_visual_params(Vector2(0.0, -8.0), false)
    _check(absf(float(max_wind.intensity) - 1.0) < 0.000001,
        "TP-1.21 8 m/s wind: intensity clamped to 1.0")
    var over := WindVFX.compute_visual_params(Vector2(-20.0, 0.0), false)
    _check(absf(float(over.intensity) - 1.0) < 0.000001 and absf(float(over.direction) - PI) < 0.000001,
        "TP-1.21 wind beyond max: intensity 1.0, direction follows sign (pi rad)")
    var low := WindVFX.compute_visual_params(Vector2(4.0, 0.0), true)
    var normal := WindVFX.compute_visual_params(Vector2(4.0, 0.0), false)
    _check(int(low.streaks) < int(normal.streaks),
        "TP-1.21 low_effects mode reduces streak count")


## TP-1.22: preview lintasan memakai BallisticsModel.predict_trajectory (identik).
func _test_tp_1_22_trajectory_preview_uses_model() -> void:
    var preview := TrajectoryPreview.new()
    var origin := Vector2(2.0, 2.0)
    var velocity := Vector2(20.0, 15.0)
    var wind := Vector2(2.5, 0.0)
    preview.update_prediction(origin, velocity, BallisticsModel.DEFAULT_GRAVITY, wind, 0.15)
    var reference := BallisticsModel.new(
        origin, velocity, BallisticsModel.DEFAULT_GRAVITY, wind, 0.15
    ).predict_trajectory(preview.effective_point_count(), 1.0 / 30.0)
    var points := preview.get_points()
    _check(points.size() == reference.size() and points.size() == TrajectoryPreview.DEFAULT_POINT_COUNT,
        "TP-1.22 preview point count matches model prediction (default 40)")
    var identical := true
    for i in points.size():
        if points[i] != reference[i]:
            identical = false
            break
    _check(identical, "TP-1.22 preview points identical to BallisticsModel.predict_trajectory (no duplicated physics)")
    preview.low_effects = true
    preview.update_prediction(origin, velocity, BallisticsModel.DEFAULT_GRAVITY, wind, 0.15)
    _check(preview.get_points().size() == TrajectoryPreview.LOW_EFFECT_POINT_COUNT,
        "TP-1.22 low_effects reduces preview points (15)")
    preview.enabled = false
    preview.update_prediction(origin, velocity, BallisticsModel.DEFAULT_GRAVITY, wind, 0.15)
    _check(preview.get_points().is_empty(), "TP-1.22 disabled preview clears points (FR-GF-004 toggle)")


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
    print("Phase 1 module tests: %d passed, %d failed" % [_passed, _failures.size()])
    for label in _failures:
        print("  FAILED: %s" % label)
