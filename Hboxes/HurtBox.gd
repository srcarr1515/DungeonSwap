extends Area2D

export(bool) var show_hit = true

#const HitEffect = preload("res://Effects/HitEffect.tscn")
var is_overlapping = false
export(float) var delay = 0.75
onready var timer = $Timer
signal on_hit

func trigger_hit():
	SFX.create('Shield Metal 1_1.wav', rand_range(-24.0, -18.0))
	pass
#	var effect = HitEffect.instance()
#	var main = get_tree().current_scene
#	main.add_child(effect)
#	effect.global_position = global_position
#	is_overlapping = true
#	emit_signal("on_hit")
#	timer.start(delay)

func _on_HurtBox_area_entered(area):
	if show_hit:
		trigger_hit()

func _on_HurtBox_area_exited(area):
	is_overlapping = false

func _on_Timer_timeout():
	if is_overlapping:
		pass
