extends Node2D

var assigned_unit_offset = []
var icon_in_unit_offset = [] ## matching index of assigned_unit_offset
var room
onready var door_icons = $Doors

func _ready():
	pass

func assign_existing_icon_unit_offset(icon):
	var unit_offset = room.path_rider.unit_offset_from_position(icon.global_position)
	assigned_unit_offset.push_front(unit_offset)
