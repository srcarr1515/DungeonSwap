extends "res://Util/StateMachine.gd"
# Called when the node enters the scene tree for the first time.
func _ready():
	current = "chase"
	all = ["death", "hit"]
	transitions = {
	"idle": ["attack", "chase"],
	"chase": ["attack", "idle"],
	"attack": ["idle"],
	"death": []
	}

func death(delta):
	print('dead!')
	parent.queue_free()

func hit(delta):
	pass

func attack(delta):
	set_animation("attack")
	yield(parent.anim_player, "animation_finished")
	state_event({"event": "idle"})
	if parent.playerDetect.target == null:
		parent.playerDetect.check_nearby_entities('player_char')
		if parent.playerDetect.target == null:
			state_event({"event": "chase"})
	
func idle(delta):
	set_animation("idle")

func chase(delta):
	set_animation("walk")
	parent.accelerate_toward_position(Vector2(parent.chase_x, parent.global_position.y), delta)
	parent.knockback = parent.knockback.move_toward(Vector2.ZERO, parent.FRICTION * delta)
	parent.knockback = parent.move_and_slide(parent.knockback)

#	var is_colliding = parent.softCollision.is_colliding()
#	if is_colliding:
#		parent.velocity += parent.softCollision.get_push_vector(is_colliding) * delta * 400

	parent.velocity = parent.move_and_slide(parent.velocity)

func set_animation(anim):
	var anim_player = parent.anim_player
	if anim_player.has_animation(anim):
		anim_player.play(anim)

func every_tick(delta):
	parent.detect_target()
