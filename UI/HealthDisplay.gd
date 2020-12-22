extends Node2D

var bar_red = preload("res://Assets/Icons/UI/barHorizontal_red.png")
var bar_green = preload("res://Assets/Icons/UI/barHorizontal_green.png")
var bar_yellow = preload("res://Assets/Icons/UI/barHorizontal_yellow.png")

onready var healthbar = $HealthBar
var parent = null
	
#func _process(delta):
#	global_rotation = 0

func init():
	parent = get_parent()
	healthbar.max_value = parent.stats.max_health
	update_healthbar(parent.stats.health)
	
func update_healthbar(value):
	healthbar.texture_progress = bar_green
	if value < healthbar.max_value * 0.7:
		healthbar.texture_progress = bar_yellow
	if value < healthbar.max_value * 0.35:
		healthbar.texture_progress = bar_red
	if value < healthbar.max_value:
		show()
	healthbar.value = value

func _on_health_changed(value):
	if parent != null && "state" in parent && parent.stats.health < value:
#		parent.state.set_animation("flash_hit")
		pass
	update_healthbar(value)
	## TODO: Should move this into a more logical area (this seems out of place here.)
	if parent != null && "stun_amt" in parent:
		if parent.stun_amt == 0:
			parent.stun_amt = 0.5
			parent.state.state_event({"event": "stunned"})
