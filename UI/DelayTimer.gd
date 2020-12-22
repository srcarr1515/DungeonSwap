extends Node2D

onready var ui = $UI
onready var timer = $Timer
var parent

var delay_timer = null
var total_delay = 0

func _ready():
	hide()
	set_process(false)

func start_timer(delay_amt):
	parent = get_parent()
	total_delay = delay_amt
	timer.wait_time = delay_amt
	show()
	timer.start()
	set_process(true)

func _process(delta):
	ui.value = int((timer.time_left / total_delay) * 100)

func _on_Timer_timeout():
	hide()
	set_process(false)
	ui.value = 0
