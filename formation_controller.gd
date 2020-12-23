extends Node2D

onready var spawn_points = get_children()
var spawn_left = null
var spawn_right = null
export var formation_left = 0
export var formation_right = 0
var formation_list = [
	[
		"Skeleton_Warrior"
	],
	[
		"Skeleton_Warrior", "Skeleton_Warrior"
	],	
	[
		"Wolf", "Skeleton_Warrior"
	],
	[
		"Skeleton_Warrior", "Wolf", "Skeleton_Warrior"
	]
]
var waves = [
	0,0,1,1,2,3
]
onready var total_waves = waves.size()
var current_wave = 0
onready var timer = $Timer

func _ready():
	if current_wave == 0:
		var body = ""
		body += "Only your outside characters can attack. "
		body += "Move your middle (support) character into an attack role "
		body += "by clicking it (to select) and clicking another "
		body += "character to swap with."
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
	if enemies.size() < 1:
		print("Staring Wave: ", current_wave, "/", total_waves)
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
			ActionController.display_info("Tutorial", body)
			timer.set_paused(true)
			var game_base = get_tree().get_nodes_in_group('game_base').front()
			yield(game_base, "left_mouse")
			timer.set_paused(false)
		elif current_wave == 3:
			ActionController.display_info("Tutorial", "", null, false)
		elif current_wave == 4:
			var body = ""
			body += "Skills can be activated by clicking on the on-screen "
			body += "button or by using a hotkey ('1', '2', '3' Keyboard Keys), "
			body += "Additionally you can keep a hotkey held down and continuously "
			body += "cast the corresponding spell."
			ActionController.display_info("Tutorial", body)
			## Wait For Mouse Click
			timer.set_paused(true)
			var game_base = get_tree().get_nodes_in_group('game_base').front()
			yield(game_base, "left_mouse")
			timer.set_paused(false)
			##
		elif current_wave == 5:
			ActionController.display_info("Tutorial", "", null, false)
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
		timer.start()
