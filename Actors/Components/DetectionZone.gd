extends Area2D
onready var radius = $CollisionShape2D
var target = null
export (String) var target_group = "enemy"

func can_see_target():
	return target != null

func check_nearby_entities(group=target_group):
	if target == null:
		var entities = get_overlapping_bodies()
		if entities.size() < 1:
			var areas = get_overlapping_areas()
			for area in areas:
				entities.push_front(area.get_parent())
		var targets = []
		if group == null:
			targets = entities
		else:
			for e in entities:
				if e.is_in_group(group):
					targets.push_front(e)
		if targets.size() > 0:
			target = targets.front()

func _on_body_entered(body):
	if body.is_in_group(target_group):
		target = body

func _on_body_exited(body):
	if body.is_in_group(target_group):
		target = null

func _on_DetectionZone_area_entered(area):
	var parent = area.get_parent()
	if parent.is_in_group(target_group):
		target = area

func _on_DetectionZone_area_exited(area):
	var parent = area.get_parent()
	if parent.is_in_group(target_group):
		target = null
