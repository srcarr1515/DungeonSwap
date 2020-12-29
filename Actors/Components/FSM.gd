extends "res://Util/StateMachine.gd"


func _ready():
	current = "idle"
	all = ["death", "cast"]
	transitions = {
	"idle": ["attack", "walk", "death"],
	"walk": ["idle", "death"],
	"attack": ["idle", "death"],
	"death": ["revive"],
	"revive": ["idle"],
	"cast": ["idle"]
	}

func idle(delta):
	set_animation("idle")

func cast(delta):
	set_animation("cast")
	yield(parent.anim_player, "animation_finished")
	state_event({"event": "idle"})

func walk(delta):
	set_animation("walk")
	
func death(delta):
	set_animation("idle")
	## You are dead, stop detecting things...
	parent.detect.radius.set_disabled(true)
	var skill_docks = get_tree().get_nodes_in_group("skill_dock")
	### Dead people can't cast spells...
	for dock in skill_docks:
		if parent.char_index == playerVar.cur_party[dock.char_slot]:
			dock.char_status = "death"
	### I don't have a death animation, let's just hide until then.
	parent.hide()
	var player_chars = get_tree().get_nodes_in_group("player_char")
	var death_ct = 0
	for pc in player_chars:
		if pc.state.current == "death":
			death_ct += 1
	if death_ct >= 3:
		GameState.set_death_ct(death_ct)
	yield(get_tree().create_timer(0.1), "timeout")
#	GameState.death_ct += 1

func revive(delta):
#	GameState.death_ct -= 1
	## You are not dead, get back to work.
	parent.detect.radius.set_disabled(false)
	var skill_docks = get_tree().get_nodes_in_group("skill_dock")
	for dock in skill_docks:
		if parent.char_index == playerVar.cur_party[dock.char_slot]:
			dock.char_status = "active"
	parent.show()
	state_event({"event": "idle"})

func attack(delta):
	set_animation("attack")
#	var attack_target = parent.attack_queue.front()
#	if attack_target != null:
#		attack_target.stats.health -= parent.atk_power
#		parent.attack_queue = []
	yield(parent.anim_player, "animation_finished")
	parent.has_target = false
	state_event({"event": "idle"})
	if parent.detect.target == null:
		parent.detect.check_nearby_entities('enemy')

func set_animation(anim):
	var anim_player = parent.anim_player
	if anim_player.has_animation(anim):
		anim_player.play(anim)
		if anim_player.current_animation == anim:
			active = false

func every_tick(delta):
	if current != "death":
		parent.detect_target()
