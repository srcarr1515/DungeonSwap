extends "res://Util/StateMachine.gd"
var queue_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	ActionController.connect("on_enemy_death", self, "on_enemy_death")
	current = "chase"
	all = ["death", "hit", "stunned"]
	transitions = {
	"idle": ["attack", "chase"],
	"chase": ["attack", "idle", "queued"],
	"attack": ["idle"],
	"death": [],
	"stunned": ["idle", "chase", "attack"],
	"queued": ["attack", "idle", "chase"]
	}

func on_enemy_death(enemy):
	if current == "queued":
		state_event({"event": "chase"})

func death(delta):
	parent.queue_free()
	
func hit(delta):
	pass

func queued(delta):
	queue_timer += 1
	if queue_timer > 60:
		queue_timer = 0
		parent.allyDetect.check_nearby_entities('enemy')
		if parent.allyDetect.target == null:
			state_event({"event": "chase"})

func on_queued():
	set_animation("idle")

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

func on_stunned():
	set_animation("flash_hit")

func stunned(delta):
#	if parent.stun_amt > 0:
#		parent.velocity = Vector2.ZERO
#		parent.stun_amt -= 0.1
#		if parent.stun_amt <= 0:
#			parent.stun_amt = 0
#	else:
	yield(parent.anim_player, "animation_finished")
	var prev_state = previous
	if prev_state == "stunned":
		prev_state = "chase"
	state_event({"event": prev_state})

func set_animation(anim):
	if anim != "flash_hit":
		parent.sprite.get_material().set_shader_param("flash_modifier", 0)
	var anim_player = parent.anim_player
	if anim_player.has_animation(anim):
		anim_player.play(anim)

func every_tick(delta):
	parent.detect_target()
