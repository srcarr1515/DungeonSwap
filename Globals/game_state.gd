extends Node

var main = 'battle'
var sub = 'ready'
var parent
var prev = {
	"sub": null,
	"main": null
}
var transition = {
	'battle': ['ready', 'select_target', 'game over'],
	'event': ['ready'],
	'map': ['battle', 'event', 'select_target']
}
var death_ct = 0 setget set_death_ct
var game_speed = 0.5

func init_parent(_parent):
	parent = _parent ## <<-- parent is the core game!

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

func main_state(new_state):
	prev["main"] = main
	main = new_state
	var tween = Tween.new()
	var battle_ui_nodes = get_tree().get_nodes_in_group("battle_ui")
	var fg = get_tree().get_nodes_in_group("FG").front()
	if new_state == "battle":
		parent.change_song('Sicambre-loop.ogg')
		fg.hide()
		var playerChars = get_tree().get_nodes_in_group("player_char")
		for pc in playerChars:
			pc.state.state_event({"event": "idle"})
			if pc.slot_assign == 4:
				pc.toggle_flip(true)
			elif pc.slot_assign == 6:
				pc.toggle_flip(false)

		tween.interpolate_property(parent.map, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.50, Tween.TRANS_LINEAR, Tween.EASE_IN)
		add_child(tween)
		tween.start()
		parent.set_game_camera()
		for node in battle_ui_nodes:
			node.show()
	elif new_state == "map":
		var slots = get_tree().get_nodes_in_group("slot")
		for slot in slots:
			slot.reset_slot()
		
		var summons = get_tree().get_nodes_in_group("player_summon")
		for summon in summons:
			summon.queue_free()
		parent.change_song('Dr-Nomura-Loop.ogg')
		fg.show()
		tween.interpolate_property(parent.map, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.50, Tween.TRANS_LINEAR, Tween.EASE_IN)
		add_child(tween)
		tween.start()
		parent.set_game_camera()
		for node in battle_ui_nodes:
			node.hide()


func last_state(state_type):
	sub = prev[state_type]
	prev[state_type] = null
