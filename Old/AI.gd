extends Node2D

var states = []
var active_state = "" setget set_state
var state_info = {}
onready var actor
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	var state_nodes = get_children()
	actor = get_parent()
	for node in state_nodes:
		if "state_name" in node:
			## Collect all possible states from children state nodes.
			states.push_front(node.state_name)
			state_info[node.state_name] = {"node": node}
			state_info[node.state_name]["index"] = state_info.keys().size() - 1
			if actor != null:
				node.initialize(actor)
	states = state_info.keys()
	if states.size() > 0:
		active_state = states[0]
	print(active_state)

func set_state(state_name):
	if state_name in states:
		active_state = state_name
	else:
		print("State: '%s' doesn't exist." % [state_name])

func next_state():
	if states.size() == 1:
		print("Only one available state.")
		return false
	var next_index = state_info[active_state].index + 1
	if next_index > states.size() - 1:
		next_index = 0
	active_state = states[next_index]

func prev_state():
	if states.size() == 1:
		print("Only one available state.")
		return false
	var prev_index = state_info[active_state].index - 1
	if prev_index < 0:
		prev_index = states.size() - 1
	active_state = states[prev_index]

func _physics_process(delta):
	if active_state in states:
		state_info[active_state].node.state_act(actor, delta)
