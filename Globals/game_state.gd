extends Node

var main = 'battle'
var sub = 'ready'
var prev = {
	"sub": null,
	"main": null
}
var transition = {
	'battle': ['ready', 'select_target', 'game over']
}
var death_ct = 0 setget set_death_ct

func set_death_ct(value):
	death_ct = value
	if death_ct >= 3:
		GameState.sub_state('game over')
		OS.alert('Game Over!')
		get_tree(). reload_current_scene()
		GameState.sub_state('ready')

func sub_state(new_state):
	if new_state == 'ready':
		Input.set_custom_mouse_cursor(null)
	if new_state == 'select_target':
		var cursor = load("res://Assets/Icons/crosshairs_cursor.png")
		Input.set_custom_mouse_cursor(cursor)
	if transition[main].has(new_state):
		prev["sub"] = sub
		sub = new_state

func last_state(state_type):
	sub = prev[state_type]
	prev[state_type] = null
