extends Node

## action_blueprint logic
var action_blueprint = []
var action_blueprints = {}
var action_step = {} ## each index of action blueprint is a step (action_step - 1 == action_blueprint.index)
signal action_complete(action)

func next_step(action_id, args):
	if args != null && "action" in args: ## If we specify an action in arguments
#		if typeof(args.action) == 19:
		call(args.action, action_id, args) ## call that action and pass in the args
		#	print('------')
		#	print(yield(self, "action_complete"))
		#	print('------')
		#	while yield(self, "action_complete") != args.id: pass ## wait for action to complete
		cue_transition(true, action_id, args) ## attempt to cue up next action (assuming it has no transition cues)
#		else:
#			print("Action in step {step} of {blueprint} is not an Array.".format({'step': action_step, 'blueprint': args.blueprint_name}))

func cue_transition(transition_cue, action_id, args=null):
	if action_id in action_blueprints:
		var action_blueprint = action_blueprints[action_id]
		var next_action = null
		if action_step[action_id] + 1 <= action_blueprint.size():
			var step_index = action_step[action_id]
			next_action = action_blueprint[step_index] ## because the index is 1 less than the current action step
			if transition_cue in next_action.transition_cue:
				action_step[action_id] += 1
				next_step(action_id, action_blueprint[step_index].args)
		else:
			## action is done, remove it from the blueprints hash
			action_blueprints.erase(action_id)

func _on_UI_commit_skill(_button, _target):
	execute_action(_button.skill_id, _target)	

func perform_action(action_blueprint_name, args=null):
	var bp_script = load("res://Actions/Blueprints/{action}.gd".format({"action": action_blueprint_name})).new()
	add_action_blueprint(bp_script.blueprint, action_blueprint_name, args)

func add_action_blueprint(blueprint, blueprint_name, args=null):
	var action_id = Helpers.random()
	if action_id in action_blueprints: ## if this Id exists, do it again! (must be unique)
		add_action_blueprint(blueprint, blueprint_name) 
	else:
		for step in range(0, blueprint.size() - 1): ## Give each step in the blue print the action id!
			var action = blueprint[step]
			action["id"] = action_id
			action["blueprint_name"] = blueprint_name
			print(step)
			if step <= args.size() - 1:
				print(args[step].keys())
				for a in args[step].keys():
					action.args[a] = args[step][a]
					print(action)
		action_blueprints[action_id] = blueprint
		action_step[action_id] = 0
		var start_args = null
		if 'args' in blueprint[action_step[action_id]]:
			start_args = blueprint[action_step[action_id]].args
		cue_transition(true, action_id, start_args)


## Actions
func move_action(action_id, args=null):
	emit_signal("action_complete", args.action)

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
	emit_signal("action_complete", args.action)

func destroy_action(action_id, args=null):
	emit_signal("action_complete", args.action)

func execute_action(skill_id, target):
	GameState.sub_state('ready')

## Events
func destroy(obj):
	if "action_id" in obj && obj.action_id != null && action_blueprints.has(obj.action_id):
		var next_action = action_blueprints[obj.action_id][action_step[obj.action_id]]
		if typeof(next_action.args.start_position) != 5:
			if next_action.args.start_position == "event_location":
				next_action.args.start_position = obj.global_position
		cue_transition("on_destroyed", obj.action_id)
	obj.queue_free()

func collide(source_obj, collide_obj):
	cue_transition("on_collision", source_obj.action_id)



