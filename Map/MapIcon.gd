extends StaticBody2D

enum icon {
	DOOR, BOX, ITEM, ENEMY
}
export (icon) var icon_type
export (PackedScene) var stageObj
var spawn_side = "right"
var stageInstance
export var z_placement = "BG" ## BG/FG
var stageDist
export (String) var in_room ## ONLY THE NAME OF THE ROOM!

export (Array) var icon_value = []
export var is_solid = false
var map
var player_marker

enum trigger {
	NONE,
	DESTROY,
	DOOR
}
export (trigger) var touch_trigger = trigger.NONE
var touch_trigger_target
export (String) var touch_trigger_anim

export (trigger) var act_trigger = trigger.NONE
var act_trigger_target
export (String) var act_trigger_anim
export (bool) var persist_act_trigger

onready var touch_shape = $TouchShape


## may not be needed any longer (but does provide super accurate results)
var mapDist
var distDiff

func _ready():
	map = get_tree().get_nodes_in_group("map").front()
	player_marker = get_tree().get_nodes_in_group("player_marker").front()
	if icon_type != icon.DOOR:
		pass
	if act_trigger != trigger.NONE:
		add_to_group("selectable_obj")
#		var room = get_parent().room
#		var icons_node = room.icons
#		var unit_offset = room.path_rider.unit_offset_from_position(global_position) ## where on Path2D (between 0 and 1)
#		icons_node.assigned_unit_offset.push_front(unit_offset)
#		icons_node.icon_in_unit_offset.push_front(self)

func dist_to_player():
	return global_position.distance_to(player_marker.global_position)

func trigger(_trigger, trigger_target):
	if _trigger == trigger.DESTROY:
		if trigger_target != null:
			## Monkey Patch Until We Make Event System:
			GameState.main = "event"
			map.camera_speed = 0.02
			map.camera_target = trigger_target
			yield(map, "camera_move_completed")
			###
			trigger_target.queue_free()
#			trigger_target = null
#			_trigger = trigger.NONE
			map.camera_speed = 0.0
			map.camera_target = player_marker
			yield(get_tree().create_timer(1), "timeout")
			map.camera_speed = 0.2
			GameState.main = "map"
	if _trigger == trigger.DOOR && icon_type == icon.DOOR:
		use_door()

func use_door():
	var door = self
	var room = map.get_node(door.icon_value.front().room)
	var exit_door = room.get_node("Icons/Doors/{door}".format({"door": door.icon_value.front().door}))
	var room_path = room.get_node("Path2D")
	## set position of path_rider in new room (to be lined up with you & door)
	room.path_rider.offset = room_path.curve.get_closest_offset(room.to_local(exit_door.global_position))
	## set new room (as current room)
	player_marker.new_room(room)

func set_stage_obj_x(input_vector):
	if !is_instance_valid(stageInstance):
		stageInstance = null
	if stageInstance != null:
			stageInstance.global_position.x -= input_vector

func set_stage_obj_pos(dist):
	var new_dist = dist * distDiff
	var stageChar = playerVar.get_char_in_slot(5)
	var new_pos = Vector2(stageChar.global_position.x - int(round(new_dist)), stageInstance.global_position.y)
	stageInstance.global_position = new_pos
