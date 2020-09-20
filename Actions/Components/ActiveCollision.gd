extends Area2D

export(bool) var destroy_on_collision
var target

func _ready():
	if target == null:
		target = get_parent()

func _on_body_entered(body):
	print(body)
	ActionController.collide(target, body)
	if destroy_on_collision:
		ActionController.destroy(target)
	if body != null && 'stats' in body:
		if target.atk_power != null && target.atk_power > 0:
			print(target.atk_power)
			body.stats.health -= target.atk_power

func _on_body_exited(body):
	pass # Replace with function body.
