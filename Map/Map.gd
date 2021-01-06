extends Node2D

onready var character = $player_marker
onready var starting_room = $Room1

func _ready():
	get_node("Room2/Icons/Doors/Door2").icon_value = [{"door": "Door3", "room": "Room1"}]
	get_node("Room3/Icons/Doors/Door").icon_value = [{"door": "Door2", "room": "Room1"}]
	get_node("Room1/Icons/Doors/Door2").icon_value = [{"door": "Door", "room": "Room3"}]
	get_node("Room1/Icons/Doors/Door").icon_value = [{"door": "Door2", "room": "Room4"}]
	get_node("Room4/Icons/Doors/Door2").icon_value = [{"door": "Door", "room": "Room1"}]
	get_node("Room2/Icons/Doors/Door").icon_value = [{"door": "Door", "room": "Room4"}]
	get_node("Room4/Icons/Doors/Door").icon_value = [{"door": "Door", "room": "Room2"}]
	get_node("Room5/Icons/Doors/Door").icon_value = [{"door": "Door3", "room": "Room2"}]
	get_node("Room2/Icons/Doors/Door3").icon_value = [{"door": "Door", "room": "Room5"}]
	starting_room.path_rider.offset = starting_room.get_node("Path2D").curve.get_closest_offset(Vector2(276,240))
	character.current_room = starting_room
	character.move_to_path_rider()
