extends Area2D

export(bool) var destroy_on_collision
var target
var colliding_with
export (String) var target_group = "enemy"

enum TYPE { direct, splash }
export(TYPE) var target_type = TYPE.direct
var collide_executed = false

func _ready():
	if target == null:
		target = get_parent()

func collide(body):
	if body.is_in_group(target_group):
		if target == null:
			target = get_parent()
		ActionController.collide(target, body)
		colliding_with = body
		if destroy_on_collision:
			ActionController.destroy(target)
			target.on_destroyed()
		if body != null && 'stats' in body:
			if target.atk_power != null && target.atk_power > 0:
				if !collide_executed:
					body.stats.health -= target.atk_power
					if target_type == TYPE.direct:
						collide_executed = true


func _on_body_entered(body):
	collide(body)

func _on_body_exited(body):
	pass # Replace with function body.

func _on_ActiveCollision_area_entered(area):
	var body = area.get_parent()
	collide(body)
