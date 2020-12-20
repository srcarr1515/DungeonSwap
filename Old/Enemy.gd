extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
onready var playerDetect = $PlayerDetectionZone
onready var sprite = $Sprite
onready var softCollision = $SoftCollision
export(int) var MOVE_TOLERANCE = 4

var knockback = Vector2.ZERO

export var ACCELEARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200


var path := PoolVector2Array() setget set_path

func set_path(value : PoolVector2Array):
	path = value
	if value.size() == 0:
		return
	set_process(true)

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var state = IDLE

onready var stats = $Stats
#onready var wanderControl = $WanderController

func _ready():
	pass
#	state = pick_random_state([IDLE, WANDER])

func accelerate_toward_position(target_position, delta):
	var direction = global_position.direction_to(target_position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELEARATION * delta)
	sprite.flip_h = velocity.x < 0

func _physics_process(delta):
	accelerate_toward_position(Vector2(160,96), delta)
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

#	match state:
#		IDLE:
#			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
#			seek_player()
#
#			if wanderControl.get_time_left() == 0:
#				state = pick_random_state([IDLE, WANDER], rand_range(1,3))
##				wanderControl.set_wander_timer(rand_range(1,3))
#		WANDER:
#			if wanderControl.get_time_left() == 0:
#				state = pick_random_state([IDLE, WANDER], rand_range(1,3))
##				wanderControl.set_wander_timer(rand_range(1,3))
#
#			if global_position.distance_to(wanderControl.target_position) <= MOVE_TOLERANCE:
#				state = pick_random_state([IDLE, WANDER], rand_range(1,3))
#
#			accelerate_toward_position(wanderControl.target_position, delta)
#		CHASE:
#			var player = playerDetect.player
#			if player != null:
##				var direction = global_position.direction_to(player.global_position)
##				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELEARATION * delta)
##				sprite.flip_h = velocity.x < 0
#				accelerate_toward_position(player.global_position, delta)
#			else:
#				state = IDLE
	var is_colliding = softCollision.is_colliding()
	if is_colliding:
		velocity += softCollision.get_push_vector(is_colliding) * delta * 400

	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetect.can_see_player():
		state = CHASE

#func pick_random_state(state_list, wander_range=null):
#	state_list.shuffle()
#	if wander_range != null:
#		wanderControl.set_wander_timer(rand_range(1,3))
#	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120

#func _on_Stats_no_health():
#	queue_free()
#	var enemyDeathEffect = EnemyDeathEffect.instance()
#	get_parent().add_child(enemyDeathEffect)
#	enemyDeathEffect.global_position = global_position
