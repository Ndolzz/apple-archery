## ScoringService — identifikasi zona dan pemberian skor (murni, tanpa node).
##
## Pemisahan tanggung jawab (T-1.5):
##   - Deteksi tabrakan: CollisionService (titik impact = titik masuk pertama).
##   - Identifikasi zona: fungsi statis classify di bawah (dari titik impact aktual,
##     bukan kedekatan visual).
##   - Pemberian skor + combo: kelas ini (state combo per sesi permainan).
##
## Aturan combo (FR-GF-005): bertambah pada tembakan berturut-turut yang berhasil
## (skor > 0); reset ke 0 saat meleset. Multiplier combo TIDAK diimplementasikan pada
## T-1.5 karena tidak diatur spec; hanya penghitung combo (lihat catatan backlog T-1.5).
##
## Kasus diatur/didokumentasikan:
##   - Panah STUCK tidak menghasilkan skor baru: Arrow.advance mengembalikan kosong
##     saat tidak FLYING, sehingga register tidak pernah dipanggil dua kali (TP-1.17).
##   - Target terkena lebih dari sekali: tidak mungkin pada T-1.5 — panah menancap
##     pada hit pertama (Arrow._stick); kasus target bergerak ditangani Phase 2.
##   - Beberapa target satu langkah: CollisionService memilih target pertama sepanjang
##     jalur (t terkecil); skor dihitung dari target tersebut.
##
## Requirement: FR-GF-005. Pengujian: TP-1.5, TP-1.6, TP-1.17 (04-TEST-PLAN).

class_name ScoringService
extends RefCounted

const EPSILON := 0.000001

var combo: int = 0
var best_combo: int = 0


## Klasifikasi zona dari titik impact aktual. Mengembalikan
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


## Hitung skor dari hasil tabrakan CollisionService ({point, id, ...}) dan target.
## Mengembalikan hasil classify; kosong bila id target tidak cocok atau tidak valid.
static func score_hit(hit: Dictionary, target: Target) -> Dictionary:
    if hit.is_empty() or String(hit.get("id", "")) != target.id:
        return {}
    return classify(target, hit.point)


## Catat hasil satu tembakan; mengembalikan jumlah combo saat ini.
## scored = true bila tembakan mengenai target (hasil skor tidak kosong).
func register_shot(scored: bool) -> int:
    if scored:
        combo += 1
        best_combo = maxi(best_combo, combo)
    else:
        combo = 0
    return combo


## Skor total dengan poin tembakan; combo mengalikan poin (keputusan: multiplier
## minimal 1.0 + 0.25 per combo di atas 1 — tercatat ADR-009, data yang dapat diubah).
static func combo_points(base_points: int, current_combo: int) -> int:
    if current_combo <= 1:
        return base_points
    var multiplier := 1.0 + 0.25 * float(current_combo - 1)
    return int(round(float(base_points) * multiplier))


func reset() -> void:
    combo = 0
    best_combo = 0
