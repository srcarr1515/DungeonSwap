extends Node2D

onready var path_rider = $Path2D/path_rider
onready var icons = $Icons

func _ready():
	pass

func init():
	icons.room = self
	for door in icons.get_node("Doors").get_children():
		icons.assign_existing_icon_unit_offset(door)
