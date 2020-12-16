extends Node

func _on_UI_commit_skill(_button, _target):
	var char_slot = _button.parent.char_slot
	var parent = playerVar.party_chars[char_slot]
	var args = {}
#	if !"atk_power" in args.keys():
#		if parent.atk_power != null:
#			args["atk_power"] = parent.atk_power
#	args.target.x = _target.global_position.x
#	if parent.is_flipped:
#		args["target"].x = abs(args["target"].x) * -1
#	else:
#		args["target"].x = abs(args["target"].x)
#	args.start_position = parent.global_position
	execute_action(_button.skill_id, args)
	_button.start_cooldown()

func execute_action(skill_id, args):
	pass
#	GameState.sub_state('ready')
#	perform_action('holy_bolt', [args])
	
#
#	var ability = playerVar.skill_list[skill_id]
#	perform_action(ability.skill_name)

#func perform_action(action_blueprint_name, args=null):
#	var bp_script = load("res://Actions/Blueprints/{action}.gd".format({"action": action_blueprint_name})).new()
#	add_action_blueprint(bp_script.blueprint, action_blueprint_name, args)

#func add_action_blueprint(blueprint, blueprint_name, args=null):
#	var action_id = Helpers.random()
#	if action_id in action_blueprints: ## if this Id exists, do it again! (must be unique)
#		add_action_blueprint(blueprint, blueprint_name) 
#	else:		
#		for step in range(0, blueprint.size() - 1): ## Give each step in the blue print the action id!
#			var action = blueprint[step]
#			action["id"] = action_id
#			action["blueprint_name"] = blueprint_name
#			if args != null && step <= args.size() - 1:
#				for a in args[step].keys():
#					action.args[a] = args[step][a]
#		action_blueprints[action_id] = blueprint
#		action_step[action_id] = 0
#		var start_args = null
#		if 'args' in blueprint[action_step[action_id]]:
#			start_args = blueprint[action_step[action_id]].args
#		cue_transition(true, action_id, start_args)


## Actions
#func move_action(action_id, args=null):
#	emit_signal("action_complete", args.action)

func spawn_instance(instance):
	get_tree().get_root().add_child(instance)

func spawn_action(action_id, args=null):
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



