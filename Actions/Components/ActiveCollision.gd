extends Area2D

export(bool) var destroy_on_collision
var target
var colliding_with

func _ready():
	if target == null:
		target = get_parent()

func collide(body):
	if target == null:
		target = get_parent()
	ActionController.collide(target, body)
	colliding_with = body
	if destroy_on_collision:
		ActionController.destroy(target)
		target.on_destroyed()
	if body != null && 'stats' in body:
		if target.atk_power != null && target.atk_power > 0:
			body.stats.health -= target.atk_power

func _on_body_entered(body):
	collide(body)

func _on_body_exited(body):
	pass # Replace with function body.

func _on_ActiveCollision_area_entered(area):
	var body = area.get_parent()
	collide(body)
