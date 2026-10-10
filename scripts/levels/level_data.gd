## LevelData — data level murni (ADR-003: data-driven, tanpa scene per level).
##
## Skema (JSON, assets/levels/levels.json):
##   { "levels": [ { "id", "name", "wind": {x, y}, "drag", "arrow_count",
##     "targets": [ { "id", "position": {x, y}, "radius", "zone_points": [..] } ] } ] }
##
## Satuan konsisten BallisticsModel: posisi meter, wind m/s, drag 1/s.
## zone_points opsional (default ADR-009: [50, 20, 10]); fraksi zona tetap default.
##
## Validasi: id unik dan tidak kosong, minimal satu target valid, arrow_count >= 1,
## wind dan drag numerik. Loader menolak seluruh berkas bila satu level tidak valid
## (gagal cepat; tidak ada level rusak yang dimuat diam-diam).
##
## Requirement: FR-LV-001 (dasar). Pengujian: TP-1.18, TP-1.19 (04-TEST-PLAN).

class_name LevelData
extends RefCounted

const DEFAULT_ZONE_POINTS: Array[int] = [50, 20, 10]

var id: String
var display_name: String
var wind: Vector2
var drag: float
var arrow_count: int
var targets: Array


static func from_dict(data: Dictionary) -> LevelData:
    var level := LevelData.new()
    level.id = String(data.get("id", ""))
    level.display_name = String(data.get("name", level.id))
    var wind_dict: Dictionary = data.get("wind", {})
    level.wind = Vector2(float(wind_dict.get("x", 0.0)), float(wind_dict.get("y", 0.0)))
    level.drag = float(data.get("drag", 0.0))
    level.arrow_count = int(data.get("arrow_count", 1))
    for t in data.get("targets", []):
        var target := _target_from_dict(t)
        if target == null or not target.is_valid():
            push_error("LevelData.from_dict: invalid target in level '%s'" % level.id)
            return null
        level.targets.append(target)
    if not level.is_valid():
        return null
    return level


## Muat seluruh level dari berkas JSON. Mengembalikan Array[LevelData];
## Array kosong bila berkas tidak ada, JSON rusak, atau ada level tidak valid.
static func load_all_from_file(path: String) -> Array:
    if not FileAccess.file_exists(path):
        push_error("LevelData.load_all_from_file: file not found: %s" % path)
        return []
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("LevelData.load_all_from_file: cannot open: %s" % path)
        return []
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("levels"):
        push_error("LevelData.load_all_from_file: invalid JSON structure: %s" % path)
        return []
    var levels: Array = []
    var seen_ids := {}
    for entry in parsed.get("levels", []):
        var level := from_dict(entry)
        if level == null:
            return []
        if seen_ids.has(level.id):
            push_error("LevelData.load_all_from_file: duplicate level id '%s'" % level.id)
            return []
        seen_ids[level.id] = true
        levels.append(level)
    return levels


func is_valid() -> bool:
    if id.is_empty():
        push_error("LevelData.is_valid: empty id")
        return false
    if arrow_count < 1:
        push_error("LevelData.is_valid: arrow_count must be >= 1 (id=%s)" % id)
        return false
    if targets.is_empty():
        push_error("LevelData.is_valid: no targets (id=%s)" % id)
        return false
    if drag < 0.0:
        push_error("LevelData.is_valid: drag must be >= 0 (id=%s)" % id)
        return false
    return true


## Dictionary target untuk CollisionService (urutan pemuatan dipertahankan).
func to_collision_targets() -> Array:
    var result: Array = []
    for target in targets:
        result.append(target.to_collision_dict())
    return result


static func _target_from_dict(data: Dictionary) -> Target:
    if not data.has("id") or not data.has("position") or not data.has("radius"):
        push_error("LevelData._target_from_dict: missing required fields")
        return null
    var pos_dict: Dictionary = data.get("position", {})
    var zone_points: Array[int] = []
    for p in data.get("zone_points", []):
        zone_points.append(int(p))
    if zone_points.is_empty():
        zone_points = DEFAULT_ZONE_POINTS
    return Target.new(
        String(data.get("id")),
        Vector2(float(pos_dict.get("x", 0.0)), float(pos_dict.get("y", 0.0))),
        float(data.get("radius", 0.0)),
        Target.DEFAULT_ZONE_FRACTIONS,
        zone_points
    )
