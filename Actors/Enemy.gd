extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
onready var playerDetect = $DetectionZone
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var softCollision = $SoftCollision
onready var state = $FSM
onready var stats = $Stats
export(int) var MOVE_TOLERANCE = 4

var knockback = Vector2.ZERO

export var ACCELEARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
var chase_x = 160

var path := PoolVector2Array() setget set_path

func set_path(value : PoolVector2Array):
	path = value
	if value.size() == 0:
		return
	set_process(true)

var velocity = Vector2.ZERO

func _ready():
	if chase_x < global_position.x:
		toggle_flip(true)

func toggle_flip(flip):
	if flip == null:
		flip = sprite.is_flipped_h()
	if sprite.is_flipped_h() != flip:
		if sprite.offset != Vector2.ZERO:
			sprite.offset *= -1
	if flip:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)

func accelerate_toward_position(target_position, delta):
	var direction = global_position.direction_to(target_position)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELEARATION * delta)

func detect_target():
	if playerDetect.can_see_target():
		state.state_event({"event": "attack", "target": playerDetect.target})

func _on_HurtBox_area_entered(area):
	stats.health -= 1
#	print(stats.health)
#	knockback = area.knockback_vector * 120
	
func mirror_offset():
	## Weird edge case with Skeleton Warrior...
	## Yucky bug fix where the offset multiplier isn't factored in.
	if sprite.is_flipped_h():
		sprite.offset.x *= -1

func _on_Stats_no_health():
	state.state_event({"event": "death"})
