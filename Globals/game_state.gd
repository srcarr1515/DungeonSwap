extends Node

var main = 'battle'
var sub = 'ready'
var prev = {
	"sub": null,
	"main": null
}
var transition = {
	'battle': ['ready', 'select_target']
}

func sub_state(new_state):
	if transition[main].has(new_state):
		prev["sub"] = sub
		sub = new_state

func last_state(state_type):
	sub = prev[state_type]
	prev[state_type] = null
