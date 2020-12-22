extends "res://Util/StateMachine.gd"
# Called when the node enters the scene tree for the first time.
func _ready():
	current = "chase"
	all = ["death", "hit", "stunned"]
	transitions = {
	"idle": ["attack", "chase"],
	"chase": ["attack", "idle"],
	"attack": ["idle"],
	"death": [],
	"stunned": ["idle", "chase", "attack"]
	}

func death(delta):
	parent.queue_free()

func hit(delta):
	pass

func attack(delta):
	set_animation("attack")
	yield(parent.anim_player, "animation_finished")
	state_event({"event": "idle"})
	if parent.playerDetect.target == null:
		parent.playerDetect.check_nearby_entities('player_entity')
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

func stunned(delta):
	set_animation("flash_hit")
	if parent.stun_amt > 0:
		parent.velocity = Vector2.ZERO
		parent.stun_amt -= 0.1
		if parent.stun_amt <= 0:
			parent.stun_amt = 0
	else:
		state_event({"event": previous})

func set_animation(anim):
	if anim != "flash_hit":
		parent.sprite.get_material().set_shader_param("flash_modifier", 0)
	var anim_player = parent.anim_player
	if anim_player.has_animation(anim):
		anim_player.play(anim)

func every_tick(delta):
	parent.detect_target()
