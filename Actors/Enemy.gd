extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
onready var playerDetect = $DetectionZone
onready var allyDetect = $AllyDetect
onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var softCollision = $SoftCollision
onready var state = $FSM
onready var stats = $Stats
onready var health_display = $HealthDisplay
onready var act_point = $ActPoint
export(int) var atk_power = 1
export(int) var MOVE_TOLERANCE = 4

export (String) var atk_anim = null
var stun_amt = 0

var knockback = Vector2.ZERO
var is_flipped = false

export var ACCELEARATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export (float) var RANGE_VARIANCE = 0.1

var chase_x = 160

var path := PoolVector2Array() setget set_path

func set_path(value : PoolVector2Array):
	path = value
	if value.size() == 0:
		return
	set_process(true)

var velocity = Vector2.ZERO

func _ready():
	ACCELEARATION *= GameState.game_speed
	MAX_SPEED *= GameState.game_speed
	health_display.init()
	health_display.hide()
	health_display.set_scale(Vector2(0.1, 0.1))
	playerDetect.position.x += rand_range(-20, 20)
	if chase_x < global_position.x:
		toggle_flip(true)

func toggle_flip(flip):
	is_flipped = flip
	if is_flipped:
		scale.x = abs(scale.x) * -1
	else:
		scale.x = abs(scale.x)

func accelerate_toward_position(target_position, delta):
	## Yucky Fix For Overlapping Enemies
#	if is_on_wall():
#		var nearest_target = Helpers.pick_nearest("player_entity", global_position)
#		var target_dist = global_position.distance_to(nearest_target.global_position)
#		if abs(target_dist) < 50:
#			state.state_event({"event": "attack"})
#		else:
#			state.state_event({"event": "queued"})

	var direction = global_position.direction_to(target_position)
#	if stun_amt > 0:
#		velocity = Vector2.ZERO
#		stun_amt -= 0.1
#		if stun_amt < 0:
#			stun_amt = 0
#	else:
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELEARATION * delta)

func get_which_wall_collided():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return "left"
		elif collision.normal.x < 0:
			return "right"
	return "none"

func detect_target():
	if playerDetect.can_see_target():
		state.state_event({"event": "attack", "target": playerDetect.target})

func AnimAction(args={"end_pos":Vector2(3,0)}):
	var atk_object = null
	if atk_anim != null:
		args["start_pos"] = act_point.global_position
		args["action_owner"] = self
		args["atk_power"] = atk_power
		if is_flipped:
			args["is_flipped"] = true
		ActionController.spawn_action(atk_anim, args)

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
