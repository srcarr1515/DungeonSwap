extends KinematicBody2D

var velocity = Vector2.ZERO
var action_id = null
export (Vector2) var start_pos = Vector2.ZERO
export (Vector2) var target = Vector2.ZERO
export (String) var is_playing = null
onready var emitter = $Particles2D
#export (Script) var skill_script
#onready var CustomEffect = load(skill_script.get_path()).new()

onready var anim_player = $AnimationPlayer
var atk_power ## must be greater than 0
var action_args = {}


# Called when the node enters the scene tree for the first time.
func _ready():
#	CustomEffect.pre_effects()
	if action_args.has('call'):
		for f in action_args.call:
			var function  = f["func"]
			var params = f["params"]
			callv(function, params)
	velocity = target
	if is_playing != null:
		anim_player.play(is_playing)

func _physics_process(delta):
	move_and_collide(velocity)

func test(b):
	print(b)
	
## does this really do anything?
## I can set variables before I add child!
func init_act(args):
	if args.has("start_position"):
		global_position = args.start_position
	if args.has("target"):
		velocity = args.target
	if args.has("emitter"):
		emitter.set_emitting(args.emitter)
	if args.has('atk_power'):
		atk_power = args.atk_power
