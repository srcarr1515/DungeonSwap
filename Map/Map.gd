extends Node2D

onready var character = $player_marker
onready var starting_room = $Room1

func _ready():
	character.current_room = starting_room
	character.move_to_path_rider()
