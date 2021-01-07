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

enum trigger {
	NONE,
	DESTROY
}
export (trigger) var touch_trigger = trigger.NONE
var touch_trigger_target
export (String) var touch_trigger_anim

onready var touch_shape = $TouchShape


## may not be needed any longer (but does provide super accurate results)
var mapDist
var distDiff

func _ready():
	if icon_type != icon.DOOR:
		pass
#		var room = get_parent().room
#		var icons_node = room.icons
#		var unit_offset = room.path_rider.unit_offset_from_position(global_position) ## where on Path2D (between 0 and 1)
#		icons_node.assigned_unit_offset.push_front(unit_offset)
#		icons_node.icon_in_unit_offset.push_front(self)

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
