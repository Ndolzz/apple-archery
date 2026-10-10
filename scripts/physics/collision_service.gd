## CollisionService — deteksi tabrakan swept segment-vs-circle (murni, tanpa node).
##
## Masalah yang diselesaikan (T-1.4): panah dapat bergerak sangat cepat; collision
## diskret (cek posisi akhir per frame) dapat melewati target. Solusi: swept collision —
## seluruh segmen perpindahan panah pada satu timestep diperiksa terhadap lingkaran target.
##
## Algoritma: persamaan kuadrat |a + t*d - center|^2 = r^2; akar terkecil t dalam [0,1]
## adalah titik masuk pertama panah ke target (bukan titik terdalam). Bila panah sudah
## berada di dalam target (C <= 0), impact pada posisi awal segmen (t = 0).
##
## ADR-011 (T-1.7): hasil tabrakan menyertakan "direction" — arah segmen ternormalisasi
## saat hit — sehingga ScoringService dapat menghitung titik skor dari kedalaman
## penetrasi. Deteksi tabrakan dan pemilihan target (t terkecil) tidak berubah.
##
## Satuan: konsisten SI dengan BallisticsModel (meter). Semua fungsi tanpa efek samping.
##
## Requirement: FR-GF-003. Pengujian: TP-1.12, TP-1.13, TP-1.23 (04-TEST-PLAN).

class_name CollisionService
extends RefCounted

const EPSILON := 0.000001


## Hasil: {hit: bool, t: float, point: Vector2, direction: Vector2}.
## t = parameter segmen [0..1]; point = titik masuk pertama; direction = arah
## segmen ternormalisasi (Vector2.ZERO bila segmen degenerate) untuk penetrasi (ADR-011).
## Dictionary kosong berarti tidak ada tabrakan.
static func segment_circle_first_hit(
    p_from: Vector2,
    p_to: Vector2,
    p_center: Vector2,
    p_radius: float
) -> Dictionary:
    if p_radius <= 0.0:
        push_error("CollisionService.segment_circle_first_hit: radius must be > 0, got %f" % p_radius)
        return {}
    var d := p_to - p_from
    var f := p_from - p_center
    var a := d.dot(d)
    var direction := Vector2.ZERO
    if a >= EPSILON:
        direction = d / sqrt(a)
    if a < EPSILON:
        if f.length() <= p_radius:
            return {"hit": true, "t": 0.0, "point": p_from, "direction": direction}
        return {}
    if f.length() <= p_radius:
        return {"hit": true, "t": 0.0, "point": p_from, "direction": direction}
    var b := 2.0 * f.dot(d)
    var c := f.dot(f) - p_radius * p_radius
    var disc := b * b - 4.0 * a * c
    if disc < 0.0:
        return {}
    var sq := sqrt(disc)
    var t1 := (-b - sq) / (2.0 * a)
    var t2 := (-b + sq) / (2.0 * a)
    var t := -1.0
    if t1 >= 0.0 and t1 <= 1.0:
        t = t1
    elif t2 >= 0.0 and t2 <= 1.0:
        t = t2
    if t < 0.0:
        return {}
    return {"hit": true, "t": t, "point": p_from + d * t, "direction": direction}


## Periksa segmen terhadap daftar target {position: Vector2, radius: float, id: Variant}.
## Mengembalikan tabrakan dengan t terkecil (target pertama yang tersentuh sepanjang jalur),
## ditambah "target_index" dan "id" target. Dictionary kosong bila tidak ada tabrakan.
static func segment_targets_first_hit(
    p_from: Vector2,
    p_to: Vector2,
    p_targets: Array
) -> Dictionary:
    var best: Dictionary = {}
    for i in p_targets.size():
        var target: Dictionary = p_targets[i]
        var result := segment_circle_first_hit(
            p_from, p_to, target.get("position", Vector2.ZERO), float(target.get("radius", 0.0))
        )
        if result.is_empty():
            continue
        if best.is_empty() or float(result.t) < float(best.t):
            best = result
            best["target_index"] = i
            best["id"] = target.get("id", i)
    return best
