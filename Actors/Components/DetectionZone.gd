extends Area2D
onready var radius = $CollisionShape2D
var target = null

func can_see_target():
	return target != null

func check_nearby_entities(group):
	if target == null:
		var entities = get_overlapping_bodies()
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
	target = body

func _on_body_exited(body):
	target = null
