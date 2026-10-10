## Target — data target statis dengan zona skor (murni, tanpa node).
##
## Struktur zona: lingkaran konsentris. Zona didefinisikan sebagai fraksi radius target
## (0..1] dengan poin menurun ke arah luar; zona 0 adalah zona pusat (Perfect Shot).
## Batas antarzona inklusif terhadap zona dalam: jarak <= radius zona menghasilkan zona
## tersebut (konsisten dengan collision yang menerima titik tepat pada batas target).
##
## Konfigurasi bawaan (ADR-009, tercatat di 02-DECISIONS.md): 3 zona, fraksi radius
## 1/3, 2/3, 1.0; poin 50, 20, 10. Nilai ini adalah data yang dapat diubah per level
## tanpa mengubah requirement — spec FR-GF-005 hanya mengamanatkan zona pusat > tepi.
##
## Validasi: radius <= 0, zona kosong, fraksi tidak naik, atau fraksi terakhir != 1.0
## ditolak dengan push_error dan target dianggap tidak valid (is_valid() = false);
## collision terhadap target tidak valid tidak menghasilkan skor.
##
## Requirement: FR-GF-005. Pengujian: TP-1.5, TP-1.17 (04-TEST-PLAN).

class_name Target
extends RefCounted

const DEFAULT_ZONE_FRACTIONS: Array[float] = [1.0 / 3.0, 2.0 / 3.0, 1.0]
const DEFAULT_ZONE_POINTS: Array[int] = [50, 20, 10]

var position: Vector2
var radius: float
var zone_radius_fractions: Array[float]
var zone_points: Array[int]
var id: String


func _init(
    p_id: String,
    p_position: Vector2,
    p_radius: float,
    p_zone_fractions: Array[float] = DEFAULT_ZONE_FRACTIONS,
    p_zone_points: Array[int] = DEFAULT_ZONE_POINTS
) -> void:
    id = p_id
    position = p_position
    radius = p_radius
    zone_radius_fractions = p_zone_fractions
    zone_points = p_zone_points


func is_valid() -> bool:
    if radius <= 0.0:
        push_error("Target.is_valid: radius must be > 0, got %f (id=%s)" % [radius, id])
        return false
    if zone_radius_fractions.is_empty() or zone_points.size() != zone_radius_fractions.size():
        push_error("Target.is_valid: zones mismatch (id=%s)" % id)
        return false
    var prev := 0.0
    for i in zone_radius_fractions.size():
        var frac: float = zone_radius_fractions[i]
        if frac <= prev or frac > 1.0:
            push_error("Target.is_valid: zone fractions must be ascending in (0,1] (id=%s)" % id)
            return false
        if zone_points[i] <= 0:
            push_error("Target.is_valid: zone points must be > 0 (id=%s)" % id)
            return false
        prev = frac
    if absf(prev - 1.0) > 0.000001:
        push_error("Target.is_valid: last zone fraction must be 1.0 (id=%s)" % id)
        return false
    return true


## Representasi Dictionary untuk CollisionService ({position, radius, id}).
func to_collision_dict() -> Dictionary:
    return {"position": position, "radius": radius, "id": id}


## Radius absolut suatu zona (meter).
func zone_absolute_radius(zone_index: int) -> float:
    return radius * float(zone_radius_fractions[zone_index])
