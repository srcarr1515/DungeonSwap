extends "res://Actions/Effects/EffectBase.gd"

func detect_entity(group=null, method=null):
	## Using inherited method of the same name.
	.detect_entity()
	if parent.detect_zone.can_see_target():
		var target = parent.detect_zone.target
		if target.state.current == "death":
			target.state.state_event({"event": "revive"})
		elif target.state.current != "death":
			parent.atk_power = 0 ## Only heal people who were just revived.
