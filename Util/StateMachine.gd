extends Node
class_name  StateMachine

var current
var previous
onready var parent = get_parent()
var props = {}
var active = true

## Emitted state event signal, pass the state event into the transitions hash:
### transitions[current][state_event] = "next state"
var transitions = {}
var all = []

## Don't know if we need to use a signal! ###
## Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	EventController.connect("char_state_event", self, "_on_State_event")


#func _on_State_event(target, props):
#	if target == parent:
#		state_event(props)

func state_event(_props):
	if _props["event"] in transitions[current] || _props["event"] in all:
		props = _props
		active = true
		current = _props.event
	else:
		pass

## Define all states as methods to be called, passing the props in.

func every_tick(delta):
	pass

## Call the state func!
func _physics_process(delta):
	every_tick(delta)
	if current != null && active:
		call(current, delta)


