extends Node2D

func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if Input.is_action_pressed("right_mouse") && GameState.sub == 'ready':
		var nearest_char = Helpers.pick_nearest("player_char", get_global_mouse_position())
#		var pchars = get_tree().get_nodes_in_group("player_char")
#		var nearest_char = pchars[0]
#		for c in pchars:
#			if c.global_position.distance_to(get_global_mouse_position()) < nearest_char.global_position.distance_to(get_global_mouse_position()):
#				nearest_char = c
		nearest_char.state.state_event({"event": "attack"})

		
		
