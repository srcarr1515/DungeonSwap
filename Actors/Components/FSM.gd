extends "res://Util/StateMachine.gd"


func _ready():
	current = "idle"
	all = ["death"]
	transitions = {
	"idle": ["attack", "walk", "death"],
	"walk": ["idle", "death"],
	"attack": ["idle", "death"],
	"death": ["revive"],
	"revive": ["idle"]
	}

func idle(delta):
	set_animation("idle")
	
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
	yield(get_tree().create_timer(0.1), "timeout")
	GameState.death_ct += 1

func revive(delta):
	GameState.death_ct -= 1
	## You are not dead, get back to work.
	parent.detect.radius.set_disabled(false)
	var skill_docks = get_tree().get_nodes_in_group("skill_dock")
	if parent.char_index == 5:
		for dock in skill_docks:
			if parent.char_index == playerVar.cur_party[dock.char_slot]:
				dock.char_status = "active"
	parent.show()
	state_event({"event": "idle"})

func attack(delta):
	set_animation("attack")
	yield(parent.anim_player, "animation_finished")
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
