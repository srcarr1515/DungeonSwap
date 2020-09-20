extends Node2D
## TODO: Make this a inheritable scene and create a seperate 'CHASE' state (scene).
const state_name = 'CHASE'
export(bool) var INHERIT_STATS = true
export(int) var MAX_SPEED = 50
export(int) var ACCELARATION = 300

export var target_group = 'Player'
var group_targets = []
var velocity = Vector2.ZERO
var target_position = Vector2.ZERO

func initialize(_actor):
	if INHERIT_STATS:
		inherit_stats(_actor)
	group_targets = get_tree().get_nodes_in_group(target_group)

func state_act(_actor, _delta):
	if _actor != null:
		if group_targets.size() > 0:
			target_position = group_targets[0].global_position
		var direction = global_position.direction_to(_actor.global_position)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * _delta)
		accelerate_toward_position(target_position, _delta)
		_actor.move_and_slide(velocity)

func inherit_stats(_actor):
	if "MAX_SPEED" in _actor:
		MAX_SPEED = _actor.MAX_SPEED
	elif "ACCELARATION" in _actor:
		ACCELARATION = _actor.ACCELARATION

func accelerate_toward_position(target_position, delta):
	var direction = global_position.direction_to(target_position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELARATION * delta)
