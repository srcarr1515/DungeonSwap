extends "res://Util/StateMachine.gd"


func _ready():
	current = "idle"
	transitions = {
	"idle": ["attack", "walk"],
	"walk": ["idle"],
	"attack": ["idle"]
	}

func idle(delta):
	set_animation("idle")
	
func walk(delta):
	set_animation("walk")

func attack(delta):
	set_animation("attack")
	yield(parent.anim_player, "animation_finished")
	state_event({"event": "idle"})

func set_animation(anim):
	var anim_player = parent.anim_player
	if anim_player.has_animation(anim):
		anim_player.play(anim)
		if anim_player.current_animation == anim:
			active = false

func every_tick(delta):
	parent.detect_target()
