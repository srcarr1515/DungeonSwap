extends Area2D

export (int) var slot_num
export (PackedScene) var onload_obj
var assigned_obj
export var is_clickable = false
onready var icon = $icon
var mouse_over = false
var slot_selected = false
onready var parent = get_parent()

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
				icon.modulate = Color(1.2,1.2,1.4,0.25)
				slot_selected = true
			elif controller.selected_slot == slot_num:
				controller.selected_slot = 0
				icon.modulate = Color(0,0,0,0)
				slot_selected = false
			else:
				var sounds = ['swosh-01.wav', 'swosh-07.wav']
				SFX.create(Helpers.choose(sounds), rand_range(-24.0, -18.0))
				controller.swap_slot_objects(controller.selected_slot, slot_num, assigned_obj)
				controller.selected_slot = 0
				for ch in controller.get_children():
					if ch.is_in_group("slot"):
						ch.icon.modulate = Color(0,0,0,0)
				slot_selected = false
		else:
			## Is button release
			pass


func _on_slot_mouse_entered():
#	if !slot_selected:
#		icon.modulate = Color(0,0,0,0.5)
	mouse_over = true
	parent.mouse_over_slot = self

func _on_slot_mouse_exited():
#	if !slot_selected:
#		icon.modulate = Color(0,0,0,0)
	mouse_over = false
	parent.mouse_over_slot = null
