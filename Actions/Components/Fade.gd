extends Tween

var target
export(float) var start_fade
export(float) var end_fade
export(float) var fade_time
export(bool) var destroy_after_fade


# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		target = get_parent()
	interpolate_property(target, "modulate", 
	  Color(1, 1, 1, start_fade), Color(1, 1, 1, end_fade), fade_time, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	start()

func _on_Fade_tween_completed(object, key):
	if destroy_after_fade:
		ActionController.destroy(target)
