extends Area2D

func is_colliding():
	var areas = get_overlapping_areas()
	if areas.size() < 1:
		return false
	else:
		return areas

func get_push_vector(areas):
	var push_vector = Vector2.ZERO
	if areas:
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)
		push_vector = push_vector.normalized()
	return push_vector
