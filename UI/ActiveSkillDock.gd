extends HBoxContainer

onready var char_slot
export(bool) var is_active = false
onready var skill_buttons = get_children()
var char_status = "active"

func _ready():
	get_parent().set_dock_char()
	toggle_activate(is_active)
	
func toggle_activate(is_active):
	if char_status == "death":
		is_active = false
	if is_active == null:
		is_active = !is_active
	if !is_active:
		set_scale(Vector2(0.5,0.5))
		set_active_buttons(is_active)
	else:
		set_scale(Vector2(1,1))
		set_active_buttons(is_active)

func set_active_buttons(is_active):
	for b in skill_buttons.size():
		var button = skill_buttons[b]
		button.is_active = is_active
		if char_slot != null:
			button.skill_id = playerVar.cur_skills[char_slot][b]
		button.init_skill()
