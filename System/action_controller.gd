extends Node2D

func _on_UI_commit_skill(_button, _target):
	var char_slot = _button.parent.char_slot
	var parent = playerVar.party_chars[char_slot]
	var args = {"start_pos":parent.global_position}
	if get_global_mouse_position().x < parent.position.x:
		args["is_flipped"] = true
	spawn_action(playerVar.skill_list[_button.skill_id]["skill_name"], args)
	_button.start_cooldown()
	GameState.sub_state('ready')

func execute_action(skill_id, args):
	print(playerVar.skill_list[skill_id])

func spawn_instance(instance):
	get_tree().get_root().add_child(instance)

func spawn_action(action_name, args=null):
	var action_instance = load("res://Actions/{action_obj}.tscn".format({"action_obj": action_name})).instance()
	for arg_key in args.keys():
		action_instance.set(arg_key, args[arg_key])
	action_instance.spawn()

func old_spawn_action(action_id, args=null):
	var action_object = args.action_object
	## Create an object
	var action_instance = load("res://Actions/{action_obj}.tscn".format({"action_obj": action_object})).instance()
	action_instance.action_id = action_id
	action_instance.action_args = args
	get_tree().get_root().add_child(action_instance)
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



