## TargetVisual — gambar target dengan zona (placeholder kartun sederhana, T-1.6).
## Hanya presentasi; zona skor sebenarnya dihitung ScoringService dari titik impact.

class_name TargetVisual
extends Node2D

var target: Target
var colors: Array[Color] = []


func _draw() -> void:
    if target == null or colors.is_empty():
        return
    for i in range(target.zone_radius_fractions.size() - 1, -1, -1):
        var radius := target.zone_absolute_radius(i)
        var color: Color = colors[i % colors.size()]
        draw_circle(Vector2.ZERO, radius, color)
    draw_arc(Vector2.ZERO, target.radius, 0.0, TAU, 48, Color(0.15, 0.23, 0.42), 0.05)
