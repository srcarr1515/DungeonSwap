extends TextureButton

var skill_id
var skill_details
export(float) var cooldown = 1.0
onready var clockwipe = $ClockWipe
var is_active
var is_preactivated = false
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
	if is_active:
		var skill_buttons = get_tree().get_nodes_in_group("skill_button")
		for button in skill_buttons:
			button.is_preactivated = false
			## TODO: change icon to default
		is_preactivated = true
		emit_signal("precommit_skill", self)
		## TODO: change icon to indicate pre-activated

func _on_Cooldown_Timer_timeout():
	clockwipe.value = 0
	disabled = false
	set_process(false)
