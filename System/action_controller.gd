extends Node2D

signal on_enemy_death

func _on_UI_commit_skill(_button, _target):
	if GameState.main == "battle":
		var skill_details = playerVar.skill_list[_button.skill_id]
		var is_occupied = false
		if is_occupied:
			pass
	#		print('occupied!')
	#		GameState.sub_state('ready')
		else:
			var char_slot = _button.parent.char_slot
			var parent = playerVar.party_chars[char_slot]
			var target_pos = Vector2.ZERO
			target_pos.x = get_global_mouse_position().x
			target_pos.y = parent.global_position.y
			if _button.skill_details["target_type"] == "tile":
				var slot = Helpers.pick_nearest("slot", get_global_mouse_position())
				target_pos = slot.global_position
	
			var args = {
				"start_pos":parent.global_position, 
				"slot_pos": target_pos,
				"action_owner": parent
				}
			if get_global_mouse_position().x < parent.position.x:
				parent.toggle_flip(true)
				args["is_flipped"] = true
			else:
				parent.toggle_flip(false)
			if "atk_power" in skill_details.keys():
				args["atk_power"] = skill_details["atk_power"]
			
			
			if _button.skill_charges == null || _button.skill_charges < 2:
				_button.start_cooldown()
				if _button.skill_charges != null:
					_button.skill_charges = skill_details.charges ## It will default to the max
			elif _button.skill_charges > 1:
				_button.skill_charges -= 1
			GameState.sub_state('ready')
			if _button.key_down:
				yield(get_tree().create_timer(0.25), "timeout")
				_button.activate_skill()
			
			spawn_action(skill_details["skill_name"], args, _button)
	else:
		GameState.sub_state('ready')

func execute_action(skill_id, args):
	pass

func restore_group_health(group_name):
	var chars = get_tree().get_nodes_in_group(group_name)
	for ch in chars:
		if "state" in ch:
			ch.state.state_event({"event": "revive"})
		if "stats" in ch:
			ch.stats.health = ch.stats.max_health

func restore_char_cooldowns():
	var buttons = get_tree().get_nodes_in_group("skill_button")
	for button in buttons:
		button.reset_cooldown()

func display_info(header, body, _position=null, show=true):
	var info_box = get_tree().get_nodes_in_group("info_box").front()
	if _position == null:
		_position = info_box.start_position
	info_box.header.text = header
	info_box.body.text = body
	info_box.global_position = _position
	if show:
		info_box.show()
	else:
		info_box.hide()

### Monkey Patch
var checkpoint_data = {
	"enemy_icon": [],
	"checkpoint_location": {"_position": Vector2.ZERO, "in_room": null}
}
func save_checkpoint():
	var map = get_tree().get_nodes_in_group("map").front()
	checkpoint_data["checkpoint_location"]["_position"] = map.character.global_position
	checkpoint_data["checkpoint_location"]["in_room"] = map.character.current_room
	var enemies = get_tree().get_nodes_in_group("enemy_icon")
	for enemy in enemies:
		checkpoint_data["enemy_icon"].push_front({"_position": enemy.global_position, "in_room": enemy.in_room})

func load_checkpoint():
	var formation_controller = get_tree().get_nodes_in_group("formation_controller").front()
	formation_controller.stop_encounter()
	var map = get_tree().get_nodes_in_group("map").front()
	var enemy_icon = load("res://Map/EnemyIcon.tscn")
	var enemy_ct = get_tree().get_nodes_in_group("enemy_icon")
	print(enemy_ct.size() < 1, " ", checkpoint_data["enemy_icon"])
	if enemy_ct.size() < 1:
		for enemy in checkpoint_data["enemy_icon"]:
			var icon_instance = enemy_icon.instance()
			var room = map.get_node(enemy.in_room)
			icon_instance.in_room = enemy.in_room
			room.get_node("Icons/Enemies").add_child(icon_instance)
			icon_instance.global_position = enemy._position
	map.character.current_room = checkpoint_data["checkpoint_location"]["in_room"]
	map.character.global_position = checkpoint_data["checkpoint_location"]["_position"]
	var path_rider = map.get_node(map.character.current_room.name).path_rider
	var offset = path_rider.offset_from_position(checkpoint_data["checkpoint_location"]["_position"])
	
	var camera = get_tree().get_nodes_in_group("main_camera").front()
	var fader = camera.get_node("ScreenFade")
	fader.fade_type = fader.fade.IN
	fader.duration = 0.5
	fader.start_fade()
	yield(fader.tween, "tween_completed")
	
	path_rider.offset = offset
	yield(get_tree().create_timer(0.1), "timeout")
	
	var stage_obj = get_tree().get_nodes_in_group("stage_object")
	for entity in stage_obj:
		entity.queue_free()
	restore_group_health("player_char")
	restore_char_cooldowns()
	map.character.build_in_view()
	
	fader.fade_type = fader.fade.OUT
	fader.duration = 0.4
	fader.start_fade()


func player_char_buff():
	var chars = get_tree().get_nodes_in_group("player_char")
	for ch in chars:
		ch.atk_power += 2

## END MONKEY PATCH


func spawn_instance(instance, node_group="action_zone"):
	var level = get_tree().get_nodes_in_group(node_group).front()
	level.add_child(instance)

func spawn_action(action_name, args=null, button=null):
	var directory = Directory.new()
	var file_path = "res://Actions/{action_obj}.tscn".format({"action_obj": action_name})
	if directory.file_exists(file_path):
		var action_instance = load(file_path).instance()
		for arg_key in args.keys():
			action_instance.set(arg_key, args[arg_key])
		var slot_controller = get_tree().get_nodes_in_group("slot_controller").front()
		var in_support_slot = slot_controller.assigned_char_slot[5]
		
		## If action has a delay timer!
		if action_instance.delay > 0:
			args.action_owner.delay_timer.start_timer(action_instance.delay)
			if button != null:
				button.player_delayed = true
			yield(args.action_owner.delay_timer.timer, "timeout")
			if button != null:
				button.player_delayed = false
		if slot_controller.assigned_char_slot[5] == in_support_slot:
			action_instance.spawn()
	else:
		print("Action doesnt exist!")

func create_msg(body, header=""):
	var msg = load("res://UI/InfoBox.tscn").instance()
	var game = GameState.parent ## << Is the Core Game Node
	game.add_child(msg)
	msg.global_position = get_viewport_rect().size / 2
	msg.set_scale(Vector2(0.75,0.75))
	msg.global_position.y -= 12
	msg.header.text = header
	msg.body.text = body
	msg.show()
	yield(game, "left_mouse")
	msg.queue_free()

func old_spawn_action(action_id, args=null):
	var action_object = args.action_object
	## Create an object
	var action_instance = load("res://Actions/{action_obj}.tscn".format({"action_obj": action_object})).instance()
	action_instance.action_id = action_id
	action_instance.action_args = args
	get_tree().get_node("Level").add_child(action_instance)
	action_instance.init_act(args)
	## Assign an action_id to it
	## Set it's position
#	set_event_location(action_instance.action_id, action_instance.global_position, "on_spawn_action")
#	cue_transition("on_spawn_action", action_instance.action_id)
	emit_signal("action_complete", args.action)

#func destroy_action(action_id, args=null):
#	emit_signal("action_complete", args.action)
	

#func set_event_location(action_id, target_pos, transition_cue):
#	if action_step[action_id] + 1 <= action_blueprints[action_id].size():
#		var next_action = action_blueprints[action_id][action_step[action_id]]
#		if transition_cue in next_action.transition_cue:
#			if typeof(next_action.args.start_position) != 5:
#				if next_action.args.start_position == "event_location":
#					next_action.args.start_position = target_pos

## Events
func destroy(obj):	
#	if "action_id" in obj && obj.action_id != null && action_blueprints.has(obj.action_id):
##		var next_action = action_blueprints[obj.action_id][action_step[obj.action_id]]
##		if typeof(next_action.args.start_position) != 5:
##			if next_action.args.start_position == "event_location":
##				next_action.args.start_position = obj.global_position
#		set_event_location(obj.action_id, obj.global_position, "on_destroyed")
#		cue_transition("on_destroyed", obj.action_id)
	var emit_enemy_signal = false
	if obj.is_in_group("enemy"):
		emit_enemy_signal = true
	obj.queue_free()
	if emit_enemy_signal:
		emit_signal("on_enemy_death")

func collide(source_obj, collide_obj):
	pass
#	cue_transition("on_collision", source_obj.action_id)

func _on_Game_left_mouse():
	pass # Replace with function body.
