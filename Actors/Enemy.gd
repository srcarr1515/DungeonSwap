extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
onready var playerDetect = $DetectionZone
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var softCollision = $SoftCollision
onready var state = $FSM
onready var stats = $Stats
onready var health_display = $HealthDisplay
export(int) var atk_power = 1
export(int) var MOVE_TOLERANCE = 4

var stun_amt = 0

var knockback = Vector2.ZERO
var is_flipped = false

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
	health_display.init()
	health_display.hide()
	health_display.set_scale(Vector2(0.1, 0.1))
	if chase_x < global_position.x:
		toggle_flip(true)

func toggle_flip(flip):
	is_flipped = flip
	if is_flipped:
		scale.x = abs(scale.x) * -1
	else:
		scale.x = abs(scale.x)

func accelerate_toward_position(target_position, delta):
	var direction = global_position.direction_to(target_position)
#	if stun_amt > 0:
#		velocity = Vector2.ZERO
#		stun_amt -= 0.1
#		if stun_amt < 0:
#			stun_amt = 0
#	else:
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELEARATION * delta)
	

func detect_target():
	if playerDetect.can_see_target():
		state.state_event({"event": "attack", "target": playerDetect.target})

func _on_HurtBox_area_entered(area):
	var entity = area.get_parent()
	if entity.is_in_group("player_char") && area.name == "HitBox":
#		if !entity.attack_queue.has(self):
#			entity.attack_queue.push_back(self)
		if !entity.has_target:
			stats.health -= entity.atk_power
			entity.has_target = true
#	stats.health -= entity.atk_power
#	print(stats.health)
#	knockback = area.knockback_vector * 120
	
func mirror_offset():
	## Weird edge case with Skeleton Warrior...
	## Yucky bug fix where the offset multiplier isn't factored in.
	if sprite.is_flipped_h():
		sprite.offset.x *= -1

func _on_Stats_no_health():
	state.state_event({"event": "death"})
