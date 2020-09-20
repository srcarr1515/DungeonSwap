extends Control

onready var char_skill_slots = [$char_slot_1, $char_slot_2, $char_slot_3]
var dock_party_slot = {}
var commit_button = null
signal commit_skill(_button, _target)
## playerVar.cur_party ## {1: 1, 2: 0, 3: 2}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_dock_char()
	set_skill_dock_pos()
	var skill_buttons = get_tree().get_nodes_in_group("skill_button")
	for button in skill_buttons:
		button.connect("precommit_skill", self, "_on_precommit_skill")
	set_process(false)

func _on_precommit_skill(_button):
	## TODO: change cursor to denote skill targeting
	## TODO: need to control the state... can't swap while selecting target.
	commit_button = _button
	GameState.sub_state('select_target')
	commit_button = _button
	set_process(true)

func _process(delta):
	if commit_button != null:
		var is_finished = false
		if Input.is_action_pressed("left_mouse"):
			## TODO: Show clickable area slots
			var nearest_target = Helpers.pick_nearest("targetable", get_global_mouse_position())
#			nearest_target.icon.modulate = Color(0,0,0,0.5)
			## TODO: Get either target slot or target entity
			## TODO: Adjust a clickable collision box on the slots that when clicked will select a slot...
			## TODO: Prioritize direct enemy clicks, clicking around an enemy to the surroudning slot will select the slot..
			## TODO: Create feedback that helps the player understand which selection is being made.
			emit_signal("commit_skill", commit_button, nearest_target)
			is_finished = true
		elif Input.is_action_pressed("right_mouse") || Input.is_action_pressed("ui_cancel"):
			is_finished = true
		if is_finished:
			set_process(false)
			commit_button = null

func set_dock_char():
	var skill_docks = get_tree().get_nodes_in_group("skill_dock")
	var slot_controller = get_tree().get_nodes_in_group("slot_controller").front()
	var party_slots = slot_controller.cur_char_slot.keys()
	for p in party_slots.size():
		var party_slot = party_slots[p]
		var dock = skill_docks[p]
		if dock.char_slot == null:
			dock.char_slot = slot_controller.cur_char_slot[party_slot]

func set_skill_dock_pos():
	var skill_docks = get_tree().get_nodes_in_group("skill_dock")
	var slot_controller = get_tree().get_nodes_in_group("slot_controller").front()
	var party_slots = slot_controller.cur_char_slot.keys() ## {4: 1, 5: 2, 6: 3}
	
	for dock in skill_docks:
		for party_slot in party_slots:
			if dock.char_slot == slot_controller.cur_char_slot[party_slot]:
				if  party_slot == party_slots.max():
					dock.rect_global_position = char_skill_slots[2].rect_global_position
					dock.toggle_activate(false)
				elif party_slot == party_slots.min():
					dock.rect_global_position = char_skill_slots[0].rect_global_position
					dock.toggle_activate(false)
				else:
					dock.rect_global_position = char_skill_slots[1].rect_global_position	
					dock.toggle_activate(true)

func _on_slot_controller_update_char_slots():
	set_skill_dock_pos()
