extends TextureButton

var skill_id
var skill_details
var skill_charges = null setget set_skill_charges
export(float) var cooldown = 1.0
onready var clockwipe = $ClockWipe
onready var charges_ui = $Charges/TextureProgress
onready var mouse_over = $MouseOver

var precommitting = false

var key_down = false

var is_active
var is_preactivated = false
export (String) var button_key
export (PackedScene) var msg_box
onready var msg = msg_box.instance()
onready var parent = get_parent()

signal precommit_skill(_button)

func _ready():
	init_skill()
	set_process(false)

func init_skill():
	var skill_name = null
	if playerVar.skill_list.has(skill_id):
		skill_details = playerVar.skill_list[skill_id]
		skill_name = skill_details.skill_name
		cooldown = skill_details.cooldown
		if "charges" in skill_details:
			charges_ui.show()
			skill_charges = skill_details.charges
			charges_ui.max_value = skill_charges
		else:
			charges_ui.hide()
		
	$Timer.wait_time = cooldown
	if is_active:
		set_modulate(Color(1,1,1,1))
		clockwipe.set_modulate(Color(0.25,0.25,0.25,1))
	else:
		set_modulate(Color(2,1,1,0.5))
		clockwipe.set_modulate(Color(0.005,0.005,0.005,1))
	if skill_name != null:
		var icon = "res://Assets/Icons/Skills/{skill_name}.png".format({"skill_name": skill_name})
		texture_normal = load(icon)
	clockwipe.texture_progress = texture_normal

func _process(delta):
	clockwipe.value = int(($Timer.time_left / cooldown) * 100)

func start_cooldown():
	if is_active:
		disabled = true
		set_process(true)
		$Timer.start()

func _on_ActiveSkillBtn_pressed():
	precommitting = true
	activate_skill()
#	ActionController.display_info(skill_details.skill_name, skill_details.skill_name, rect_global_position)
		## TODO: change icon to indicate pre-activated

func _input(event):
	if is_active:
		if Input.is_action_just_pressed(button_key) && key_down == false:
			activate_skill()
			key_down = true
		
		if Input.is_action_just_released(button_key):
			key_down = false
	
#func _on_Button_gui_input(event):
#	print(event)
#	if event is InputEventMouseButton and event.pressed:
#		match event.button_index:
#			BUTTON_RIGHT:
#				print('test')
#				ActionController.display_info(skill_details.skill_name, skill_details.skill_name, rect_global_position)

func activate_skill():
	var is_ready = true
	if skill_charges != null:
		if skill_charges < 1:
			is_ready = false
	
	if is_active && is_ready && !disabled:
		var skill_buttons = get_tree().get_nodes_in_group("skill_button")
		for button in skill_buttons:
			button.is_preactivated = false
			## TODO: change icon to default
		is_preactivated = true
		emit_signal("precommit_skill", self)

func set_skill_charges(value):
	if skill_charges < 0:
		skill_charges = 0
		key_down = false
	if value > skill_details.charges:
		skill_charges = skill_details.charges
	skill_charges = value
	charges_ui.value = value

func reset_cooldown():
	clockwipe.value = 0
	disabled = false
	set_process(false)

func _on_Cooldown_Timer_timeout():
	reset_cooldown()

func _on_TextureRect_gui_input(ev):
	print(ev)

func _on_mouse_entered():
	mouse_over.start()

func _on_mouse_exited():
	mouse_over.stop()
	msg.hide()

func _on_MouseOver_timeout():
	if !precommitting:
		var middle_of_screen = get_viewport_rect().size / 2
		msg.global_position = rect_global_position
		msg.global_position.y += 12
		if rect_global_position.x > middle_of_screen.x + 40:
			msg.global_position.x -= 64
		elif rect_global_position.x < middle_of_screen.x - 40:
			msg.global_position.x += 64
		var ui = get_tree().get_nodes_in_group("UI").front()
		ui.add_child(msg)
		msg.set_scale(Vector2(0.4,0.4))
		msg.header.text = skill_details["label"]
		msg.body.text = skill_details["description"]
		msg.show()
