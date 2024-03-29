extends Node2D

onready var character = $player_marker
onready var starting_room = $Room2
onready var camera = $Camera2D
onready var camera_target = $player_marker
var camera_speed = 0.2
signal camera_move_completed

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

## I think I will be going for true random encounters.
#	var enemy_formation = load("res://Data/enemy_formation.gd").new()
#	for room in [$Room1, $Room2, $Room3, $Room4, $Room5]:
#		for n in range(3):
#			var formation_set = int(rand_range(0,enemy_formation.list.size() - 1))
#			print("formation_set: ", formation_set, "Room: ", room.name)
#			var unit_offset = [0.0, 1.0]
#			if room == $Room2:
#				unit_offset = [0.0, 0.4]
#			place_map_icon(room, "EnemyIcon", enemy_formation.list[formation_set], {"unit_offset_range":unit_offset})
#	place_map_icon($Room2, "EnemyIcon", enemy_formation.list[0], {"unit_offset_range":[0.0, 1.0]})
	
	## Levers and Gates
	var gate = place_map_icon($Room4, "GateIcon", null, {"unit_offset_range":[0.7, 0.79]})
	place_map_icon($Room3, "LeverIcon", null, {"unit_offset_range":[0, 0.3], "act_trigger_target": gate})
	gate = place_map_icon($Room2, "GateIcon", null, {"unit_offset_range":[0.8, 0.89]})
	place_map_icon($Room4, "LeverIcon", null, {"unit_offset_range":[0.9, 0.99], "act_trigger_target": gate})
	var map_nodes = get_children()
	for node in map_nodes:
		if node.is_in_group("room"):
			node.init()


## I'm redesigning the demo quest... No need for this yet.
#	place_map_icon($Room4, "StatueIcon", null, {"unit_offset_range":[0.0, 0.1]})
	place_map_icon(Helpers.choose([$Room1]), "FountainIcon", null, {"unit_offset_range":[0.0, 1.0]})
	place_map_icon($Room5, "FountainIcon", null, {"unit_offset_range":[0.1, 0.4]})
	place_map_icon($Room3, "FountainIcon", null, {"unit_offset_range":[0.1, 0.4]})
	
	starting_room.path_rider.offset = starting_room.get_node("Path2D").curve.get_closest_offset(Vector2(276,240))
	character.current_room = starting_room
	character.move_to_path_rider()

func _process(delta):
	var cam_dist = camera.global_position.distance_to(camera_target.global_position)
	if cam_dist > 2:
		camera.global_position = lerp(camera.global_position, camera_target.global_position, camera_speed)
	elif cam_dist <= 2 && camera.global_position != camera_target.global_position:
		camera.global_position = camera_target.global_position
		emit_signal("camera_move_completed")


func place_map_icon(_room, _icon, _icon_value=null, _args={}):
	var icon_scene = load("res://Map/{icon}.tscn".format({"icon": _icon}))
	var icon = icon_scene.instance()
	icon.in_room = _room.name
	## All Icons will definitely have 'icon_value' available, but may not utilize it.
	if _icon_value != null:
		icon.icon_value = _icon_value
	var icons_node = _room.get_node("Icons")
	## Icons are placed differently based on what kind of icon they are.
	var dest_node
	if icon.icon_type == icon.icon.DOOR:
		dest_node = _room.get_node("Icons/Doors")
	elif icon.icon_type == icon.icon.ENEMY:
		dest_node = _room.get_node("Icons/Enemies")
	else:
		dest_node = icons_node
	## set the offset (between 0.0 and 1.0) this determines where on the Path2D you spawn.
	var unit_offset
	## we also should allow for passing the offset values in:
	if "unit_offset" in _args:
		unit_offset = _args["unit_offset"]
	elif "unit_offset_range" in _args:
		## the range must be an array and the value must be between 0.0 and 1.0...
		## think of it as a percentage, like 0.1 represents 10% the way down the Path2D.
		var unit_offset_range = _args["unit_offset_range"]
		unit_offset = rand_range(unit_offset_range[0], unit_offset_range[1])
	else:
		unit_offset = rand_range(0, 1)
	var already_exists = true
	var tries = 0
	var assigned_unit_offset = icons_node.assigned_unit_offset
	
	## we do not want to create icons on top of other icons, so keep track...
	while already_exists:
		tries += 1
		if assigned_unit_offset.size() < 1:
			already_exists = false
		for _unit_offset in assigned_unit_offset:
			## we dont want icons to be too close so we only care about the tens point
			## So, .1, .2, .3, etc instead of .141 or .37
			## This means we can have 10 icons on a line...
			## TODO: We will need to dynamically shift how many icons based on the length of line.
			if "%0.1f" % _unit_offset == "%0.1f" % unit_offset:
				pass
			else:
				already_exists = false
		if tries > 3:
			already_exists = null
	## If we find that it doesn't already exist at that offset, we can spawn it.
	if !already_exists:
		icons_node.assigned_unit_offset.push_front(unit_offset)
		_room.path_rider.unit_offset = unit_offset
		dest_node.add_child(icon)
		icon.position = dest_node.to_local(_room.path_rider.global_position)
	
	## Not all icons are the same, _args  will allow us to pass in params as needed.
	## Also we will apply this last so it can overwrite everything else.
	if _args != null:
		## _args must always be formatted as a dictionary object!
		for arg_key in _args.keys():
			## this will loop through all arg keys and apply them to the value to the icon
			if arg_key in icon:
				var arg_value = _args[arg_key]
				icon.set(arg_key, arg_value)
	
	## We may want to share this icon or its data with other systems or icons.
	return icon

func reveal_enemy_icons():
	var enemy_icons = get_tree().get_nodes_in_group("enemy_icon")
	for icon in enemy_icons:
		icon.show()
