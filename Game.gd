## <emitting_node>.connect("signal_name", <target_node>, "target_method_name") <<--- I keep forgetting this

extends Node2D
var key_code = []
var cheat_modes = []
onready var camera = $Camera
onready var battle_cam_pos = $camPos_Battle
onready var map_cam_pos = $camPos_Map
onready var map = $Minimap
onready var jukebox = $JukeBox
var last_key_code_time


signal left_mouse
func _ready():
#	change_song('Dr-Nomura-loop.ogg')
	GameState.init_parent(self)
	set_game_camera()
	GameState.main_state('map')
	var body = "Escape The Dungeon...\n\n That's it.\n\n"
	body += "If you want something more 'deep' and 'meaningful' go play Disco Elysium."
	var header = "Demo Quest"
#	var start_msg = ActionController.create_msg(body, header)
	ActionController.create_msg(body, header)
#	yield(self, "left_mouse")
#	start_msg.queue_free()
#	var fader = load("res://UI/ScreenFade.tscn")
#	var screen_fader = fader.instance()
#	screen_fader.fade_type = screen_fader.fade.IN
#	camera.add_child(screen_fader)
	pass # Replace with function body
# For testing!
#func _unhandled_input(event):
#	if Input.is_action_just_pressed("left_mouse"):
#		var test_action = load("res://Actions/{atk_anim}.tscn".format({"atk_anim": "bullet"})).instance()
#		test_action.start_pos = get_global_mouse_position()
#		test_action.end_pos = Vector2(3,0)
#		test_action.spawn()

func start_msg():
		var msg = load("res://UI/InfoBox.tscn").instance()
		add_child(msg)
		msg.global_position = get_viewport_rect().size / 2
		msg.set_scale(Vector2(0.75,0.75))
		msg.global_position.y -= 12
		msg.header.text = "Demo Quest"
		msg.body.text = "Clear All The Monsters In The Dungeon...\n\n That's it.\n\n"
		msg.body.text += "If you want something more 'deep' and 'meaningful' go play Disco Elysium."
		msg.show()
		return msg

func change_song(song_file, db=-16):
	var path = "res://Assets/Music/{song_file}"
	jukebox.stream = load(path.format({"song_file": song_file}))
	jukebox.set_volume_db(db)
	jukebox.play()


func _unhandled_input(event):
	if Input.is_action_just_pressed("left_mouse"):
		emit_signal("left_mouse")
#	if InputEventScreenTouch:
#		emit_signal("left_mouse")
	if "scancode" in event:
		var key_pressed = OS.get_scancode_string(event.scancode)
		if event.pressed == false && key_pressed.length() < 2:
			key_code.push_back(key_pressed)
			last_key_code_time = OS.get_ticks_msec()
	
#	print(key_code)

	if key_code == ['I', 'D', 'D', 'Q', 'D']:
		if cheat_modes.has("God Mode"):
			OS.alert('God Mode is turned off')
			cheat_modes = []
		else:
			OS.alert('Welcome to God Mode')
			cheat_modes.push_front("God Mode")
		key_code = []
	if key_code == ['I', 'D', 'K', 'F', 'A']:
		OS.alert('Ah Feeling Refreshed')
		ActionController.restore_char_cooldowns()
		ActionController.restore_group_health("player_char")
		key_code = []
	if key_code == ['I', 'D', 'S', 'P', 'I', 'S', 'P', 'O', 'P', 'D']:
		if cheat_modes.has("No Encounters"):
			OS.alert('Cheat Modes Are Now Turned Off')
			cheat_modes = []
		else:
			OS.alert('Random Encounters Are Turned Off')
			cheat_modes.push_front("No Encounters")
			var player = get_tree().get_nodes_in_group("player_marker").front()
			player.INIT_ENCOUNTER_PERC = 0.0
			player.ENCOUNTER_PERC = 0.0
		key_code = []

func _process(delta):
	if key_code != []:
		if OS.get_ticks_msec() - last_key_code_time > 1000:
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
