extends Control

onready var screen = $screen
enum fade {
	IN, OUT, IN_OUT
}
export (fade) var fade_type
export (float) var duration = 3.0
var tween

func _ready():
	start_fade()

func start_fade():
	var end_state
	if fade_type == fade.OUT:
		self.modulate = Color(1,1,1,1)
		end_state = Color(0,0,0,0)
	else:
		self.modulate = Color(0,0,0,0)
		end_state = Color(1,1,1,1)
	var start_state = self.modulate
	tween = Tween.new()
	tween.interpolate_property(self, 
	"modulate", 
	start_state, end_state,
	 duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	if fade_type == fade.IN_OUT:
		tween.interpolate_property(self, 
		"modulate", 
		end_state, start_state,
		 duration, Tween.TRANS_SINE, Tween.EASE_OUT)
		add_child(tween)
		tween.start()
