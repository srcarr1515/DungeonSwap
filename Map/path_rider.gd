extends PathFollow2D

onready var room_path = get_parent()
onready var room = room_path.get_parent()

func offset_from_position(_global_position):
	var _offset = room_path.curve.get_closest_offset(room.to_local(_global_position))
	offset = _offset 
	return _offset

func unit_offset_from_position(_global_position):
	var _offset = offset_from_position(_global_position)
	return get_unit_offset()
