extends Position2D

export(PackedScene) var Action
onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func SpawnAction(args):
	if args != null:
		if !"atk_power" in args.keys():
			if parent.atk_power != null:
				args["atk_power"] = parent.atk_power
	var action = Action.instance()
	if parent.is_flipped:
		args["target"].x = abs(args["target"].x) * -1
	else:
		args["target"].x = abs(args["target"].x)
	args.start_position = global_position
	var new_args = [args]
	action.start_pos = position
	action.atk_power = args['atk_power']
	action.target = args['target']
	add_child(action)
#	ActionController.perform_action('bullet', null)
