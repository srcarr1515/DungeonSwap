extends Line2D
var point
export(int) var trail_length
export(bool) var inherit_alpha
var target

func _ready():
	set_as_toplevel(true)
	if target == null:
		target = get_parent()

func _physics_process(delta):
	if inherit_alpha:
		modulate.a = target.modulate.a
	point = target.global_position
	add_point(point)
	if points.size() > trail_length:
		remove_point(0)
