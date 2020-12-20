extends KinematicBody2D

export (float) var delay = 5.0

var velocity = Vector2.ZERO
export (float) var max_speed = 64
export (float) var accel = 1.0

var action_id = null

export (Vector2) var start_pos = Vector2.ZERO
export (Vector2) var end_pos = Vector2.ZERO
export (Vector2) var slot_pos = Vector2.ZERO

enum MOVEMENT { bullet, pathfinder, fixed }
export(MOVEMENT) var movement_type = MOVEMENT.bullet
export(bool) var flippable = true
export(bool) var is_flipped = false

export (Vector2) var target = Vector2.ZERO
export (String) var is_playing = null
export (bool) var is_healing = false

export (PackedScene) var onCollisionObject
export (PackedScene) var onDestroyedObject
export (PackedScene) var onTriggerObject

export (String) var customScriptPath = null
var CustomScript

export (String) var char_animation ## Not done yet...
export (int) var  start_act_point = -1 ## No act point specified


onready var emitter = $Particles2D
export(bool) var is_emitting = true
#export (Script) var skill_script
#onready var CustomEffect = load(skill_script.get_path()).new()

onready var detect_zone = $DetectionZone
onready var collision = $ActiveCollision
onready var anim_player = $AnimationPlayer
var atk_power = 0 ## must be greater than 0
var action_args = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	if customScriptPath != null:
		CustomScript = load(customScriptPath).new()
		CustomScript.init(self)
	emitter.emitting = is_emitting
#	CustomEffect.pre_effects()
#	init_movement()
	if action_args.has('call'):
		for f in action_args.call:
			var function  = f["func"]
			var params = f["params"]
			callv(function, params)
	if is_playing != null:
		anim_player.play(is_playing)

func _physics_process(delta):
	move(delta)
	
## does this really do anything?
## I can set variables before I add child!
func init_act(args):
	if args.has("start_position") && typeof(args.start_position) == 5:
		global_position = args.start_position
	if args.has("target"):
		velocity = args.target
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	if args.has("emitter"):
		emitter.set_emitting(args.emitter)
	if args.has('atk_power'):
		atk_power = args.atk_power

func move(delta):
	if movement_type == MOVEMENT.bullet:
		move_and_collide(velocity)

func init_movement():
	global_position = start_pos
	end_pos.x = end_pos.x * accel
	end_pos.y = end_pos.y * accel
	velocity = end_pos
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

func toggle_flip(flip):
	is_flipped = flip
	if is_flipped:
		scale.x = abs(scale.x) * -1
	else:
		scale.x = abs(scale.x)

func on_destroyed():
	if onDestroyedObject != null:
		var on_destroyed_instance = onDestroyedObject.instance()
		on_destroyed_instance.global_position = global_position
		ActionController.spawn_instance(on_destroyed_instance)

func on_collision():
	if onCollisionObject != null:
		var on_collision_instance = onCollisionObject.instance()
		on_collision_instance.global_position = global_position
		ActionController.spawn_instance(on_collision_instance)

func on_trigger(inherit_stat=false):
	if onTriggerObject != null:
		var on_trigger_instance = onTriggerObject.instance()
		on_trigger_instance.global_position = global_position
		if inherit_stat:
			on_trigger_instance.atk_power = atk_power
		ActionController.spawn_instance(on_trigger_instance)

func detect_entity(group=null, method=null):
	if customScriptPath != null:
		CustomScript.detect_entity(group, method)
	if detect_zone.can_see_target():
		print(detect_zone.target)
		if method == null:
			if "stats" in detect_zone.target:
				detect_zone.target.stats.health -= atk_power
		## callv(method)

func destroy():
	ActionController.destroy(self)

func spawn():
	if is_healing:
		atk_power = atk_power * -1
	if movement_type == MOVEMENT.fixed:
		start_pos = slot_pos
	init_movement()
	ActionController.spawn_instance(self)
	if flippable:
		if is_flipped:
			toggle_flip(true)
		else:
			var end_position = end_pos
			if movement_type == MOVEMENT.bullet:
				end_position = start_pos + end_pos
			if start_pos > end_position:
				toggle_flip(true)
	if is_flipped:
		velocity.x = velocity.x * -1
	

