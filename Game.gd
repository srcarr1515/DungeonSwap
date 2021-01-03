## <emitting_node>.connect("signal_name", <target_node>, "target_method_name") <<--- I keep forgetting this

extends Node2D
var key_code = []
var cheat_modes = []
onready var camera = $Camera
onready var battle_cam_pos = $camPos_Battle
onready var map_cam_pos = $camPos_Map
onready var map = $Map


signal left_mouse
func _ready():
	GameState.init_parent(self)
	set_game_camera()
	GameState.main_state('map')
	pass # Replace with function body
# For testing!
#func _unhandled_input(event):
#	if Input.is_action_just_pressed("left_mouse"):
#		var test_action = load("res://Actions/{atk_anim}.tscn".format({"atk_anim": "bullet"})).instance()
#		test_action.start_pos = get_global_mouse_position()
#		test_action.end_pos = Vector2(3,0)
#		test_action.spawn()

func _unhandled_input(event):
	if Input.is_action_just_pressed("left_mouse"):
		emit_signal("left_mouse")
#	if InputEventScreenTouch:
#		emit_signal("left_mouse")
	if Input.is_key_pressed(KEY_I):
		key_code.push_back('I')
	if Input.is_key_pressed(KEY_D):
		key_code.push_back('D')
	if Input.is_key_pressed(KEY_Q):
		key_code.push_back('Q')
	if key_code == ['I', 'I', 'I']:
		GameState.main_state('map')
		print(GameState.main)
		key_code = []
	if key_code == ['Q', 'Q', 'Q']:
		GameState.main_state('battle')
		print(GameState.main)
		key_code = []
	if key_code == ['I', 'D', 'D', 'Q', 'D']:
		if cheat_modes.has("God Mode"):
			OS.alert('God Mode is turned off')
			cheat_modes = []
		else:
			OS.alert('Welcome to God Mode')
			cheat_modes.push_front("God Mode")
		key_code = []

func _process(delta):
	if key_code != []:
		yield(get_tree().create_timer(1), "timeout")
		key_code = []

func set_game_camera(smooth=true):
	var tween = Tween.new()
	var cam_position = {
		"battle": battle_cam_pos.global_position,
		"map": map_cam_pos.global_position
	}
	tween.interpolate_property(camera, 
	"global_position", 
	camera.global_position, cam_position[GameState.main],
	 0.7, Tween.TRANS_SINE, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
#	camera.global_position = cam_position[GameState.main]
