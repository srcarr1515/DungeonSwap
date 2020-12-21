extends KinematicBody2D
onready var stats = $Stats
onready var health_display = $HealthDisplay
onready var parent = get_parent()

func _ready():
	health_display.init()
	health_display.set_scale(Vector2(0.1, 0.1))

func _on_HurtBox_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("enemy") && area.name == "HitBox":
		stats.health -= entity.atk_power


func _on_Stats_no_health():
	if parent.is_in_group("action"):
		parent.queue_free()
	else:
		queue_free()
