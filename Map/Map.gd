extends Node2D

onready var character = $player_marker
onready var starting_room = $Room2

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
	
	place_map_enemy($Room1)
	place_map_enemy($Room1)
	place_map_enemy($Room2)
	place_map_enemy($Room2)
	place_map_enemy($Room3)
	place_map_enemy($Room3)
	place_map_enemy($Room4)
	place_map_enemy($Room4)
	place_map_enemy($Room4)
	place_map_enemy($Room5)
	place_map_enemy($Room5)
	place_map_enemy($Room5)

	starting_room.path_rider.offset = starting_room.get_node("Path2D").curve.get_closest_offset(Vector2(276,240))
	character.current_room = starting_room
	character.move_to_path_rider()

func place_map_enemy(room):
	var enemy_icon_scene = load("res://Map/EnemyIcon.tscn")
	var enemy_icon = enemy_icon_scene.instance()
	enemy_icon.in_room = room.name
	enemy_icon.icon_value = ["Wolf"]
	var enemies_node = room.get_node("Icons/Enemies")
#	var room_path = room.get_node("Path2D")
	var random_offset = rand_range(0, 1)
	var already_exists = true
	var tries = 0
	while already_exists:
		if enemies_node.enemy_unit_offsets.size() < 1:
			already_exists = false
		for unit_offset in enemies_node.enemy_unit_offsets:
			tries += 1
			if "%0.1f" % unit_offset == "%0.1f" % random_offset:
				pass
			elif tries > 3:
				already_exists = null
			else:
				already_exists = false
		if already_exists:
			random_offset = rand_range(0, 1)
	if !already_exists:
		enemies_node.enemy_unit_offsets.push_front(random_offset)
	room.path_rider.unit_offset = random_offset
	enemies_node.add_child(enemy_icon)
	enemy_icon.position = enemies_node.to_local(room.path_rider.global_position)
