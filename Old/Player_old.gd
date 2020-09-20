#extends Actor
#
#
### Temp Vars
#var input_map = {}
#var state = null
#onready var sprite = $Sprite
#var state_machine
#####
#
#func _ready():
#	state_machine = $AnimationTree.get("parameters/playback")
#
#func _unhandled_input(event):
#	## dir is declared in Actor class
#	if map_input(event):
#		dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#		if Input.is_action_just_pressed("ui_jump"):
#			if is_on_floor():
#				velocity.y = jump_speed
#		animate(input_map[event.as_text()])
#
#	## Temp (Animation)
#
### Temp Methods
#func map_input(event):
#	if event.as_text() in input_map.keys():
#		return true
#	var is_valid_key = false
#	for action in InputMap.get_actions():
#		if InputMap.event_is_action(event, action):
#			input_map[event.as_text()] = action
#			is_valid_key = true
#	return is_valid_key
#
#func animate(value):
#	var current_state = state_machine.get_current_node()
#	if state == null:
#		current_state = null
#	if value == state:
#		return true
#	match value:
#		"ui_left":
#			sprite.set_flip_h(true)
#			state = "walk"
#		"ui_right":
#			sprite.set_flip_h(false)
#			state = "walk"
#		"ui_attack":
#			if current_state == "fall":
#				state = "air_kick"
#			else:	
#				state = "punch"
#		"ui_jump":
#			state = "jump"
#		_:
#			state = value
#	if current_state == null:
#		state_machine.start(state)
#	elif current_state != state:
#		state_machine.travel(state)
#
#func _on_Player_is_stopped():
#	animate("idle")
#
#func _on_Player_is_falling():
#	pass
