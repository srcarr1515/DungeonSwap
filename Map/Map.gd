extends Node2D

onready var nav_2d = $Navigation2D
onready var character = $player_marker
onready var starting_room = $Room1

func _ready():
	character.current_room = starting_room
	character.move_to_path_rider()

#func _unhandled_input(event):
#	if not event is InputEventMouseButton:
#		return
#	if event.button_index != BUTTON_LEFT or not event.pressed:
#		return
#
#	var new_path = nav_2d.get_simple_path(character.global_position, get_global_mouse_position())
#	character.path = new_path
