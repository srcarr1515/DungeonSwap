extends Area2D

export (int) var slot_num
export (PackedScene) var onload_obj
var assigned_obj
export var is_clickable = false
onready var icon = $icon

# Called when the node enters the scene tree for the first time.
func _ready():
	icon.modulate = Color(0,0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_slot_input_event(viewport, event, shape_idx):
	var controller = get_parent()
	if event is InputEventMouseButton && !controller.swap_in_progress && is_clickable && GameState.sub == 'ready':
		if event.is_pressed():
			if controller.selected_slot == 0:
				controller.selected_slot = slot_num
				icon.modulate = Color(0,0,0,0.5)
			elif controller.selected_slot == slot_num:
				controller.selected_slot = 0
				icon.modulate = Color(0,0,0,0)
			else:
				controller.swap_slot_objects(controller.selected_slot, slot_num, assigned_obj)
				controller.selected_slot = 0
				for ch in controller.get_children():
					if ch.is_in_group("slot"):
						ch.icon.modulate = Color(0,0,0,0)
		else:
			## Is button release
			pass
