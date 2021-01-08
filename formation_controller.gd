extends Node2D

onready var spawn_points = get_children()
var spawn_left = null
var spawn_right = null
onready var timer = $Timer
var formation_set = []


## maybe useless?
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
var current_wave = -1

func _ready():
#	TUTORIAL CODE (don't think I need it anymore')
#	wave_ct_label = get_tree().get_nodes_in_group("wave_counter").front()
#	wave_ct_label.hide()
#	if current_wave == 0:
#		var body = ""
#		body += "Only your outside characters can attack. "
#		body += "Move your middle (support) character into an attack role "
#		body += "by clicking it (to select) and clicking another "
#		body += "character to swap with."
#		body += "[At any time click the arrow to the right to skip the tutorial.]"
#		ActionController.display_info("Tutorial", body)
#		var skill_docks = get_tree().get_nodes_in_group("skill_dock")
#		for dock in skill_docks:
#			dock.hide()
#	if current_wave > 0:
#		timer.start()
#GameState.main_state('map')
	
	for spawn in spawn_points:
		if "deployment_group" in spawn:
			if spawn.deployment_group == "left_side_enemy":
				spawn_left = spawn
			elif spawn.deployment_group == "right_side_enemy":
				spawn_right = spawn

#func start_wave(wave_index):
#	var formation_id = waves[wave_index]
#	var args = {
#		"formation": formation_list[formation_id],
#		"timer_amt": rand_range(2.5, 3.5)
#	}
#	set_spawn_points(args)
#	reset_timers()

func _process(delta):
	if GameState.main == "battle" && formation_set.size() < 1:
		check_enemies_killed()

func spawnEnemy(enemy_name, spawn_side):
	if enemy_name != null:
		var actor_path = "res://Actors/Enemy/{enemy_name}.tscn"
		var enemy = load(actor_path.format({"enemy_name": enemy_name})).instance()
		enemy.add_to_group(spawn_side)

		if spawn_side == "left_side_enemy":
			spawn_left.add_child(enemy)
		else:
			spawn_right.add_child(enemy)

func process_formation_set():
	timer.set_wait_time(0.1)
	var spawn_side_hash = {
		"left": "left_side_enemy",
		"right": "right_side_enemy"
	}
	var formation = formation_set.front()
	if "delay" in formation:
		var delay = float(formation["delay"])
		timer.set_wait_time(delay)
	if typeof(formation) == TYPE_STRING:
		for side in ["left_side_enemy", "right_side_enemy"]:
			spawnEnemy(formation, side)
		## deploy to both
	elif "enemy" in formation:
		var spawn_side = "left"
		if "spawn_side" in formation:
			spawn_side = formation["spawn_side"]
		spawnEnemy(formation["enemy"], spawn_side_hash[spawn_side])
	formation_set.pop_front()
	if formation_set.size() > 0:
		timer.start()
	else:
		timer.stop()

func start_encounter(_formation_set):
	formation_set = _formation_set
	process_formation_set()

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
	process_formation_set()
#	pass
#	var enemies = get_tree().get_nodes_in_group("enemy")
#	if enemies.size() < 1 && current_wave + 1 <= waves.size():
#		print("Staring Wave: ", current_wave + 1, "/", total_waves)
#		if current_wave == 1:
#			ActionController.display_info("Tutorial", "", null, false)
#		elif current_wave == 2:
#			var skill_docks = get_tree().get_nodes_in_group("skill_dock")
#			for dock in skill_docks:
#				dock.show()
#			var body = ""
#			body += "'Attacking' characters are not able to access "
#			body += "their skills, however "
#			body += "your support character can use any of his or her "
#			body += "skills. Swap characters in and out of support "
#			body += "to better maximize skill availability."
#			body += " (click to continue)"
#			ActionController.display_info("Tutorial", body)
#			timer.set_paused(true)
#			var game_base = get_tree().get_nodes_in_group('game_base').front()
#			yield(game_base, "left_mouse")
#			timer.set_paused(false)
#			ActionController.display_info("Tutorial", "", null, false)
#		elif current_wave == 4:
#			var body = ""
#			body += "Skills can be activated by clicking on the on-screen "
#			body += "button or by using a hotkey ('1', '2', '3' Keyboard Keys), "
#			body += "Additionally you can keep a hotkey held down and continuously "
#			body += "cast the corresponding spell."
#			body += " (click to continue)"
#			ActionController.display_info("Tutorial", body)
#			## Wait For Mouse Click
#			timer.set_paused(true)
#			var game_base = get_tree().get_nodes_in_group('game_base').front()
#			yield(game_base, "left_mouse")
#			timer.set_paused(false)
#			ActionController.display_info("Tutorial", "", null, false)
#		elif current_wave == 6:
#			ActionController.restore_char_cooldowns()
#			ActionController.restore_group_health("player_char")
#			var skill_docks = get_tree().get_nodes_in_group("skill_dock")
#			for dock in skill_docks:
#				dock.show()
#			var skip_btn = get_tree().get_nodes_in_group("skip_button").front()
#			skip_btn.hide()
#			wave_ct_label.show()
#			update_wave_label()
#			var body = ""
#			body += "Okay... Tutorial Over... "
#			body += "Let's have some fun... "
#			body += "But first I'll fully restore your characters. "
#			body += " (click to continue)"
#			ActionController.display_info("Tutorial", body)
#			## Wait For Mouse Click
#			timer.set_paused(true)
#			var game_base = get_tree().get_nodes_in_group('game_base').front()
#			yield(game_base, "left_mouse")
#			timer.set_paused(false)
#			ActionController.display_info("Tutorial", "", null, false)
#		update_wave_label()
#		start_wave(current_wave)
#		current_wave += 1
#		timer.stop()
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

func stage_item_in_view(item):
	if "stageObj" in item:
		if item.stageObj != null:
			var stageObj = item.stageObj.instance()
			item.stageInstance = stageObj
			stageObj.map_icon = item
			if item.spawn_side == "left":
				stageObj.global_position = spawn_left.global_position
			else:
				stageObj.global_position = spawn_right.global_position
			var stageChar = playerVar.get_char_in_slot(5)
			item.stageDist = stageChar.global_position.x - stageObj.global_position.x
	#		item.stageDist = stageChar.global_position.distance_to(stageObj.global_position)
			item.distDiff = (item.stageDist - item.mapDist)/item.mapDist
			ActionController.spawn_instance(stageObj, item.z_placement)
			if item.z_placement == "FG":
				stageObj.set_fg_element()

func stage_item_out_view(item):
	if "stageInstance" in item:
		if !is_instance_valid(item.stageInstance):
			item.stageInstance = null
		if item.stageInstance != null:
			item.stageInstance.queue_free()

func check_enemies_killed():
	var enemy_ct = get_tree().get_nodes_in_group("enemy")
	if enemy_ct.size() < 1:
		GameState.main_state('map')
