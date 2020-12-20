extends Node2D
var key_code = []
var cheat_modes = []
func _ready():
	pass # Replace with function body
# For testing!
#func _unhandled_input(event):
#	if Input.is_action_just_pressed("left_mouse"):
#		var test_action = load("res://Actions/{atk_anim}.tscn".format({"atk_anim": "bullet"})).instance()
#		test_action.start_pos = get_global_mouse_position()
#		test_action.end_pos = Vector2(3,0)
#		test_action.spawn()

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_I):
		key_code.push_back('I')
	if Input.is_key_pressed(KEY_D):
		key_code.push_back('D')
	if Input.is_key_pressed(KEY_Q):
		key_code.push_back('Q')
	if key_code == ['I', 'D', 'D', 'Q', 'D']:
		if cheat_modes.has("God Mode"):
			OS.alert('God Mode is turned off')
			cheat_modes = []
		else:
			OS.alert('Welcome to God Mode')
			cheat_modes.push_front("God Mode")
		key_code = []

