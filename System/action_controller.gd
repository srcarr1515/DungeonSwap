extends Node2D

func _on_UI_commit_skill(_button, _target):
	var char_slot = _button.parent.char_slot
	var parent = playerVar.party_chars[char_slot]
	var skill_details = playerVar.skill_list[_button.skill_id]
	var slot = Helpers.pick_nearest("slot", get_global_mouse_position())
	var args = {"start_pos":parent.global_position, "slot_pos": slot.global_position}
	if get_global_mouse_position().x < parent.position.x:
		args["is_flipped"] = true
	if "atk_power" in skill_details.keys():
		args["atk_power"] = skill_details["atk_power"]
	spawn_action(skill_details["skill_name"], args)
	_button.start_cooldown()
	GameState.sub_state('ready')

func execute_action(skill_id, args):
	pass

func spawn_instance(instance):
	var level = get_tree().get_nodes_in_group("foreground").front()
	level.add_child(instance)

func spawn_action(action_name, args=null):
	var directory = Directory.new()
	var file_path = "res://Actions/{action_obj}.tscn".format({"action_obj": action_name})
	if directory.file_exists(file_path):
		var action_instance = load(file_path).instance()
		pass
		for arg_key in args.keys():
			action_instance.set(arg_key, args[arg_key])
		var slot_controller = get_tree().get_nodes_in_group("slot_controller").front()
		var in_support_slot = slot_controller.assigned_char_slot[5]
		yield(get_tree().create_timer(action_instance.delay), "timeout")
		if slot_controller.assigned_char_slot[5] == in_support_slot:
			action_instance.spawn()
	else:
		print("Action doesnt exist!")

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
	obj.queue_free()

func collide(source_obj, collide_obj):
	pass
#	cue_transition("on_collision", source_obj.action_id)



