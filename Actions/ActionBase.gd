extends KinematicBody2D

var velocity = Vector2.ZERO
export (float) var max_speed = 64
export (float) var accel = 1.0

var action_id = null

export (Vector2) var start_pos = Vector2.ZERO
export (Vector2) var end_pos = Vector2.ZERO

enum MOVEMENT { bullet, pathfinder, fixed }
export(MOVEMENT) var movement_type = MOVEMENT.bullet
export(bool) var flippable = true
export(bool) var is_flipped = false

export (Vector2) var target = Vector2.ZERO
export (String) var is_playing = null

export (PackedScene) var onCollisionObject
export (PackedScene) var onDestroyedObject


onready var emitter = $Particles2D
export(bool) var is_emitting = true
#export (Script) var skill_script
#onready var CustomEffect = load(skill_script.get_path()).new()

onready var anim_player = $AnimationPlayer
var atk_power ## must be greater than 0
var action_args = {}


# Called when the node enters the scene tree for the first time.
func _ready():
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

func spawn():
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
	

