## ScoringService — identifikasi zona dan pemberian skor (murni, tanpa node).
##
## Pemisahan tanggung jawab (T-1.5, diperbarui T-1.7/ADR-011):
##   - Deteksi tabrakan: CollisionService (titik masuk pertama + arah datang).
##   - Titik skor (ADR-011): compute_penetration_point — kedalaman penetrasi ujung
##     panah ke dalam geometri target, bukan titik masuk. Tembakan lurus melalui
##     pusat mencapai pusat → Perfect Shot dari jalur gameplay normal.
##   - Identifikasi zona: fungsi statis classify (aturan ADR-009 tidak berubah).
##   - Pemberian skor + combo: kelas ini (state combo per sesi permainan).
##
## Aturan combo (FR-GF-005, ADR-009): bertambah pada tembakan berturut-turut yang
## berhasil (skor > 0); reset ke 0 saat meleset.
##
## Kasus diatur/didokumentasikan:
##   - Panah STUCK tidak menghasilkan skor baru: Arrow.advance mengembalikan kosong
##     saat tidak FLYING (TP-1.17, TP-1.23).
##   - Tabrakan tangensial / arah datang nol / panah mulai di dalam target: titik
##     skor = titik masuk (tepi → zona terluar, inklusif ADR-009).
##   - Arah datang menjauhi pusat (along <= 0): titik skor = titik masuk.
##   - Beberapa target satu langkah: CollisionService memilih target pertama
##     sepanjang jalur (t terkecil); penetrasi dihitung terhadap target tersebut.
##
## Requirement: FR-GF-005. Pengujian: TP-1.5, TP-1.6, TP-1.17, TP-1.23 (04-TEST-PLAN).

class_name ScoringService
extends RefCounted

const EPSILON := 0.000001
## ADR-011: fraksi panjang chord yang ditembus ujung panah hingga titik skor.
## 0.5 = titik tengah chord; tembakan lurus melalui pusat → S = pusat (Perfect).
## Data konfigurasi per level menyusul pada Phase 2 (data, bukan requirement).
const PENETRATION_FRACTION := 0.5

var combo: int = 0
var best_combo: int = 0


## ADR-011: titik skor dari kedalaman penetrasi ujung panah.
## p_entry = titik masuk pertama swept collision; p_direction = arah datang panah.
## Target statis tanpa rotasi: hasil dalam koordinat dunia.
## Geometri: chord L = 2*sqrt(r^2 - h^2), h = jarak tegak lurus garis datang ke pusat
## (dihitung dari p_entry). Kedalaman p = PENETRATION_FRACTION * L, dijepit [0, L].
## S = p_entry + dir * p.
static func compute_penetration_point(p_entry: Vector2, p_direction: Vector2, target: Target) -> Vector2:
    if not target.is_valid() or p_direction.length() <= EPSILON:
        return p_entry
    var dir := p_direction.normalized()
    var to_center := target.position - p_entry
    var along := to_center.dot(dir)
    if along <= 0.0:
        return p_entry
    var h_sq := to_center.length_squared() - along * along
    var r_sq := target.radius * target.radius
    if h_sq >= r_sq:
        return p_entry
    var chord := 2.0 * sqrt(r_sq - h_sq)
    var depth := clampf(PENETRATION_FRACTION * chord, 0.0, chord)
    return p_entry + dir * depth


## Klasifikasi zona dari sebuah titik (aturan ADR-009). Mengembalikan
## {zone_index: int, points: int, is_perfect: bool, distance: float},
## Dictionary kosong bila titik di luar target atau target tidak valid.
static func classify(target: Target, impact_point: Vector2) -> Dictionary:
    if not target.is_valid():
        return {}
    var dist := impact_point.distance_to(target.position)
    if dist > target.radius + EPSILON:
        return {}
    for i in target.zone_radius_fractions.size():
        if dist <= target.zone_absolute_radius(i) + EPSILON:
            return {
                "zone_index": i,
                "points": int(target.zone_points[i]),
                "is_perfect": i == 0,
                "distance": dist,
            }
    return {}


## Hitung skor dari hasil tabrakan CollisionService ({point (titik masuk),
## direction, id}) dan target. Titik skor = titik penetrasi (ADR-011);
## klasifikasi zona dari ADR-009. Kosong bila id target tidak cocok atau tidak valid.
static func score_hit(hit: Dictionary, target: Target) -> Dictionary:
    if hit.is_empty() or String(hit.get("id", "")) != target.id:
        return {}
    if not target.is_valid():
        return {}
    var entry: Vector2 = hit.get("point", Vector2.ZERO)
    var direction: Vector2 = hit.get("direction", Vector2.ZERO)
    return classify(target, compute_penetration_point(entry, direction, target))


## Catat hasil satu tembakan; mengembalikan jumlah combo saat ini.
## scored = true bila tembakan mengenai target (hasil skor tidak kosong).
func register_shot(scored: bool) -> int:
    if scored:
        combo += 1
        best_combo = maxi(best_combo, combo)
    else:
        combo = 0
    return combo


## Skor total dengan poin tembakan; combo mengalikan poin (ADR-009,
## multiplier = 1.0 + 0.25 per combo di atas 1 — data yang dapat diubah).
static func combo_points(base_points: int, current_combo: int) -> int:
    if current_combo <= 1:
        return base_points
    var multiplier := 1.0 + 0.25 * float(current_combo - 1)
    return int(round(float(base_points) * multiplier))


func reset() -> void:
    combo = 0
    best_combo = 0
