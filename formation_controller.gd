extends Node2D

onready var spawn_points = get_children()
var spawn_left = null
var spawn_right = null
export var formation_left = 0
export var formation_right = 0
var wave_ct_label
var formation_list = [
	[
		"Skeleton_Warrior"
	],
	[
		"Skeleton_Warrior", "Skeleton_Archer"
	],	
	[
		"Wolf", "Skeleton_Warrior"
	],
	[
		"Skeleton_Warrior", "Wolf", "Skeleton_Archer"
	],
	[
		"Wolf", "Skeleton_Warrior", "Skeleton_Archer", "Skeleton_Warrior"
	],
	[
		"Wolf", "Wolf", "Wolf"
	],
	[
		"Skeleton_Archer", "Skeleton_Archer", "Wolf", "Skeleton_Archer"
	],
	[
		"Skeleton_Archer"
	]
]
var waves = [
	0,7,1,1,2,2, ## Tutorial Levels
	2,2,7,1,3,2,4,3,5,7,6
]
onready var total_waves = waves.size()
var current_wave = 0
onready var timer = $Timer

func _ready():
	wave_ct_label = get_tree().get_nodes_in_group("wave_counter").front()
	wave_ct_label.hide()
	if current_wave == 0:
		var body = ""
		body += "Only your outside characters can attack. "
		body += "Move your middle (support) character into an attack role "
		body += "by clicking it (to select) and clicking another "
		body += "character to swap with."
		body += "[At any time click the arrow to the right to skip the tutorial.]"
		ActionController.display_info("Tutorial", body)
		var skill_docks = get_tree().get_nodes_in_group("skill_dock")
		for dock in skill_docks:
			dock.hide()
	if current_wave != 0:
		timer.start()
	
	for spawn in spawn_points:
		if "deployment_group" in spawn:
			if spawn.deployment_group == "left_side_enemy":
				spawn_left = spawn
			elif spawn.deployment_group == "right_side_enemy":
				spawn_right = spawn

func start_wave(wave_index):
	var formation_id = waves[wave_index]
	var args = {
		"formation": formation_list[formation_id],
		"timer_amt": rand_range(2.5, 3.5)
	}
	set_spawn_points(args)
	reset_timers()

func reset_timers(value=null):
	if value != null:
		spawn_left.timer_amt = value
		spawn_right.timer_amt = value
	spawn_left.reset_timer()
	spawn_right.reset_timer()

func set_spawn_points(args):
	for spawn_point in spawn_points:
		for arg_key in args.keys():
			if arg_key == "formation":
				spawn_point.set(arg_key, args[arg_key].duplicate())
			else:
				spawn_point.set(arg_key, args[arg_key])

func _on_Timer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() < 1 && current_wave + 1 <= waves.size():
		print("Staring Wave: ", current_wave + 1, "/", total_waves)
		if current_wave == 1:
			ActionController.display_info("Tutorial", "", null, false)
		elif current_wave == 2:
			var skill_docks = get_tree().get_nodes_in_group("skill_dock")
			for dock in skill_docks:
				dock.show()
			var body = ""
			body += "'Attacking' characters are not able to access "
			body += "their skills, however "
			body += "your support character can use any of his or her "
			body += "skills. Swap characters in and out of support "
			body += "to better maximize skill availability."
			body += " (click to continue)"
			ActionController.display_info("Tutorial", body)
			timer.set_paused(true)
			var game_base = get_tree().get_nodes_in_group('game_base').front()
			yield(game_base, "left_mouse")
			timer.set_paused(false)
			ActionController.display_info("Tutorial", "", null, false)
		elif current_wave == 4:
			var body = ""
			body += "Skills can be activated by clicking on the on-screen "
			body += "button or by using a hotkey ('1', '2', '3' Keyboard Keys), "
			body += "Additionally you can keep a hotkey held down and continuously "
			body += "cast the corresponding spell."
			body += " (click to continue)"
			ActionController.display_info("Tutorial", body)
			## Wait For Mouse Click
			timer.set_paused(true)
			var game_base = get_tree().get_nodes_in_group('game_base').front()
			yield(game_base, "left_mouse")
			timer.set_paused(false)
			ActionController.display_info("Tutorial", "", null, false)
		elif current_wave == 6:
			ActionController.restore_char_cooldowns()
			ActionController.restore_group_health("player_char")
			var skill_docks = get_tree().get_nodes_in_group("skill_dock")
			for dock in skill_docks:
				dock.show()
			var skip_btn = get_tree().get_nodes_in_group("skip_button").front()
			skip_btn.hide()
			wave_ct_label.show()
			update_wave_label()
			var body = ""
			body += "Okay... Tutorial Over... "
			body += "Let's have some fun... "
			body += "But first I'll fully restore your characters. "
			body += " (click to continue)"
			ActionController.display_info("Tutorial", body)
			## Wait For Mouse Click
			timer.set_paused(true)
			var game_base = get_tree().get_nodes_in_group('game_base').front()
			yield(game_base, "left_mouse")
			timer.set_paused(false)
			ActionController.display_info("Tutorial", "", null, false)
		update_wave_label()
		start_wave(current_wave)
		current_wave += 1
		timer.stop()
#	for enemy in enemies:
#		if enemy.state.current == "queued":
#			enemy.state.state_event({"event": "chase"})

func _on_spawnPoint_deploy_finished():
	if timer.is_stopped():
		timer.wait_time = 1.5
		timer.start()

func _on_Game_left_mouse():
	if current_wave == 0:
		ActionController.display_info("Tutorial", "", null, false)
		timer.start()

func update_wave_label():
	wave_ct_label.text = "{current_wave}/{total_waves}".format({"current_wave": current_wave - 6, "total_waves": total_waves - 7})
