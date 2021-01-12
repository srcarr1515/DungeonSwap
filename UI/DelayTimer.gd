extends Node2D

onready var ui = $UI
onready var timer = $Timer
var parent
export (bool) var hide_when_finished = true

var delay_timer = null
var total_delay = 0

func _ready():
	set_process(false)

func start_timer(delay_amt):
	parent = get_parent()
	total_delay = delay_amt
	timer.wait_time = delay_amt
	show()
	timer.start()
	set_process(true)

func stop_timer():
	set_process(false)
	timer.stop()
	ui.value = 0

func _process(delta):
	ui.value = int((timer.time_left / total_delay) * 100)

func _on_Timer_timeout():
	if hide_when_finished:
		hide()
	set_process(false)
	ui.value = 0
